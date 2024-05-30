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
        .background(
            backgroundImage
                .padding(.trailing, 400)
        )
        .safeAreaInset(edge: .bottom) {
            cancelButton
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity)
    }

    var cancelButton: some View {
        Button {
            vm.didCancel.send(vm)
        } label: {
            Text("Cancel")
                .padding(6)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color(uiColor: .systemBackground))
                .font(.title)
                .background(Color(uiColor: .systemRed))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }
}

#Preview {
    GameLoadingView(vm: GameLoadingViewModel(account: fakeAccount))
}
