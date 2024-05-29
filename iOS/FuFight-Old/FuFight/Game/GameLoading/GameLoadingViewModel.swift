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
                        didFindEnemy.send(self)
                    }
                }
            }
            .store(in: &subscriptions)

        findOrCreateRoom()
    }

    //MARK: - ViewModel Overrides
    override func onAppear() {
        super.onAppear()
        enemyPlayer = nil
    }

    override func onDisappear() {
        super.onDisappear()
        deleteCurrentRoom()
        unsubscribe()
        room = nil
        enemyPlayer = nil
        currentRoomId = nil
        subscriptions.removeAll()
    }

    //MARK: - Public Methods
    func deleteCurrentRoom() {
        guard let currentRoomId else { return }
        Task {
            if self.room?.player?.userId == player.userId {
                //Only room's owner can delete the room
                try await RoomNetworkManager.deleteCurrentRoom(roomId: currentRoomId)
            } else if room != nil {
                //Delete enemy data from joined room
                self.room?.leaveAsChallenger(userId: player.userId)
                try await RoomNetworkManager.leaveRoom(self.room!)
            }
        }
    }
}

private extension GameLoadingViewModel {
    ///Search for rooms the user can join. If there is no available room, creates a room and wait for challengers
    func findOrCreateRoom() {
        updateLoadingMessage(to: "Finding opponent")
        Task {
            do {
                let roomIds = try await RoomNetworkManager.findAvailableRooms(userId: account.userId)
                if roomIds.isEmpty {
                    //Create room and wait for an enemy to join
                    let ownedRoom = Room(player: player)
                    try! await RoomNetworkManager.createOrRejoinRoom(room: ownedRoom)
                    DispatchQueue.main.async {
                        self.updateRoom(gameRoom: ownedRoom, isOwner: true)
                    }
                    //TODO: Listen for changes and wait for up to 5-12 seconds
                } else {
                    //Join someone's room by writing to their room as an enemy. Enemy in this case is the user
                    let roomId = roomIds.first!
                    let fetchedRoom = Room(roomId: roomId, enemyPlayer: player)
                    try await RoomNetworkManager.joinRoom(room: fetchedRoom)
                    isRoomOwner = false
                    currentRoomId = roomId
                }
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
                    let gameAsChallenger = try snapshot.data(as: FetchedGame.self)
                    if gameAsChallenger.ownerId != player.userId {
                        self.enemyPlayer = gameAsChallenger.player
                    } else {
                        TODO("Handle when game created is not the user")
                    }
                } catch let error {
                    print(error)
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
                LOGD("Valid game room with enemyPlayer \(gameRoom.challengers.first!.username)")
                self.enemyPlayer = gameRoom.challengers.first!
            }
        }
    }

    func createGame(enemyPlayer: FetchedPlayer) {
        Task {
            if isRoomOwner, let room {
                try await GameNetworkManager.createGameFromRoom(room)
                self.didFindEnemy.send(self)
            }
        }
    }
}
