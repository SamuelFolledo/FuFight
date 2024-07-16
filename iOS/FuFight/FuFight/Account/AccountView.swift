//
//  AccountView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/23/24.
//

import SwiftUI

struct AccountView: View {
    @StateObject var vm: AccountViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    profilePicture

                    usernameField

                    emailField

                    Spacer()

                    VStack(spacing: 40) {
                        changePasswordButton

                        deleteAccountButton

                        logOutButton
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.top)
                }
                .padding(.horizontal, horizontalPadding)
            }
            .alert(title: vm.alertTitle, 
                   message: vm.alertMessage,
                   isPresented: $vm.isAlertPresented)
            .alert(title: Str.deleteAccountQuestion,
                   primaryButton: GameButton(type: .delete, action: vm.deleteAccount), 
                   secondaryButton: GameButton(type: .secondaryCancel), 
                   isPresented: $vm.isDeleteAccountAlertPresented)
            .alert(withText: $vm.password,
                   fieldType: .password(.current),
                   title: Str.recentReauthenticationIsRequiredToMakeChanges,
                   primaryButton: GameButton(title: Str.logInTitle, action: vm.reauthenticate),
                   isPresented: $vm.isReauthenticationAlertPresented)
            .padding(.top, homeNavBarHeight + 6)
            .padding(.bottom, UserDefaults.bottomSafeAreaInset + 6)
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
        .background {
            AnimatingBackgroundView(animate: true, leadingPadding: -900)
        }
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarHidden(true)
        .safeAreaInset(edge: .bottom) {
            navigationView
        }
    }

    var backButton: some View {
        GameButton(title: "Back", type: .delete, maxWidth: navBarButtonMaxWidth) {
            vm.didBack.send(vm)
        }
    }
    var editSaveButton: some View {
        GameButton(title: vm.isViewingMode ? Str.editTitle : Str.saveTitle, type: .custom, maxWidth: navBarButtonMaxWidth, action: vm.editSaveButtonTapped)
    }
    var profilePicture: some View {
        AccountImagePicker(selectedImage: $vm.selectedImage, url: $vm.account.photoUrl)
            .frame(width: accountImagePickerHeight, height: accountImagePickerHeight)
            .padding()
    }
    var usernameField: some View {
        UnderlinedTextField(
            type: .constant(.username),
            text: $vm.usernameFieldText,
            hasError: $vm.usernameFieldHasError,
            isActive: $vm.usernameFieldIsActive, 
            isDisabled: $vm.isViewingMode) {
                TODO("Is username unique?")
            }
            .onSubmit {
                vm.usernameFieldIsActive = false
            }
    }
    var emailField: some View {
        UnderlinedTextField(
            type: .constant(.email),
            text: .constant(vm.account.email ?? ""),
            isDisabled: .constant(true))
    }
    var changePasswordButton: some View {
        GameButton(title: Str.changePasswordTitle) {
            vm.changePasswordButtonTapped()
        }
    }
    var deleteAccountButton: some View {
        GameButton(title: Str.deleteTitle, type: .delete) {
            vm.deleteButtonTapped()
        }
    }
    var logOutButton: some View {
        GameButton(title: Str.logOutTitle, type: .delete) {
            vm.logOut()
        }
    }
    var navigationView: some View {
        HStack(alignment: .center) {
            backButton

            Spacer()

            editSaveButton
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.bottom, UserDefaults.bottomSafeAreaInset)
        .padding(.horizontal, smallerHorizontalPadding)
    }
}

#Preview {
    NavigationView {
        AccountView(vm: AccountViewModel(account: Account()))
    }
}
