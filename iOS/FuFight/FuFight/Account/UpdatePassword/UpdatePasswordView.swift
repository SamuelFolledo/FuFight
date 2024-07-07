//
//  UpdatePasswordView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/26/24.
//

import SwiftUI

struct UpdatePasswordView: View {
    @StateObject var vm = UpdatePasswordViewModel()
//    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                navigationView

                VStack(spacing: 12) {
                    currentPasswordField

                    passwordField

                    confirmPasswordField

                    Spacer()
                }
                .padding(.horizontal, horizontalPadding)
            }
            .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
            .padding(.top, homeNavBarHeight + 6)
            .padding(.bottom, UserDefaults.bottomSafeAreaInset + 6)
        }
        .overlay {
            LoadingView(message: vm.loadingMessage)
        }
        .overlay {
            VStack {
                Spacer()

                updatePasswordButton
            }
        }
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
        .allowsHitTesting(vm.loadingMessage == nil)
        .onTapGesture {
            hideKeyboard()
        }
        .background {
            AnimatingBackgroundView(animate: true, leadingPadding: -900)
        }
        .navigationBarHidden(true)
    }

    var currentPasswordField: some View {
        UnderlinedTextField(
            type: $vm.currentPasswordFieldType,
            text: $vm.currentPassword,
            isSecure: $vm.currentPasswordIsSecure,
            hasError: $vm.currentPasswordHasError,
            isActive: $vm.currentPasswordIsActive,
            isDisabled: .constant(false))
        .onSubmit {
            vm.passwordIsActive = true
        }
    }
    var passwordField: some View {
        UnderlinedTextField(
            type: $vm.passwordFieldType,
            text: $vm.password,
            isSecure: $vm.passwordIsSecure,
            hasError: $vm.passwordHasError,
            isActive: $vm.passwordIsActive,
            isDisabled: .constant(false))
        .onSubmit {
            vm.confirmPasswordIsActive = true
        }
    }
    var confirmPasswordField: some View {
        UnderlinedTextField(
            type: $vm.confirmPasswordFieldType,
            text: $vm.confirmPassword,
            isSecure: $vm.confirmPasswordIsSecure,
            hasError: $vm.confirmPasswordHasError,
            isActive: $vm.confirmPasswordIsActive,
            isDisabled: .constant(false))
        .onSubmit {
            vm.updatePasswordButtonTapped()
        }
    }
    var updatePasswordButton: some View {
        Button(action: vm.updatePasswordButtonTapped) {
            Text(Str.updatePasswordTitle)
                .frame(maxWidth: .infinity)
        }
        .appButton(.primary)
        .disabled(!vm.isUpdatePasswordButtonEnabled)
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, UserDefaults.bottomSafeAreaInset + 6)
    }
    var navigationView: some View {
        HStack(alignment: .center) {
            Button(action: {
                vm.didBack.send(vm)
            }, label: {
                backButtonImage
                    .padding(.leading, smallerHorizontalPadding)
                    .frame(width: 104, height: 30)
            })

            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        UpdatePasswordView(vm: UpdatePasswordViewModel())
    }
}
