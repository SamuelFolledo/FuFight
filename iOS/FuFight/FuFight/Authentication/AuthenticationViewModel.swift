//
//  AuthenticationViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/16/24.
//

import UIKit
import SwiftUI

@Observable
class AuthenticationViewModel: ViewModel {
    private(set) var step: AuthStep
    let account: Account

    var showForgotPassword: Bool = false
    var rememberMe: Bool = Defaults.saveEmailAndPassword {
        didSet {
            Defaults.saveEmailAndPassword = rememberMe
            saveTopFieldTextIfNeeded()
            saveBottomFieldTextIfNeeded()
        }
    }
    var topFieldType: FieldType = .emailOrUsername
    var topFieldText: String = Defaults.saveEmailAndPassword ? Defaults.savedEmail : "" {
        didSet {
            saveTopFieldTextIfNeeded()
        }
    }
    var topFieldHasError: Bool = false
    var topFieldIsActive: Bool = false
    var bottomFieldType: FieldType = Defaults.showPassword ? .visiblePassword : .password {
        didSet {
            Defaults.showPassword = bottomFieldType == .visiblePassword
        }
    }
    var bottomFieldText: String = Defaults.saveEmailAndPassword ? Defaults.savedPassword : "" {
        didSet {
            saveBottomFieldTextIfNeeded()
        }
    }
    var bottomFieldHasError: Bool = false
    var bottomFieldIsActive: Bool = false
    var error: Error?
    var selectedImage: UIImage = defaultProfilePhoto

    var topButtonIsEnabled: Bool {
        switch step {
        case .logIn, .signUp:
            return topFieldText.count >= 3 && bottomFieldText.count >= 3
        case .phone, .onboard:
            return topFieldText.count >= 3
        case .phoneVerification:
            return bottomFieldText.count >= 6
        }
    }

    //MARK: - Initializer

    init(step: AuthStep, account: Account) {
        self.step = step
        self.account = account
    }

    //MARK: - ViewModel Overrides
    func onAppear() { }

    func onDisappear() { }

    //MARK: - Public Methods
    func topButtonTapped() {
        bottomFieldIsActive = false
        //TODO: Show loading
        switch step {
        case .logIn:
            Task {
                await logIn()
            }
        case .signUp:
            Task {
                await signUp()
                topFieldIsActive = true
            }
        case .phone:
            TODO("Send phone code")
            updateStep(to: .phoneVerification)
        case .phoneVerification:
            TODO("Login/sign up with phone")
            transitionToHomeView()
        case .onboard:
            Task {
                await finishAccountCreation()
            }
        }
    }

    func bottomButtonTapped() {
        switch step {
        case .logIn:
            updateStep(to: .signUp)
        case .signUp:
            updateStep(to: .logIn)
        case .phone, .onboard:
            break
        case .phoneVerification:
            TODO("Cancel registration")
            updateStep(to: .logIn)
        }
    }

    func requestPasswordReset() {
        let email = topFieldText
        Task {
            do {
                try await auth.sendPasswordReset(withEmail: email)
            } catch {
                LOGE("SendingPasswordReset to \(email): \(error.localizedDescription)")
            }
        }
    }

    func onTopFieldReturnButtonTapped() {
        switch step {
        case .logIn, .signUp, .phone:
            validateTopField()
            topFieldIsActive = false
            bottomFieldIsActive = true
        case .phoneVerification, .onboard:
            topButtonTapped()
        }
    }

    func onBottomFieldReturnButtonTapped() {
        topButtonTapped()
    }

    func updateStep(to toStep: AuthStep) {
        step = toStep
        switch toStep {
        case .logIn:
            resetFields()
        case .signUp:
            resetFields()
        case .phone:
            resetFields()
        case .phoneVerification:
            break
        case .onboard:
            resetFields()
        }
    }
}

private extension AuthenticationViewModel {
    func signUp() async {
        validateTopField()
        //TODO: 1: Uncomment line below to prevent unsafe passwords
//        bottomFieldHasError = !bottomFieldText.isValidPassword
        if !topFieldHasError && !bottomFieldHasError {
            do {
                guard let authData = try await AccountNetworkManager.createUser(email: topFieldText, password: bottomFieldText) else { return }
                let updatedAccount = Account(authData)
                account.update(with: updatedAccount)
                updateStep(to: .onboard)
            } catch {
                LOGE("Error signing up \(error.localizedDescription)")
            }
        } else {
            LOGE("Email has error \(topFieldHasError) or password has error \(bottomFieldHasError)")
        }
    }

    func finishAccountCreation() async {
        validateTopField()
        if !topFieldHasError {
            do {
                if let imageUrl = try await AccountNetworkManager.storePhoto(selectedImage, for: account.userId) {
                    try await AccountNetworkManager.updateAuthenticatedAccount(username: topFieldText, photoURL: imageUrl)
                    account.username = topFieldText
                    account.imageUrl = imageUrl
                    transitionToHomeView()
                    try await AccountNetworkManager.setData(account: account)
                    try await AccountManager.saveCurrent(account)
                }
            } catch {
                LOGE("Error Finishing Account creation \(error.localizedDescription)")
            }
        }
    }

    func logIn() async {
        validateTopField()
        //TODO: 1: Uncomment line below to prevent unsafe passwords
//        bottomFieldHasError = !bottomFieldText.isValidPassword
        if !topFieldHasError && !bottomFieldHasError {
            do {
                ///Authenticate in Auth, then create an account from the fetched data from the database using the authenticated user's userId
                guard let authData = try await AccountNetworkManager.logIn(email: topFieldText, password: bottomFieldText),
                      let fetchedAccount = try await AccountNetworkManager.fetchData(userId: authData.user.uid)
                else { return }
                account.update(with: fetchedAccount)
                try await AccountManager.saveCurrent(account)
                ///Transition to home view
                transitionToHomeView()
            } catch {
                LOGE("Error Logging in \(error.localizedDescription)")
            }
        } else {
            LOGE("Email has error \(topFieldHasError) or password has error \(bottomFieldHasError)")
        }
    }

    func transitionToHomeView() {
        account.status = .valid
        AccountManager.saveCurrent(account)
    }

    func resetFields() {
        topFieldIsActive = false
        bottomFieldIsActive = false
        topFieldText = ""
        bottomFieldText = ""
        topFieldHasError = false
        bottomFieldHasError = false
    }

    ///Set topFieldHasError to true if text are not valid. This will also trim leading and trailing whitespaces
    func validateTopField() {
        topFieldText = topFieldText.trimmed
        switch step {
        case .logIn:
            topFieldHasError = !(topFieldText.isValidEmail || topFieldText.isValidUsername)
        case .signUp:
            topFieldHasError = !topFieldText.isValidEmail
        case .phone, .phoneVerification:
            break
        case .onboard:
            topFieldHasError = !topFieldText.isValidUsername
        }
    }

    func saveTopFieldTextIfNeeded() {
        if rememberMe && !topFieldText.isEmpty {
            Defaults.savedEmail = topFieldText
        } else if !rememberMe {
            Defaults.savedEmail = ""
        }
    }

    func saveBottomFieldTextIfNeeded() {
        let isPassword = bottomFieldType == .password || bottomFieldType == .visiblePassword
        if rememberMe && isPassword && !bottomFieldText.isEmpty {
            Defaults.savedPassword = bottomFieldText
        } else if !rememberMe && isPassword {
            Defaults.savedPassword = ""
        }
    }
}
