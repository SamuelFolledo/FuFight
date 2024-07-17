//
//  UpdatePasswordView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/26/24.
//

import SwiftUI

struct UpdatePasswordView: View {
    @StateObject var vm = UpdatePasswordViewModel()

    var body: some View {
        GeometryReader { reader in
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 12) {
                        currentPasswordField

                        passwordField

                        confirmPasswordField

                        Spacer()

                        updatePasswordButton(reader)
                    }
                    .padding(.horizontal, horizontalPadding)
                }
                .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
                .padding(.top, homeNavBarHeight + 6)
                .padding(.bottom, UserDefaults.bottomSafeAreaInset + 6)
            }
        }
        .overlay {
            LoadingView(message: vm.loadingMessage)
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
        .safeAreaInset(edge: .bottom) {
            navigationView
        }
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
    var backButton: some View {
        AppButton(title: "Back", type: .delete, textType: .buttonSmall, maxWidth: navBarButtonMaxWidth) {
            vm.didBack.send(vm)
        }
    }
    @ViewBuilder private func updatePasswordButton(_ reader: GeometryProxy) -> some View {
        AppButton(title: Str.updatePasswordTitle, maxWidth: reader.size.width * 0.4, action: vm.updatePasswordButtonTapped)
    }
    var navigationView: some View {
        HStack(alignment: .center) {
            backButton

            Spacer()
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.bottom, UserDefaults.bottomSafeAreaInset)
        .padding(.horizontal, smallerHorizontalPadding)
    }
}

#Preview {
    NavigationView {
        UpdatePasswordView(vm: UpdatePasswordViewModel())
    }
}
