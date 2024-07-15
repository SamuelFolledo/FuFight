//
//  HomeViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/16/24.
//

import Combine
import SwiftUI

final class HomeViewModel: BaseAccountViewModel {
    var player: FetchedPlayer?
    @Published var fighter: Fighter!
    @Published var isAccountVerified = false
    @Published var path = NavigationPath()
    @Published var selectedGameType: GameType = .casual
    @Published var isOffline: Bool = false
    @Published var showFriendPicker: Bool = false

    let gameTypes: [GameType] = GameType.allCases
    let availableButtonTypes: [HomeButtonType] = HomeButtonType.allCases

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
    func gameTypeUpdatedHandler() {
        withAnimation {
            isOffline = !selectedGameType.requiresWifi
            showFriendPicker = false
        }
    }

    func homeButtonTapped(_ buttonType: HomeButtonType) {
        switch buttonType {
        case .leading1, .leading2, .leading3:
            LOG("Tapped leading button \(buttonType.rawValue)")
        case .trailing1, .trailing2:
            LOG("Tapped trailing button \(buttonType.rawValue)")
        case .friendPicker:
            break
        }
    }
}

private extension HomeViewModel {
    ///Make sure account is valid at least once
    @MainActor func verifyAccount() {
        if !isAccountVerified {
            Task {
                do {
                    if try await AccountNetworkManager.isAccountValid(userId: account.userId) {
                        LOGD("Account verified", from: HomeViewModel.self)
                        isAccountVerified = true
                        refreshPlayer()
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
        guard let room = Room.current else { return }
        self.player = room.player
        RoomManager.goOnlineIfNeeded()
        if let fighterType = player?.fighterType,
           room.player.fighterType != fighterType {
            fighter = Fighter(type: fighterType, isEnemy: false)
        }
    }
}
