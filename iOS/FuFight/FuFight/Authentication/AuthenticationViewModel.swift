//
//  AuthenticationViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/16/24.
//

import UIKit
import SwiftUI

enum AuthStep {
    case logIn, signUp, phone, phoneVerification
    ///Step after signing up to add username and profile picture
    case onboard

    var title: String {
        switch self {
        case .logIn:
            return Str.logInTitle
        case .signUp:
            return Str.signUpTitle
        case .phone:
            return Str.phoneTitle
        case .phoneVerification:
            return Str.phoneCodeTitle
        case .onboard:
            return Str.finishSignUpTitle
        }
    }

    var topFieldType: FieldType {
        switch self {
        case .logIn:
            return .emailOrUsername
        case .signUp:
            return .email
        case .phone:
            return .phoneNumber
        case .phoneVerification:
            return .phoneCode
        case .onboard:
            return .username
        }
    }

    var topButtonTitle: String {
        switch self {
        case .logIn:
            return Str.logInTitle
        case .signUp:
            return Str.createAccountTitle
        case .phone:
            return Str.sendCode
        case .phoneVerification:
            return Str.verifyCode
        case .onboard:
            return Str.finishTitle
        }
    }

    var bottomFieldType: FieldType {
        switch self {
        case .logIn, .signUp:
            return .password
        case .phone:
            return .phoneCode
        case .phoneVerification:
            return .phoneCode
        case .onboard:
            //Should not appear
            return .username
        }
    }

    var bottomButtonTitle: String {
        switch self {
        case .logIn:
            return Str.dontHaveAnAccount
        case .signUp:
            return Str.alreadyHaveAnAccount
        case .phone, .onboard:
            return ""
        case .phoneVerification:
            return Str.cancelTitle
        }
    }
}

@Observable
class AuthenticationViewModel: ViewModel {
    private(set) var step: AuthStep
    private(set) var user: User?
    var username: String = ""
    var topFieldText: String = ""
    var topFieldHasError: Bool = false
    var topFieldIsActive: Bool = false
    var bottomFieldText: String = ""
    var bottomFieldHasError: Bool = false
    var bottomFieldIsActive: Bool = false
    var error: Error?

    //MARK: - Initializer

    init(step: AuthStep, user: User? = nil) {
        self.step = step
        self.user = user
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
            print("TODO: Log in, then go to game view")
            validateUser()
        case .signUp:
            signUp()
        case .phone:
            print("TODO: Send phone code")
            updateStep(to: .phoneVerification)
        case .phoneVerification:
            print("TODO: Login/sign up with phone")
            validateUser()
        case .onboard:
            finishAccountCreation()
        }
    }

    func bottomButtonTapped() {
        switch step {
        case .logIn:
            updateStep(to: .signUp)
        case .signUp:
            updateStep(to: .logIn)
        case .phone, .onboard:
            print("TODO: button should be hidden")
            break
        case .phoneVerification:
            print("TODO: Cancel registration")
            updateStep(to: .logIn)
        }
    }

    func onTopFieldSubmit() {
        topFieldIsActive = false
        bottomFieldIsActive = true
        switch step {
        case .logIn:
            topFieldHasError = !topFieldText.isValidEmail || !topFieldText.isValidUsername
        case .signUp:
            topFieldHasError = !topFieldText.isValidEmail
        case .phone, .phoneVerification:
            break
        case .onboard:
            topFieldHasError = !topFieldText.isValidUsername
        }
    }

    func onBottomFieldSubmit() {
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
    func signUp() {
        topFieldHasError = !topFieldText.isValidEmail
        //TODO: 1: Uncomment line below to prevent unsafe passwords
//        bottomFieldHasError = !bottomFieldText.isValidPassword
        if bottomFieldHasError {
            print("Password has issue with \(bottomFieldText)")
        }
        if !topFieldHasError && !bottomFieldHasError {
            AccountNetworkManager.createUser(email: topFieldText, password: bottomFieldText) { user, error in
                if let error  {
                    self.error = error
                }
                if let user {
                    print("Successfully create a user \(user.emailAddress) with status \(user.accountStatus)")
                    self.user = user
                    self.goToOnboarding()
                    //TODO: Show Onboarding
                }
            }
        } else {
            print("Email has error \(topFieldHasError) or password has error \(bottomFieldHasError)")
        }
    }

    func goToOnboarding() {
        updateStep(to: .onboard)
        topFieldText = ""
    }

    func finishAccountCreation() {
        topFieldHasError = !topFieldText.isValidUsername
        if !topFieldHasError {
            print("TODO: Store image and write user data to Database")
            validateUser()
        }
    }

    func validateUser() {
        if let user {
            user.accountStatus = .valid
        } else {
            let isPhone = step == .phone || step == .phoneVerification
            if isPhone {
                user = User.init(userId: "123", username: username, firstName: "FName", lastName: "LName", phoneNumber: topFieldText, createdAt: Date(), updatedAt: Date())
            } else {
                user = User.init(userId: "123", username: username, firstName: "FName", lastName: "LName", email: topFieldText, createdAt: Date(), updatedAt: Date())
            }
            validateUser()
        }
    }

    func resetFields() {
        topFieldIsActive = false
        bottomFieldIsActive = false
        topFieldText = ""
        bottomFieldText = ""
        topFieldHasError = false
        bottomFieldHasError = false
    }
}
