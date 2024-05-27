//
//  StoreViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/25/24.
//

import Combine
import SwiftUI

final class StoreViewModel: BaseAccountViewModel {
    @Published var player: Player?
    @Published var path = NavigationPath()
    //    let transitionToLoading = PassthroughSubject<StoreViewModel, Never>()
    //    let transitionToOffline = PassthroughSubject<StoreViewModel, Never>()
    //    let transitionToPractice = PassthroughSubject<StoreViewModel, Never>()
    //    let transitionToAccount = PassthroughSubject<StoreViewModel, Never>()

    //MARK: - Public Methods
    ///Make sure account is valid at least once
    @MainActor func verifyAccount() {
        Task {
            do {
                if try await AccountNetworkManager.isAccountValid(userId: account.userId) {
                    self.player = Player(userId: account.userId, photoUrl: account.photoUrl ?? fakePhotoUrl,
                                         username: Account.current?.displayName ?? "",
                                         hp: defaultMaxHp,
                                         maxHp: defaultMaxHp,
                                         fighter: Fighter(type: .samuel, isEnemy: false),
                                         state: PlayerState(boostLevel: .none, hasSpeedBoost: false),
                                         moves: Moves(attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses))
                    return
                }
                LOGE("Account is invalid \(account.displayName) with id \(account.userId)", from: StoreViewModel.self)
                AccountManager.deleteCurrent()
                updateError(nil)
                account.reset()
                account.status = .logOut
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
