//
//  PasswordlessLogInViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/1/24.
//

import SwiftUI

@Observable
class PasswordlessLogInViewModel: BaseViewModel {
    let account: Account

    var rememberMe: Bool = Defaults.isSavingEmailAndPassword {
        didSet {
            Defaults.isSavingEmailAndPassword = rememberMe
            saveEmailFieldTextIfNeeded()
        }
    }
    var emailFieldText: String = "" {
        didSet {
            saveEmailFieldTextIfNeeded()
        }
    }
    var emailFieldHasError: Bool = false
    var emailFieldIsActive: Bool = false

    var sendLinkButtonIsEnabled: Bool {
        !emailFieldText.isEmpty
    }

    //MARK: - Initializer

    init(account: Account) {
        self.account = account
    }

    //MARK: - Public Methods
    func sendLinkButtonTapped() {
        emailFieldIsActive = false
        logIn()
    }
}

private extension PasswordlessLogInViewModel {
    func logIn() {
        validateEmailField()
        guard !emailFieldHasError else {
            return updateError(MainError(type: .invalidEmail))
        }
//        Task {
//            do {

//            } catch {
//                updateError(MainError(type: .logIn, message: error.localizedDescription))
//            }
//        }
    }

    func transitionToHomeView() {
        account.status = .online
        AccountManager.saveCurrent(account)
    }

    func resetFields() {
        emailFieldIsActive = false
        emailFieldText = ""
        emailFieldHasError = false
    }

    func validateEmailField() {
        emailFieldText = emailFieldText.trimmed
        emailFieldHasError = !emailFieldText.isValidEmail
    }

    func saveEmailFieldTextIfNeeded() {
        if rememberMe && !emailFieldText.isEmpty {
            Defaults.savedEmailOrUsername = emailFieldText
        } else if !rememberMe {
            Defaults.savedEmailOrUsername = ""
        }
    }

    func populateFieldsIfNeeded() {
        if Defaults.isSavingEmailAndPassword {
            emailFieldText = Defaults.savedEmailOrUsername
        }
    }
}
