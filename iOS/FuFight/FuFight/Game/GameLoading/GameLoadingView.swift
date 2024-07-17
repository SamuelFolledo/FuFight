//
//  GameLoadingView.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/16/24.
//

import SwiftUI

struct GameLoadingView: View {
    @ObservedObject var vm: GameLoadingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer()

            }
            .alert(title: vm.alertTitle,
                   message: vm.alertMessage,
                   isPresented: $vm.isAlertPresented)
            .padding(.horizontal, horizontalPadding)
            .padding(.top, homeNavBarHeight + 6)
            .padding(.bottom, UserDefaults.bottomSafeAreaInset + 6)
        }
        .frame(maxWidth: .infinity)
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
        .safeAreaInset(edge: .bottom) {
            cancelButton
        }
        .navigationBarHidden(true)
    }

    var cancelButton: some View {
        Button {
            vm.cancelButtonTapped()
        } label: {
            AppText("Cancel", type: .buttonMedium)
                .padding(6)
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .systemRed))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
        .padding(.bottom, UserDefaults.bottomSafeAreaInset + 6)
    }
}

#Preview {
    GameLoadingView(vm: GameLoadingViewModel(account: fakeAccount))
}
