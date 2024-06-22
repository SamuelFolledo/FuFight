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
                navigationView

                VStack(spacing: 12) {
                    profilePicture

                    usernameField

                    emailField

                    Spacer()

                    changePasswordButton

                    deleteAccountButton

                    logOutButton
                }
                .padding(.horizontal, horizontalPadding)
            }
            .alert(title: vm.alertTitle, 
                   message: vm.alertMessage,
                   isPresented: $vm.isAlertPresented)
            .alert(title: Str.deleteAccountQuestion,
                   primaryButton: AlertButton(type: .delete, action: vm.deleteAccount), 
                   secondaryButton: AlertButton(type: .secondaryCancel), 
                   isPresented: $vm.isDeleteAccountAlertPresented)
            .alert(withText: $vm.password,
                   fieldType: .password(.current),
                   title: Str.recentReauthenticationIsRequiredToMakeChanges,
                   primaryButton: AlertButton(title: Str.logInTitle, action: vm.reauthenticate),
                   isPresented: $vm.isReauthenticationAlertPresented)
            .padding(.top, UserDefaults.topSafeAreaInset + 6)
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
        .background(
            backgroundImage
                .padding(.trailing, 600)
        )
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarHidden(true)
    }

    var editSaveButton: some View {
        Button(action: vm.editSaveButtonTapped) {
            Text(vm.isViewingMode ? Str.editTitle : Str.saveTitle)
        }
        .appButton(.tertiary, hasPadding: false)
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
        Button {
            vm.changePasswordButtonTapped()
        } label: {
            Text(Str.changePasswordTitle)
                .frame(maxWidth: .infinity)
        }
        .appButton(.primary)
    }
    var deleteAccountButton: some View {
        Button(action: vm.deleteButtonTapped) {
            Text(Str.deleteTitle)
                .frame(maxWidth: .infinity)
        }
        .appButton(.destructive)
    }
    var logOutButton: some View {
        Button(action: vm.logOut) {
            Text(Str.logOutTitle)
                .frame(maxWidth: .infinity)
        }
        .appButton(.destructive, isBordered: true)
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

            editSaveButton
        }
    }
}

#Preview {
    NavigationView {
        AccountView(vm: AccountViewModel(account: Account()))
    }
}
