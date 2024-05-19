//
//  UpdatePasswordViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/26/24.
//

import SwiftUI

final class UpdatePasswordViewModel: BaseViewModel {
    @Published var currentPassword = ""
    @Published var currentPasswordFieldType: FieldType = .password(.current)
    @Published var currentPasswordIsSecure = true
    @Published var currentPasswordHasError = false
    @Published var currentPasswordIsActive = false
    @Published var password = "" {
        didSet {
            validateNewPassword()
        }
    }
    @Published var passwordFieldType: FieldType = .password(.new)
    @Published var passwordIsSecure = true
    @Published var passwordHasError = false
    @Published var passwordIsActive = false
    @Published var confirmPassword = "" {
        didSet {
            validateConfirmNewPassword()
        }
    }
    @Published var confirmPasswordFieldType: FieldType = .password(.confirmNew)
    @Published var confirmPasswordIsSecure = true
    @Published var confirmPasswordHasError = false
    @Published var confirmPasswordIsActive = false
    var isUpdatePasswordButtonEnabled: Bool {
        if currentPassword.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            return false
        }
        return !currentPasswordHasError && !passwordHasError && !confirmPasswordHasError
    }

    override func onAppear() {
        super.onAppear()
        currentPasswordIsActive = true
    }

    //MARK: - Public Methods

    func updatePasswordButtonTapped() {
        currentPasswordIsActive = false
        passwordIsActive = false
        confirmPasswordIsActive = false
        validateNewPassword()
        validateConfirmNewPassword()
        updatePassword()
    }
}

private extension UpdatePasswordViewModel {
    func updatePassword() {
        guard !currentPasswordHasError, !passwordHasError, !confirmPasswordHasError else { return }
        Task {
            do {
                ///Reauthenticate
                updateLoadingMessage(to: Str.reauthenticatingAccount)
                try await AccountNetworkManager.reauthenticateUser(password: currentPassword)
                ///Update password
                updateLoadingMessage(to: Str.updatingPassword)
                try await AccountNetworkManager.updatePassword(password)
                updateError(nil)
                LOGD("Finished updating password for \(auth.currentUser!.displayName!)", from: AccountManager.self)
                dismissView()
            } catch {
                updateError(MainError(type: .reauthenticatingUser, message: error.localizedDescription))
            }
        }
    }

    func validateNewPassword() {
        //TODO: 1 Uncomment line below to prevent new unsafe password
//        passwordHasError = password.trimmed.isValidPassword
    }

    func validateConfirmNewPassword() {
        //TODO: 1 Uncomment line below to prevent new unsafe password
        //        passwordHasError = confirmPassword.trimmed.isValidPassword
        confirmPasswordHasError = confirmPassword.trimmed != password.trimmed
    }
}
