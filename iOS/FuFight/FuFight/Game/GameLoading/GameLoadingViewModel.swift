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
 */

final class GameLoadingViewModel: BaseAccountViewModel {
    @Published var game: FetchedGame?
    @Published var room: Room?
    ///Currently logged in player, does not necessarily means the owner
    @Published var player: FetchedPlayer
    @Published var enemy: FetchedPlayer?
    @Published var currentRoomId: String?
    let didFindEnemy = PassthroughSubject<GameLoadingViewModel, Never>()
    let didCancel = PassthroughSubject<GameLoadingViewModel, Never>()

    ///Set this to true if current player is first when the game begins
    var initiallyHasSpeedBoost: Bool = false
    var isChallenger: Bool = true
    private var isEnemyFound: Bool = false
    private var listener: ListenerRegistration?
    private var subscriptions = Set<AnyCancellable>()

    override init(account: Account) {
        self.player = RoomManager.getPlayer() ?? FetchedPlayer(account)
        super.init(account: account)

        //After room owner receives getting a room with player and enemy, create an enemy
        $room
            .map { room in
                guard let room,
                      !room.challengers.isEmpty else { return nil }
                return FetchedPlayer(room: room, isChallenger: self.isChallenger)
            }
            .assign(to: \.enemy, on: self)
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
        } else {
            RoomNetworkManager.updateStatus(to: .online, roomId: account.userId)
        }
        initiallyHasSpeedBoost = false
        isChallenger = true
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
                let rooms = try await RoomNetworkManager.fetchAvailableRooms(userId: account.userId)
                if rooms.isEmpty {
                    waitForChallenger()
                } else {
                    joinRoomAsChallenger(rooms: rooms)
                }
            } catch {
                updateError(MainError(type: .noOpponentFound, message: error.localizedDescription))
            }
        }
    }

    func waitForChallenger() {
        Task {
            updateLoadingMessage(to: "Waiting for an opponent")
            //TODO: Listen for changes and wait for up to 5-12 seconds
            guard let ownedRoom = Room.current else { return }
            DispatchQueue.main.async {
                self.updateRoom(ownedRoom, isChallenger: false)
            }
        }
    }

    func joinRoomAsChallenger(rooms: [Room]) {
        Task {
            do {
                //Select the room to join, and add the player as a challenger
                let room = rooms.first!
                room.challengers.append(player)
                //Update enemy's room
                try await RoomNetworkManager.updateRoom(room)
                DispatchQueue.main.async {
                    self.updateRoom(room, isChallenger: true)
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

    ///subscribe to changes on user's Rooms document
    func subscribeToRoomChanges() {
        if listener != nil {
            unsubscribe()
        }
        guard !isChallenger,
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
                        //This room should have challengers needed to be handled
                        let fetchedOwnedRoom = try snapshot.data(as: Room.self)
                        if !fetchedOwnedRoom.challengers.isEmpty {
                            unsubscribe()
                            DispatchQueue.main.async {
                                self.updateRoom(fetchedOwnedRoom, isChallenger: self.isChallenger)
                            }
                        }
                    } catch {
                        LOGDE("Error creating room with error: \(error.localizedDescription)\t\t and data: \(snapshot.data()?.description ?? "")")
                    }
                }
            }
    }

    @MainActor func updateRoom(_ gameRoom: Room, isChallenger: Bool) {
        self.isChallenger = isChallenger
        currentRoomId = gameRoom.player.userId
        room = gameRoom
        updateLoadingMessage(to: "Waiting for opponent")
        if isChallenger {
            if let enemy = gameRoom.challengers.first {
                subscribeToEnemyGameChanges(enemy.userId)
            } else {
                LOGE("Failed to join room as challenger")
            }
        } else {
            if let enemy = gameRoom.challengers.first {
                prepareForGameAsOwner(enemy: enemy)
            } else {
                subscribeToRoomChanges()
            }
        }
    }

    func prepareForGameAsOwner(enemy: FetchedPlayer) {
        Task {
            guard !isChallenger else { return }
            initiallyHasSpeedBoost = Bool.random()
            let game = FetchedGame(player: player, enemy: enemy, playerInitiallyHasSpeedBoost: initiallyHasSpeedBoost)
            try await GameNetworkManager.createGame(game)
            self.game = game
            subscribeToEnemyGameChanges(enemy.userId)
        }
    }

    func prepareForGameAsChallenger(enemy: FetchedPlayer) {
        Task {
            guard isChallenger,
                  let room else { return }
            let gameAsChallenger = FetchedGame(player: player, enemy: enemy, playerInitiallyHasSpeedBoost: initiallyHasSpeedBoost)
            try await GameNetworkManager.createGame(gameAsChallenger)
            self.game = gameAsChallenger
            transitionToGameView()
        }
        self.enemy = enemy
        let gameAsChallenger = FetchedGame(player: player, enemy: enemy, playerInitiallyHasSpeedBoost: initiallyHasSpeedBoost)
        Task {
            try await GameNetworkManager.createGame(gameAsChallenger)
            self.game = gameAsChallenger
            DispatchQueue.main.async {
                self.transitionToGameView()
            }
        }
    }

    ///As the player is challenged, subscribe to the enemy's game changes
    func subscribeToEnemyGameChanges(_ enemyId: String) {
        if listener != nil {
            unsubscribe()
        }
        updateLoadingMessage(to: "Syncing with opponent")
        let query = gamesDb.document(enemyId)
        listener = query
            .addSnapshotListener { [weak self] snapshot, error in
                do {
                    guard let self,
                          let snapshot,
                          snapshot.exists,
                          !snapshot.metadata.hasPendingWrites else { return }
                    let enemyGame = try snapshot.data(as: FetchedGame.self)
                    if isChallenger {
                        initiallyHasSpeedBoost = !enemyGame.playerInitiallyHasSpeedBoost
                        prepareForGameAsChallenger(enemy: enemyGame.player)
                    } else {
                        transitionToGameView()
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
