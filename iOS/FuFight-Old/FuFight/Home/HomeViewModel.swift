//
//  HomeViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/16/24.
//

import SwiftUI
import FirebaseAuth

@Observable
class HomeViewModel: BaseAccountViewModel {
    var isAccountVerified = false
    var path = NavigationPath()

    //MARK: - ViewModel Overrides

    override func onAppear() {
        super.onAppear()
        if !isAccountVerified {
            verifyAccount()
        }
    }

    //MARK: - Public Methods
}

//MARK: - Private Methods
private extension HomeViewModel {
    ///Make sure account is valid at least once
    func verifyAccount() {
        Task {
            do {
                if try await AccountNetworkManager.isAccountValid(userId: account.userId) {
                    LOGD("Account verified", from: HomeViewModel.self)
                    isAccountVerified = true
                    return
                }
                LOGE("Account is invalid \(account.displayName) with id \(account.userId)", from: HomeViewModel.self)
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
