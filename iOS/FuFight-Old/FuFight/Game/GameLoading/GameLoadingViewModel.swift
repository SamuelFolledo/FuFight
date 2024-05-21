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
    @Published var lobby: GameLobby?
    @Published var player: Player
    @Published var enemyPlayer: Player?
    @Published var currentLobbyId: String?
    let didFindEnemy = PassthroughSubject<GameLoadingViewModel, Never>()
    let didCancel = PassthroughSubject<GameLoadingViewModel, Never>()

    private var isLobbyOwner: Bool = false
    private var listener: ListenerRegistration?
    private var subscriptions = Set<AnyCancellable>()

    init(player: Player, enemyPlayer: Player? = nil, account: Account) {
        self.player = player
        self.enemyPlayer = enemyPlayer
        super.init(account: account)

        //After receiving a lobbyId, lobbyOwner will listen to lobby changes when challengers appears, while nonLobbyOwner will listen to when a game Firestore document is created
        $currentLobbyId
            .delay(for: 0.5, scheduler: RunLoop.main) //0.5 seconds delay fixed not transitioning to GameView when enemyPlayer appears
            .sink { [weak self] lobbyId in
                if lobbyId != nil {
                    guard let self else { return }
                    if self.isLobbyOwner {
                        self.subscribeToLobbyChanges()
                    } else {
                        self.subscribeToGameChanges(with: lobbyId!)
                    }
                }
            }
            .store(in: &subscriptions)

        //After getting a lobby with player and enemy, create an enemyPlayer
        $lobby
            .map { lobby in
                Player(lobby: lobby, isLobbyOwner: self.isLobbyOwner)
            }
            .assign(to: \.enemyPlayer, on: self)
            .store(in: &subscriptions)

        //After receiving creating an enemyPlayer, go to GameView
        $enemyPlayer
            .delay(for: 0.1, scheduler: RunLoop.main) // helps reduce the visual jank and this vm's enemyPlayer has been set
            .sink { [weak self] enemyPlayer in
                if let self, let enemyPlayer {
                    //stop subscribing to changes on the lobby
                    unsubscribe()
                    if isLobbyOwner {
                        createGame(enemyPlayer: enemyPlayer)
                    } else {
                        didFindEnemy.send(self)
                    }
                }
            }
            .store(in: &subscriptions)

        findOrCreateLobby()
    }

    //MARK: - ViewModel Overrides
    override func onAppear() {
        super.onAppear()
        enemyPlayer = nil
    }

    override func onDisappear() {
        super.onDisappear()
        deleteCurrentLobby()
        unsubscribe()
        lobby = nil
        enemyPlayer = nil
        currentLobbyId = nil
        subscriptions.removeAll()
    }

    //MARK: - Public Methods
    func deleteCurrentLobby() {
        guard let currentLobbyId else { return }
        Task {
            if self.lobby?.player?.userId == player.userId {
                //Only lobby's owner can delete the lobby
                try await GameNetworkManager.deleteCurrentLobby(lobbyId: currentLobbyId)
            } else if lobby != nil {
                //Delete enemy data from joined lobby
                self.lobby?.leaveAsChallenger(userId: player.userId)
                try await GameNetworkManager.leaveLobby(self.lobby!)
            }
        }
    }
}

private extension GameLoadingViewModel {
    ///Search for lobbies the user can join. If there is no available lobby, creates a lobby and wait for challengers
    func findOrCreateLobby() {
        updateLoadingMessage(to: "Finding opponent")
        Task {
            do {
                let lobbyIds = try await GameNetworkManager.findAvailableLobbies(userId: account.userId)
                if lobbyIds.isEmpty {
                    //Create lobby and wait for an enemy to join
                    let ownedLobby = try! await GameNetworkManager.createOrRejoinLobby(lobby: GameLobby(player: player))
                    DispatchQueue.main.async {
                        self.updateLobby(gameLobby: ownedLobby, isOwner: true) //this has document id
                    }
                    //TODO: Listen for changes and wait for up to 5-12 seconds
                } else {
                    //Join someone's lobby by writing to their lobby as an enemy. Enemy in this case is the user
                    let lobbyId = lobbyIds.first!
                    let fetchedLobby = GameLobby(lobbyId: lobbyId, enemyPlayer: player)
                    try await GameNetworkManager.joinLobby(lobby: fetchedLobby)
                    isLobbyOwner = false
                    currentLobbyId = lobbyId
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

    ///subscribe to lobby database changes for lobby owners
    func subscribeToLobbyChanges() {
        if listener != nil {
            unsubscribe()
        }
        guard isLobbyOwner,
            let currentLobbyId
        else { return }
        LOGD("Subscribing to lobby changes as owner")
        let query = lobbiesDb.document(currentLobbyId)
        listener = query
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let snapshot, snapshot.exists {
                    do {
                        var fetchedLobby = try snapshot.data(as: GameLobby.self)
                        fetchedLobby.lobbyId = currentLobbyId
                        if fetchedLobby.isValid {
                            DispatchQueue.main.async {
                                self.updateLobby(gameLobby: fetchedLobby, isOwner: self.isLobbyOwner)
                            }
                        }
                    } catch {
                        LOGDE("Error creating lobby with error: \(error.localizedDescription)\t\t and data: \(snapshot.data()?.description ?? "")")
                    }
                }
            }
    }

    ///subscribe to game database changes when it is created for lobby joiner
    func subscribeToGameChanges(with lobbyId: String) {
        if listener != nil {
            unsubscribe()
        }
        guard !isLobbyOwner else { return }
        updateLoadingMessage(to: "Syncing with opponent")
        LOGD("Subscribing to game changes as joiner at \(lobbyId)")
        let query = gamesDb.document(lobbyId)
        listener = query
            .addSnapshotListener { [weak self] snapshot, error in
                do {
                    guard let self,
                          let snapshot,
                          snapshot.exists else { return }
                    var gameAsChallenger = try snapshot.data(as: FetchedGame.self)
                    gameAsChallenger.ownerId = lobbyId
                    if gameAsChallenger.enemyPlayer.userId == player.userId {
                        self.enemyPlayer = Player(fetchedPlayer: gameAsChallenger.player)
                    } else {
                        TODO("Handle when game created is not the user")
                    }
                } catch let error {
                    print(error)
                }
            }
    }

    @MainActor func updateLobby(gameLobby: GameLobby, isOwner: Bool) {
        isLobbyOwner = isOwner
        currentLobbyId = gameLobby.player!.userId
        if isOwner {
            lobby = gameLobby
            updateLoadingMessage(to: "Waiting for opponent")
            if gameLobby.isValid {
                LOGD("Valid game lobby with enemyPlayer \(gameLobby.challengers.first!.username)")
                self.enemyPlayer = Player(fetchedPlayer: gameLobby.challengers.first!)
            }
        }
    }

    func createGame(enemyPlayer: Player) {
        if isLobbyOwner {
            Task {
                try await GameNetworkManager.createGameFromLobby(lobby)
                self.didFindEnemy.send(self)
            }
        }
    }
}
