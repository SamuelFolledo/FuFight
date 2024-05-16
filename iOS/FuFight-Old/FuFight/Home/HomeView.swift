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
            GeometryReader { proxy in
                ScrollView {
                    ZStack {
                        DaePreview()
                            .frame(width: proxy.size.width, height: proxy.size.height)

                        VStack {
                            navigationView

                            VStack {
                                Text("Welcome \(vm.account.displayName)")
                                    .font(mediumTitleFont)
                                    .foregroundStyle(.white)

                                Spacer()
                            }
                            .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
                            .padding()
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
            .overlay {
                LoadingView(message: vm.loadingMessage)
            }
            .navigationDestination(for: GameRoute.self) { route in
                switch route {
                case .loading:
                    if let player = vm.player {
                        GameLoadingView(path: $vm.path, vm: GameLoadingViewModel(player: player, account: vm.account))
                    }
                case .onlineGame:
                    GameView(path: $vm.path, vm: GameViewModel(isPracticeMode: false, player: vm.player ?? fakePlayer, enemyPlayer: fakeEnemyPlayer))
                case .offlineGame:
                    GameView(path: $vm.path, vm: GameViewModel(isPracticeMode: false, player: vm.player ?? fakePlayer, enemyPlayer: fakeEnemyPlayer))
                case .practice:
                    GameView(path: $vm.path, vm: GameViewModel(isPracticeMode: true, player: vm.player ?? fakePlayer, enemyPlayer: fakeEnemyPlayer))
                }
            }
            .background(
                backgroundImage
                    .padding(.leading, 30)
            )
            .safeAreaInset(edge: .bottom) {
                VStack {
                    playButton

                    offlinePlayButton

                    practiceButton
                }
            }
            .navigationBarHidden(true)
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
        .allowsHitTesting(vm.loadingMessage == nil)
    }

    var navigationView: some View {
        HStack {
            accountImage

            Spacer()
        }
        .padding(.horizontal, smallerHorizontalPadding)
    }

    var accountImage: some View {
        NavigationLink(destination: AccountView(vm: AccountViewModel(account: vm.account))) {
            AccountImage(url: vm.account.photoUrl, radius: 30)
        }
    }

    var playButton: some View {
        Button {
            vm.path.append(GameRoute.loading)
        } label: {
            Image("playButton")
                .frame(width: 200)
        }
    }

    var offlinePlayButton: some View {
        Button {
            vm.path.append(GameRoute.offlineGame)
        } label: {
            Text("Offline Play")
                .padding(6)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color(uiColor: .systemBackground))
                .font(.title)
                .background(Color(uiColor: .label))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }

    var practiceButton: some View {
        Button {
            vm.path.append(GameRoute.practice)
        } label: {
            Text("Practice")
                .padding(6)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color(uiColor: .label))
                .font(.title)
                .background(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }
}

#Preview {
    HomeView(vm: HomeViewModel(account: fakeAccount))
}
