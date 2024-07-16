//
//  AuthenticationView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject var vm: AuthenticationViewModel
    private let dividerWidth: CGFloat = 70

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    profilePicture

                    VStack(spacing: 12) {
                        fields

                        HStack {
                            rememberMeButton

                            Spacer()

                            forgetPasswordButton
                        }

                        authButtons
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .allowsHitTesting(vm.loadingMessage == nil)
            }
            .navigationBarTitle(vm.step.title, displayMode: .large)
            .overlay {
                LoadingView(message: vm.loadingMessage)
            }
            .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
//            .alert(withText: $vm.topFieldText,
//                   fieldType: .emailOrUsername,
//                   title: Str.putEmailOrUsernameToResetPassword,
//                   primaryButton: AlertButton(title: Str.sendLinkTitle, action: vm.requestPasswordReset),
//                   isPresented: $vm.showForgotPassword)
            .background(
                backgroundImage
                    .padding(.trailing, 400)
            )
        }
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
        .onTapGesture {
            hideKeyboard()
        }
    }

    @ViewBuilder var profilePicture: some View {
        if vm.step == .onboard {
            AccountImagePicker(selectedImage: $vm.selectedImage, url: .constant(nil))
                .frame(width: accountImagePickerHeight, height: accountImagePickerHeight)
                .padding(.top, 20)
                .padding(.bottom, 10)
        }
    }

    var fields: some View {
        VStack {
            switch vm.step {
            case .logIn, .phoneVerification, .signUp:
                topField

                bottomField
            case .phone, .onboard:
                topField
            }
        }
    }

    @ViewBuilder var rememberMeButton: some View {
        if vm.step != .onboard {
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
    }

    @ViewBuilder var forgetPasswordButton: some View {
        if vm.step == .logIn {
            Button(action: {
                vm.showForgotPassword = true
            }) {
                Text(Str.forgotPasswordTitleQuestion)
                    .background(.clear)
                    .foregroundColor(systemColor)
                    .font(buttonFont)
            }
            .padding(.vertical)
        }
    }

    var authButtons: some View {
        VStack(spacing: 80) {
            topButton

            bottomButton
        }
        .fixedSize(horizontal: true, vertical: false)
        .padding(.top)
    }

    var topField: some View {
        UnderlinedTextField(
            type: $vm.topFieldType,
            text: $vm.topFieldText,
            hasError: $vm.topFieldHasError,
            isActive: $vm.topFieldIsActive) {
                TODO("TODO: CHECK USERNAME HERE")
                TODO("Add an action for top field's trailing button. Step: \(vm.step), and type: \(vm.topFieldType)")
            }
        .onSubmit {
            vm.onTopFieldReturnButtonTapped()
        }
    }

    var bottomField: some View {
        UnderlinedTextField(
            type: $vm.bottomFieldType,
            text: $vm.bottomFieldText,
            isSecure: $vm.bottomFieldIsSecure,
            hasError: $vm.bottomFieldHasError,
            isActive: $vm.bottomFieldIsActive) {
                TODO("Add an action for bottom field's trailing button. Step: \(vm.step), and type: \(vm.bottomFieldType)")
            }
        .onSubmit {
            vm.onBottomFieldSubmit()
        }
    }

    var topButton: some View {
        GameButton(title: vm.step.topButtonTitle, action: vm.topButtonTapped)
        .disabled(!vm.topButtonIsEnabled)
    }

    @ViewBuilder var bottomButton: some View {
        switch vm.step {
        case .logIn, .signUp:
            GameButton(title: vm.step.bottomButtonTitle, type: .secondaryCustom, action: vm.bottomButtonTapped)
        case .phone, .phoneVerification, .onboard:
            EmptyView()
        }
    }
}


#Preview {
    AuthenticationView(vm: AuthenticationViewModel(step: .logIn, account: Account()))
}
