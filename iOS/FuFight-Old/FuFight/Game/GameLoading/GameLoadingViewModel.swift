//
//  GameLoadingViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/16/24.
//

import SwiftUI
import FirebaseAuth

@Observable
class GameLoadingViewModel: BaseAccountViewModel {
    var player: Player
    var enemyPlayer: Player?
    var currentLobbyId: String?

    init(player: Player, enemyPlayer: Player? = nil, account: Account) {
        self.player = player
        self.enemyPlayer = enemyPlayer
        super.init(account: account)
    }

    //MARK: - ViewModel Overrides

    override func onAppear() {
        super.onAppear()
        updateLoadingMessage(to: "Finding Opponent")
        findOpponent()
    }

    override func onDisappear() {
        super.onDisappear()
        deleteCurrentLobby()
    }

    //MARK: - Public Methods
    func findOpponent() {
        Task {
            do {
                let lobbyIds = try await GameNetworkManager.findAvailableLobbies(userId: account.userId)
                if lobbyIds.isEmpty {
                    if let lobbyId = try await GameNetworkManager.createLobby(for: account) {
                        currentLobbyId = lobbyId
                        //TODO: Wait for up to 5-12 seconds
                    }
                } else {
                    LOGD("Lobbies found at \(lobbyIds)")
                }
            } catch {
                updateError(MainError(type: .noOpponentFound, message: error.localizedDescription))
            }
        }
    }
}

//MARK: - Private Methods
private extension GameLoadingViewModel {
    func deleteCurrentLobby() {
        guard let currentLobbyId else { return }
        Task {
            try await GameNetworkManager.deleteCurrentLobby(lobbyId: currentLobbyId)
        }
    }
}
