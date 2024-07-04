//
//  HomeView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject var vm: HomeViewModel

    var body: some View {
        ZStack {
            fighterView

            VStack {
                navigationView

                VStack {
                    Spacer()
                }
                .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
            }
            .padding(.top, UserDefaults.topSafeAreaInset + 6)
            .padding(.bottom, UserDefaults.bottomSafeAreaInset + 6)
        }
        .overlay {
            LoadingView(message: vm.loadingMessage)
        }
        .background(
            backgroundImage
                .padding(.leading, 30)
        )
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()

                VStack {
                    practiceButton

                    offlinePlayButton

                    playButton
                }
            }
            .padding(.bottom, UserDefaults.bottomSafeAreaInset + 90)
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity)
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
        .allowsHitTesting(vm.loadingMessage == nil)
    }

    var navigationView: some View {
        ZStack {
            HStack {
                accountImage

                Spacer()
            }
            
            HStack {
                Spacer()

                Text("Welcome \(vm.account.displayName)")
                    .font(mediumTitleFont)
                    .foregroundStyle(.white)

                Spacer()
            }
        }
        .padding(.horizontal, smallerHorizontalPadding)
    }

    var accountImage: some View {
        Button {
            vm.transitionToAccount.send(vm)
        } label: {
            AccountImage(url: vm.account.photoUrl, radius: 30)
        }
    }

    var playButton: some View {
        Button {
            vm.transitionToLoading.send(vm)
        } label: {
            Image("playButton")
                .frame(width: 150)
        }
    }

    var offlinePlayButton: some View {
        Button {
            vm.transitionToOffline.send(vm)
        } label: {
            Text("Offline")
                .padding(6)
                .frame(width: 120)
                .foregroundStyle(Color(uiColor: .systemBackground))
                .font(boldedButtonFont)
                .background(Color(uiColor: .label))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }

    var practiceButton: some View {
        Button {
            vm.transitionToPractice.send(vm)
        } label: {
            Text("Practice")
                .padding(6)
                .frame(width: 120)
                .foregroundStyle(Color(uiColor: .label))
                .font(buttonFont)
                .background(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }

    @ViewBuilder var fighterView: some View {
        if let player = Room.current?.player {
            DaePreview(scene: createFighterScene(fighterType: player.fighterType, animation: .idleStand))
                .ignoresSafeArea()
        }
    }
}

#Preview {
    HomeView(vm: HomeViewModel(account: fakeAccount))
}
