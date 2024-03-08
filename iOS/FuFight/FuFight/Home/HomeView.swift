//
//  HomeView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import SwiftUI

struct HomeView: View {
    @State var vm: HomeViewModel

    var body: some View {
        NavigationStack(path: $vm.path) {
            ScrollView {
                VStack {
                    Text("Welcome \(vm.account.displayName)")

                    Spacer()

                    playButton
                }
                .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
                .padding()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        accountImage
                    }
                }
            }
            .overlay {
                if let message = vm.loadingMessage {
                    ProgressView(message)
                }
            }
            .navigationDestination(for: GameRoute.self) { route in
                switch route {
                case .game:
                    GameView(path: $vm.path)
//                case .gameOver:
//                    GameOverView(path: $vm.path)
                }
            }
            .background(
                backgroundImage
                    .padding(.leading, 30)

            )
        }
        .navigationTitle("Welcome \(vm.account.displayName)")
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
        .allowsHitTesting(vm.loadingMessage == nil)
    }

    var accountImage: some View {
        NavigationLink(destination: AccountView(vm: AccountViewModel(account: vm.account))) {
            AccountImage(url: vm.account.photoUrl, radius: 30)
        }
    }

    var playButton: some View {
        Button {
            vm.path.append(GameRoute.game)
        } label: {
            Text("Start game")
        }
    }
}

#Preview {
    HomeView(vm: HomeViewModel(account: fakeAccount))
}
