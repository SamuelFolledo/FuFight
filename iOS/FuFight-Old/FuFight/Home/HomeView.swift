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
                        FighterPreview()
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
                if let message = vm.loadingMessage {
                    ProgressView(message)
                }
            }
            .navigationDestination(for: GameRoute.self) { route in
                switch route {
                case .game:
                    GameView(path: $vm.path)
                }
            }
            .background(
                backgroundImage
                    .padding(.leading, 30)
            )
            .safeAreaInset(edge: .bottom) {
                playButton
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
            vm.path.append(GameRoute.game)
        } label: {
            Image("playButton")
                .frame(width: 200)
        }
    }
}

#Preview {
    HomeView(vm: HomeViewModel(account: fakeAccount))
}
