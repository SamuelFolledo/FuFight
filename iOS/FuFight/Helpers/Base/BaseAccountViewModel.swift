//
//  BaseAccountViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/2/24.
//

import Foundation
import FirebaseAuth

@Observable
class BaseAccountViewModel: BaseViewModel {
    var account: Account
    var authChangesListener: AuthStateDidChangeListenerHandle?
    
    init(account: Account) {
        self.account = account
    }

    override func onAppear() {
        super.onAppear()
        observeAuthChanges()
    }

    override func onDisappear() {
        super.onDisappear()
        if let authChangesListener {
            auth.removeStateDidChangeListener(authChangesListener)
        }
    }
}

private extension BaseAccountViewModel {
    func observeAuthChanges() {
        authChangesListener = auth.addStateDidChangeListener { (authDataResult, updatedUser) in
            if let updatedUser,
               let account = Account.current {
                if updatedUser.uid != account.userId ||
                    updatedUser.displayName != account.username ||
                    updatedUser.photoURL != account.photoUrl ||
                    updatedUser.email != account.email ||
                    updatedUser.phoneNumber != account.phoneNumber {
                    let updatedAccount = Account(updatedUser)
                    LOGD("Auth ACCOUNT changes handler for \(updatedUser.displayName ?? "")", from: BaseAccountViewModel.self)
                    self.account.update(with: updatedAccount)
                    AccountManager.saveCurrent(self.account)
                }
            }
        }
    }
}
