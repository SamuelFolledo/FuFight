//
//  GameLoadingViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/16/24.
//

import SwiftUI
import Combine
import FirebaseFirestore

final class GameLoadingViewModel: BaseAccountViewModel {
    @Published var room: Room?
    @Published var player: FetchedPlayer
    @Published var enemyPlayer: FetchedPlayer?
    @Published var currentRoomId: String?
    let didFindEnemy = PassthroughSubject<GameLoadingViewModel, Never>()
    let didCancel = PassthroughSubject<GameLoadingViewModel, Never>()

    private var isRoomOwner: Bool = false
    private var isEnemyFound: Bool = false
    private var listener: ListenerRegistration?
    private var subscriptions = Set<AnyCancellable>()

    override init(account: Account) {
        self.player = RoomManager.getPlayer() ?? FetchedPlayer(account)
        super.init(account: account)

        //After receiving a roomId, roomOwner will listen to room changes when challengers appears, while nonRoomOwner will listen to when a game Firestore document is created
        $currentRoomId
            .delay(for: 0.5, scheduler: RunLoop.main) //0.5 seconds delay fixed not transitioning to GameView when enemyPlayer appears
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

        //After getting a room with player and enemy, create an enemyPlayer
        $room
            .map { room in
                FetchedPlayer(room: room, isRoomOwner: self.isRoomOwner)
            }
            .assign(to: \.enemyPlayer, on: self)
            .store(in: &subscriptions)

        //After receiving creating an enemyPlayer, go to GameView
        $enemyPlayer
            .delay(for: 0.1, scheduler: RunLoop.main) // helps reduce the visual jank and this vm's enemyPlayer has been set
            .sink { [weak self] enemyPlayer in
                if let self, let enemyPlayer {
                    //stop subscribing to changes on the room
                    unsubscribe()
                    if isRoomOwner {
                        createGame(enemyPlayer: enemyPlayer)
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
        enemyPlayer = nil
        updateRoomStatus(.searching)
    }

    override func onDisappear() {
        super.onDisappear()
        unsubscribe()
        room = nil
        enemyPlayer = nil
        currentRoomId = nil
        subscriptions.removeAll()
        if isEnemyFound {
            isEnemyFound = false
            updateRoomStatus(.gaming)
        } else {
            updateRoomStatus(.online)
        }
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
                    self.updateRoom(gameRoom: ownedRoom, isOwner: true)
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
        LOGD("Subscribing to room changes as owner")
        let query = roomsDb.document(currentRoomId)
        listener = query
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let snapshot, snapshot.exists {
                    do {
                        let fetchedOwnedRoom = try snapshot.data(as: Room.self)
                        if fetchedOwnedRoom.isValid {
                            DispatchQueue.main.async {
                                self.updateRoom(gameRoom: fetchedOwnedRoom, isOwner: self.isRoomOwner)
                            }
                        }
                    } catch {
                        LOGDE("Error creating room with error: \(error.localizedDescription)\t\t and data: \(snapshot.data()?.description ?? "")")
                    }
                }
            }
    }

    @MainActor func updateRoom(gameRoom: Room, isOwner: Bool) {
        isRoomOwner = isOwner
        currentRoomId = gameRoom.player!.userId
        if isOwner {
            room = gameRoom
            updateLoadingMessage(to: "Waiting for opponent")
            if gameRoom.isValid {
                LOGD("Valid game room against enemyPlayer \(gameRoom.challengers.first!.username)")
                self.enemyPlayer = gameRoom.challengers.first!
            }
        }
    }

    func createGame(enemyPlayer: FetchedPlayer) {
        Task {
            if isRoomOwner, let room {
                try await GameNetworkManager.createGameFromRoom(room)
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
                          snapshot.exists else { return }
                    let fetchedGameAsChallenger = try snapshot.data(as: FetchedGame.self)
                    if fetchedGameAsChallenger.ownerId != player.userId {
                        enemyPlayer = fetchedGameAsChallenger.player
                        LOGD("Challenging to a game against the room owner \(fetchedGameAsChallenger.player.username)")
                        unsubscribe()
                    } else {
                        TODO("Handle when game created is not the user")
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

    func updateRoomStatus(_ status: Room.Status) {
        Task {
            do {
                try await RoomNetworkManager.updateStatus(to: status, roomId: player.userId)
            } catch let error {
                LOGE(error.localizedDescription, from: GameLoadingViewModel.self)
            }
        }
    }
}
