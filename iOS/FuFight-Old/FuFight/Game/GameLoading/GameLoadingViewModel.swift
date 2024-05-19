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

        //After receiving a lobbyId (created or joined), subscribe to changes and update lobby
        $currentLobbyId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] lobbyId in
                if lobbyId != nil {
                    self?.unsubscribe()
                    self?.subscribeToLobbyChanges()
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
            .receive(on: DispatchQueue.main)
            .sink { [weak self] player in
                if let self, player != nil {
                    self.didFindEnemy.send(self)
                }
            }
            .store(in: &subscriptions)

        findOrCreateLobby()
    }

    deinit {
        unsubscribe()
        lobby = nil
        enemyPlayer = nil
        currentLobbyId = nil
    }

    //MARK: - ViewModel Overrides
    override func onDisappear() {
        super.onDisappear()
        deleteCurrentLobby()
    }

    //MARK: - Public Methods
    func deleteCurrentLobby() {
        guard let currentLobbyId,
            let lobby else { return }
        Task {
            if lobby.userId == player.userId {
                //Only lobby's owner can delete the lobby
                try await GameNetworkManager.deleteCurrentLobby(lobbyId: currentLobbyId)
            } else {
                //Delete enemy data from joined lobby
                try await GameNetworkManager.leaveLobby(lobbyId: currentLobbyId)
            }
        }
    }

    func findOrCreateLobby() {
        updateLoadingMessage(to: "Finding opponent")
        Task {
            do {
                let lobbyIds = try await GameNetworkManager.findAvailableLobbies(userId: account.userId)
                if lobbyIds.isEmpty {
                    //Create lobby and wait for an enemy to join
                    //Create an enemy player from kENEMYUSERNAME
                    let createdLobby = try! await GameNetworkManager.createLobby(lobby: GameLobby(player: player))
                    DispatchQueue.main.async {
                        self.updateLobby(gameLobby: createdLobby, isOwner: true)
                    }
                    //TODO: Listen for changes and wait for up to 5-12 seconds
                } else {
                    //Join someone's lobby by writing to their lobby as an enemy
                    //Create an enemy player from kUSERNAME
                    LOGD("Lobbies found at \(lobbyIds)")
                    let lobbyId = lobbyIds.first!
                    let fetchedLobby = GameLobby(lobbyId: lobbyId, enemyPlayer: player)
                    try await GameNetworkManager.joinLobby(lobby: fetchedLobby)
                    DispatchQueue.main.async {
                        self.updateLobby(gameLobby: fetchedLobby, isOwner: false)
                    }
                }
            } catch {
                updateError(MainError(type: .noOpponentFound, message: error.localizedDescription))
            }
        }
    }
}

private extension GameLoadingViewModel {
    func unsubscribe() {
        if listener != nil {
            listener?.remove()
            listener = nil
        }
    }

    ///subscribe to lobby database changes and update VM's lobby based on changes
    func subscribeToLobbyChanges() {
        if listener != nil {
            unsubscribe()
        }
        guard let currentLobbyId else { return }
        let query = lobbiesDb.document(currentLobbyId)
        listener = query
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return } //check if lobby creator goes here after enemy joins
                if let snapshot, snapshot.exists {
                    do {
                        let fetchedLobby = try snapshot.data(as: GameLobby.self)
                        if fetchedLobby.isValid {
                            DispatchQueue.main.async {
                                LOG("Created lobby is now valid against \(self.isLobbyOwner ? fetchedLobby.enemyUsername ?? "" : fetchedLobby.username ?? "") with fighter \(self.isLobbyOwner ? fetchedLobby.enemyFighterType?.rawValue ?? "" : fetchedLobby.fighterType?.rawValue ?? "")")
                                self.updateLobby(gameLobby: fetchedLobby, isOwner: self.isLobbyOwner)
                            }
                        }
                    } catch {
                        LOGDE("Error creating lobby with error: \(error.localizedDescription)\t\t and data: \(snapshot.data()?.description ?? "")")
                    }
                }
            }
    }

    @MainActor func updateLobby(gameLobby: GameLobby, isOwner: Bool) {
        isLobbyOwner = isOwner
        lobby = gameLobby
        currentLobbyId = gameLobby.lobbyId
        if isOwner {
            updateLoadingMessage(to: "Waiting for opponent")
        } else {
            updateLoadingMessage(to: "Syncing with opponent")
        }
    }
}
