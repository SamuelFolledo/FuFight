//
//  GameLoadingView.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/16/24.
//

import SwiftUI

struct GameLoadingView: View {
    @Binding var path: NavigationPath
    @State var vm: GameLoadingViewModel

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
        .onAppear(delay: 3) {
            vm.updateLoadingMessage(to: "Creating match")

            runAfterDelay(delay: 0.2) {
                self.path.append(GameRoute.onlineGame)
            }
        }
    }

    var cancelButton: some View {
        Button {
            transitionBackToHome()
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

private extension GameLoadingView {
    func transitionBackToHome() {
        path.removeLast(path.count)
    }
}

#Preview {
    @State var path: NavigationPath = NavigationPath()

    return GameLoadingView(path: $path, vm: GameLoadingViewModel(player: fakePlayer, account: fakeAccount))
}
