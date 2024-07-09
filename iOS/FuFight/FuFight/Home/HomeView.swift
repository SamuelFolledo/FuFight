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
            GeometryReader { reader in

                //            fighterView

                VStack(spacing: 0) {
                    Spacer()

                    HStack {
                        Spacer()

                        FriendPickerView()
                            .frame(width: reader.size.width / 2, height: abs(reader.size.height - homeNavBarHeight) / 3)
                            .padding(.trailing, smallerHorizontalPadding)
                    }

                    Spacer()

                    VStack {
                        practiceButton

                        offlinePlayButton

                        playButton
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
        .padding(.top, homeNavBarHeight + 6)
        .padding(.bottom, homeTabBarHeight)
        .overlay {
            LoadingView(message: vm.loadingMessage)
        }
        .background {
            AnimatingBackgroundView(animate: true, leadingPadding: -900)
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
