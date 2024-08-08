//
//  RootSettingsView.swift
//  FuFight
//
//  Created by Samuel Folledo on 8/7/24.
//

import SwiftUI

struct RootSettingsView: View {
    @StateObject var vm: RootSettingsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 12) {

                    Spacer()

                }
                .padding(.horizontal, horizontalPadding)
            }
            .alert(title: vm.alertTitle,
                   message: vm.alertMessage,
                   isPresented: $vm.isAlertPresented)
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

    var navigationView: some View {
        HStack(alignment: .center) {
            AppButton(title: "Back", color: ColorType.destructive, textType: .buttonSmall, maxWidth: navBarButtonMaxWidth) {
                vm.didBack.send(vm)
            }

            Spacer()
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.bottom, UserDefaults.bottomSafeAreaInset)
        .padding(.horizontal, smallerHorizontalPadding)
    }
}

#Preview {
    RootSettingsView(vm: RootSettingsViewModel(account: fakeAccount))
}
