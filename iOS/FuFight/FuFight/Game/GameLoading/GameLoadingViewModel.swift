//
//  GameLoadingViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/16/24.
//

import SwiftUI
import Combine
import FirebaseFirestore

/*
 GameLoadingViewModel flow
 1. Look for rooms with status == .searching
    - If no rooms found, player becomes the room/game owner and waits for challengers. Room owner will be in charge of setting if player or enemy has the initialSpeedBoost and creating the Game document
    - If rooms found, player becomes a room/game owner's challenger
 2a) Room owner flow
    - For room owner, listen to their Room Firestore challengers joining
    - When challenger has been added to Room, create a Game document for both players
    - Transition to GameView
 2b) Room challenger
    - For room challenger, listen to owner's Game Firestore creation
    - Transition to GameView

 TODOs
 [] Challengers should update the room's status (i.e. pendingOpponent)
 [] Maybe, both players should listen Game changes along with the start time
 */

final class GameLoadingViewModel: BaseAccountViewModel {
    @Published var room: Room?
    ///Currently logged in player, does not necessarily means the owner
    @Published var player: FetchedPlayer
    @Published var enemy: FetchedPlayer?
    @Published var currentRoomId: String?
    let didFindEnemy = PassthroughSubject<GameLoadingViewModel, Never>()
    let didCancel = PassthroughSubject<GameLoadingViewModel, Never>()

    ///Set this to true if current player is first when the game begins
    var initiallyHasSpeedBoost: Bool = false
    var isRoomOwner: Bool = false
    private var isEnemyFound: Bool = false
    private var listener: ListenerRegistration?
    private var subscriptions = Set<AnyCancellable>()

    override init(account: Account) {
        self.player = RoomManager.getPlayer() ?? FetchedPlayer(account)
        super.init(account: account)

        //After receiving a roomId, roomOwner will listen to room changes when challengers appears, while nonRoomOwner will listen to when a game Firestore document is created
        $currentRoomId
            .delay(for: 0.5, scheduler: RunLoop.main) //0.5 seconds delay fixed not transitioning to GameView when enemy appears
            .sink { [weak self] roomId in
                if roomId != nil {
                    guard let self else { return }
                    if self.isRoomOwner {
                        self.subscribeToRoomChanges()
                    } else {
                        self.subscribeToGameChanges(with: roomId!)
                    }
                }
            }
            .store(in: &subscriptions)

        //After room owner receives getting a room with player and enemy, create an enemy
        $room
            .map { room in
                guard let room,
                      room.isValid else { return nil }
                return FetchedPlayer(room: room, isRoomOwner: self.isRoomOwner)
            }
            .assign(to: \.enemy, on: self)
            .store(in: &subscriptions)

        //After receiving creating an enemy, go to GameView
        $enemy
            .delay(for: 0.25, scheduler: RunLoop.main)
            .sink { [weak self] enemy in
                if let self, let enemy {
                    if isRoomOwner {
                        createGame(enemy: enemy)
                    } else {
                        transitionToGameView()
                    }
                }
            }
            .store(in: &subscriptions)

        findOpponent()
    }

    //MARK: - ViewModel Overrides
    override func onAppear() {
        super.onAppear()
        enemy = nil
        RoomNetworkManager.updateStatus(to: .searching, roomId: account.userId)
    }

    override func onDisappear() {
        super.onDisappear()
        unsubscribe()
        room = nil
        enemy = nil
        currentRoomId = nil
        subscriptions.removeAll()
        if isEnemyFound {
            isEnemyFound = false
            RoomNetworkManager.updateStatus(to: .gaming, roomId: account.userId)
        }
        initiallyHasSpeedBoost = false
        isRoomOwner = false
    }

    //MARK: - Public Methods
    func cancelButtonTapped() {
        didCancel.send(self)
    }
}

private extension GameLoadingViewModel {
    ///Search for rooms the user can join. If there is no available room, creates a room and wait for challengers
    func findOpponent() {
        updateLoadingMessage(to: "Finding opponent")
        Task {
            do {
                let roomIds = try await RoomNetworkManager.findAvailableRooms(userId: account.userId)
                if roomIds.isEmpty {
                    createOrRejoinRoom()
                } else {
                    joinRoomAsChallenger(roomIds: roomIds)
                }
            } catch {
                updateError(MainError(type: .noOpponentFound, message: error.localizedDescription))
            }
        }
    }

    func createOrRejoinRoom() {
        Task {
            do {
                //Create room and wait for an enemy to join
                let ownedRoom = Room(ownerPlayer: player)
                try await RoomNetworkManager.createOrRejoinRoom(room: ownedRoom)
                DispatchQueue.main.async {
                    self.updateRoom(ownedRoom, isOwner: true)
                }
                //TODO: Listen for changes and wait for up to 5-12 seconds
            } catch {
                updateError(MainError(type: .noOpponentFound, message: error.localizedDescription))
            }
        }
    }

    func joinRoomAsChallenger(roomIds: [String]) {
        Task {
            do {
                //Join someone's room by writing to their room as an enemy. Enemy in this case is the user
                let roomId = roomIds.first!
                try await RoomNetworkManager.joinRoom(player, roomId: roomId)
                isRoomOwner = false
                currentRoomId = roomId
            } catch {
                updateError(MainError(type: .noOpponentFound, message: error.localizedDescription))
            }
        }
    }

    func unsubscribe() {
        if listener != nil {
            listener?.remove()
            listener = nil
        }
    }

    ///subscribe to room database changes for room owners
    func subscribeToRoomChanges() {
        if listener != nil {
            unsubscribe()
        }
        guard isRoomOwner,
            let currentRoomId
        else { return }
        let query = roomsDb.document(currentRoomId)
        listener = query
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let snapshot,
                    snapshot.exists,
                   !snapshot.metadata.hasPendingWrites {
                    do {
                        let fetchedOwnedRoom = try snapshot.data(as: Room.self)
                        if fetchedOwnedRoom.isValid {
                            DispatchQueue.main.async {
                                self.updateRoom(fetchedOwnedRoom, isOwner: self.isRoomOwner)
                            }
                        }
                    } catch {
                        LOGDE("Error creating room with error: \(error.localizedDescription)\t\t and data: \(snapshot.data()?.description ?? "")")
                    }
                }
            }
    }

    @MainActor func updateRoom(_ gameRoom: Room, isOwner: Bool) {
        isRoomOwner = isOwner
        currentRoomId = gameRoom.owner!.userId
        if isOwner {
            room = gameRoom
            updateLoadingMessage(to: "Waiting for opponent")
        }
    }

    func createGame(enemy: FetchedPlayer) {
        Task {
            if isRoomOwner, let room {
                initiallyHasSpeedBoost = Bool.random()
                try await GameNetworkManager.createGameFromRoom(room, ownerInitiallyHasSpeedBoost: initiallyHasSpeedBoost)
                transitionToGameView()
            }
        }
    }

    ///subscribe to game database changes when it is created for room joiner
    func subscribeToGameChanges(with roomId: String) {
        if listener != nil {
            unsubscribe()
        }
        guard !isRoomOwner else { return }
        updateLoadingMessage(to: "Syncing with opponent")
        LOGD("Subscribing to game changes as joiner at \(roomId)")
        let query = gamesDb.document(roomId)
        listener = query
            .addSnapshotListener { [weak self] snapshot, error in
                do {
                    guard let self,
                          let snapshot,
                          snapshot.exists,
                          !snapshot.metadata.hasPendingWrites else { return }
                    let fetchedGameAsChallenger = try snapshot.data(as: FetchedGame.self)
                    if fetchedGameAsChallenger.enemy.userId == player.userId {
                        initiallyHasSpeedBoost = !fetchedGameAsChallenger.ownerInitiallyHasSpeedBoost
                        enemy = fetchedGameAsChallenger.owner
                    }
                } catch let error {
                    LOGE(error.localizedDescription, from: GameLoadingViewModel.self)
                }
            }
    }

    func transitionToGameView() {
        isEnemyFound = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.didFindEnemy.send(self)
        }
    }
}
