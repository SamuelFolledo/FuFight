//
//  PasswordlessLogInView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/1/24.
//

import SwiftUI

struct PasswordlessLogInView: View {
    @State var vm: PasswordlessLogInViewModel
    private let dividerWidth: CGFloat = 70

    var body: some View {
            ScrollView {
                VStack(spacing: 12) {
                    emailField

                    HStack {
                        rememberMeButton

                        Spacer()
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .allowsHitTesting(vm.loadingMessage == nil)
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationBarTitle(Str.passwordlessLogInTitle, displayMode: .large)
            .overlay {
                if let message = vm.loadingMessage {
                    ProgressView(message)
                }
            }
            .safeAreaInset(edge: .bottom, content: {
                sendLinkButton
            })
            .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
    }

    var emailField: some View {
        UnderlinedTextField(
            type: .constant(.email),
            text: $vm.emailFieldText,
            hasError: $vm.emailFieldHasError,
            isActive: $vm.emailFieldIsActive)
            .onSubmit {
                vm.sendLinkButtonTapped()
            }
    }

    @ViewBuilder var rememberMeButton: some View {
        Button(action: {
            vm.rememberMe = !vm.rememberMe
        }) {
            HStack {
                Image(uiImage: vm.rememberMe ? checkedImage : uncheckedImage)
                    .renderingMode(.template)
                    .foregroundColor(.label)

                Text(Str.rememberMe)
                    .background(.clear)
                    .foregroundColor(Color.label)
                    .font(buttonFont)
            }
        }
        .padding(.vertical)
    }

    var sendLinkButton: some View {
        Button(action: vm.sendLinkButtonTapped) {
            Text(Str.sendLogInLinkTitle)
                .frame(maxWidth: .infinity)
                .font(boldedButtonFont)
        }
        .appButton(.system)
        .disabled(!vm.sendLinkButtonIsEnabled)
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom)
    }
}


#Preview {
    NavigationView {
        PasswordlessLogInView(vm: PasswordlessLogInViewModel(account: Account()))
    }
}
