//
//  GameLoadingViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/16/24.
//

import SwiftUI
import FirebaseAuth
import Combine
import FirebaseFirestore

class GameLoadingViewModel: BaseAccountViewModel, ObservableObject {
    @Published var lobby: GameLobby?
    @Published var player: Player
    @Published var enemyPlayer: Player?
    @Published var currentLobbyId: String?
    var onEnemyPlayerReceived: ((_ enemyPlayer: Player?)->Void)?

    private var isLobbyOwner: Bool = false
    private var listener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()

    init(player: Player, enemyPlayer: Player? = nil, account: Account, onEnemyPlayerReceived: ((_ enemyPlayer: Player?)->Void)? = nil) {
        self.player = player
        self.enemyPlayer = enemyPlayer
        self.onEnemyPlayerReceived = onEnemyPlayerReceived
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
            .store(in: &cancellables)

        //After getting a lobby with player and enemy, create an enemyPlayer
        $lobby
            .map { lobby in
                Player(lobby: lobby, isLobbyOwner: self.isLobbyOwner)
            }
            .assign(to: \.enemyPlayer, on: self)
            .store(in: &cancellables)

        //After receiving creating an enemyPlayer, go to GameView
        $enemyPlayer
            .receive(on: DispatchQueue.main)
            .sink { [weak self] player in
                if player != nil {
                    self?.onEnemyPlayerReceived?(player)
                }
            }
            .store(in: &cancellables)
    }

    deinit {
        unsubscribe()
        lobby = nil
        enemyPlayer = nil
        currentLobbyId = nil
    }

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
                            LOG("Created lobby is now valid against \(isLobbyOwner ? fetchedLobby.enemyUsername ?? "" : fetchedLobby.username ?? "") with fighter \(isLobbyOwner ? fetchedLobby.enemyFighterType?.rawValue ?? "" : fetchedLobby.fighterType?.rawValue ?? "")")
                            lobby = fetchedLobby
                        }
                    } catch {
                        LOGDE("Error creating lobby with error: \(error.localizedDescription)\t\t and data: \(snapshot.data()?.description ?? "")")
                    }
                }
            }
    }

    //MARK: - ViewModel Overrides

    override func onAppear() {
        super.onAppear()
        updateLoadingMessage(to: "Finding opponent")
        findOrCreateLobby()
    }

    override func onDisappear() {
        super.onDisappear()
        deleteCurrentLobby()
    }

    //MARK: - Public Methods
    func findOrCreateLobby() {
        Task {
            do {
                let lobbyIds = try await GameNetworkManager.findAvailableLobbies(userId: account.userId)
                if lobbyIds.isEmpty {
                    //Create lobby and wait for an enemy to join
                    //Create an enemy player from kENEMYUSERNAME
                    lobby = try! await GameNetworkManager.createLobby(lobby: GameLobby(player: player))
                    isLobbyOwner = true
                    updateLoadingMessage(to: "Waiting for opponent")
                    currentLobbyId = lobby!.lobbyId!
                    //TODO: Listen for changes and wait for up to 5-12 seconds
                } else {
                    //Join someone's lobby by writing to their lobby as an enemy
                    //Create an enemy player from kUSERNAME
                    LOGD("Lobbies found at \(lobbyIds)")
                    let lobbyId = lobbyIds.first!
                    lobby = GameLobby(lobbyId: lobbyId, enemyPlayer: player)
                    try await GameNetworkManager.joinLobby(lobby: lobby!)
                    isLobbyOwner = false
                    updateLoadingMessage(to: "Syncing with opponent")
                    currentLobbyId = lobbyId
                }
            } catch {
                updateError(MainError(type: .noOpponentFound, message: error.localizedDescription))
            }
        }
    }

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
}
