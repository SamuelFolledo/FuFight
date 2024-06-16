//
//  HomeViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/16/24.
//

import Combine
import SwiftUI

final class HomeViewModel: BaseAccountViewModel {
    @Published var player: FetchedPlayer?
    @Published var enemyPlayer: FetchedPlayer?
    @Published var isAccountVerified = false
    @Published var path = NavigationPath()
    let transitionToLoading = PassthroughSubject<HomeViewModel, Never>()
    let transitionToOffline = PassthroughSubject<HomeViewModel, Never>()
    let transitionToPractice = PassthroughSubject<HomeViewModel, Never>()
    let transitionToAccount = PassthroughSubject<HomeViewModel, Never>()

    override init(account: Account) {
        super.init(account: account)
    }

    override func onAppear() {
        super.onAppear()
        DispatchQueue.main.async {
            self.verifyAccount()
        }
        refreshPlayer()
    }

    //MARK: - Public Methods
    ///Make sure account is valid at least once
    @MainActor func verifyAccount() {
        if !isAccountVerified {
            Task {
                do {
                    if try await AccountNetworkManager.isAccountValid(userId: account.userId) {
                        LOGD("Account verified", from: HomeViewModel.self)
                        isAccountVerified = true
                        refreshPlayer()
                        RoomNetworkManager.updateStatus(to: .online, roomId: account.userId)
                        return
                    }
                    LOGE("Account is invalid \(account.displayName) with id \(account.userId)", from: HomeViewModel.self)
                    AccountManager.deleteCurrent()
                    updateError(nil)
                    account.reset()
                    account.status = .loggedOut
                    if Defaults.isSavingEmailAndPassword {
                        Defaults.savedEmailOrUsername = ""
                        Defaults.savedPassword = ""
                    }
                } catch {
                    updateError(MainError(type: .deletingUser, message: error.localizedDescription))
                }
            }
        }
    }

    func refreshPlayer() {
        guard let player = RoomManager.getPlayer() else { return }
        self.player = player
        //TODO: Make sure to not set status to online if it's already online in the database
        RoomNetworkManager.updateStatus(to: .online, roomId: account.userId)
        Task {
            do {
                //TODO: Make sure to only delete the game in the database if it exist
                try await GameNetworkManager.deleteGame(player.userId)
            }
        }
    }
}
