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
        GeometryReader { reader in
            ZStack {

                //            fighterView

                VStack(spacing: 0) {
                    HStack(alignment: .top) {
                        sideButtonsView(position: .leading, reader: reader)

                        Spacer()

                        VStack {
                            AppText("\(vm.selectedGameType.title)", type: .titleMedium)

                            Spacer()

                            Spacer()
                        }

                        Spacer()

                        sideButtonsView(position: .trailing, reader: reader)
                    }

                    Spacer()

                    playButtons(reader)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
        .padding(.top, homeNavBarHeight + 6)
        .padding(.bottom, homeTabBarHeight)
        .overlay {
            LoadingView(message: vm.loadingMessage)
        }
        .background {
            GeometryReader { reader in
                VerticalTabView(selectedGameType: $vm.selectedGameType, proxy: reader) {
                    ForEach(vm.gameTypes, id: \.id) { type in
                        AnimatingBackgroundView(animate: vm.selectedGameType == type,
                                                leadingPadding: -900,
                                                color: type.color)
                        .tag(type)
                    }
                }
                .onChange(of: vm.selectedGameType) { oldValue, newValue in
                    vm.gameTypeUpdatedHandler()
                }
            }
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

    @ViewBuilder var fighterView: some View {
        if let player = Room.current?.player {
            DaePreview(scene: createFighterScene(fighterType: player.fighterType, animation: .idleStand))
                .ignoresSafeArea()
        }
    }

    @ViewBuilder func sideButtonsView(position: HomeButtonType.Position, reader: GeometryProxy) -> some View {
        if !vm.isOffline {
            VStack {
                ForEach(vm.availableButtonTypes.compactMap { $0.position == position ? $0 : nil }, id: \.id) { buttonType in
                    switch buttonType {
                        case .leading1, .leading2, .leading3, .trailing1, .trailing2:
                            PopoverButton(type: buttonType, popOverContent: {
                                EmptyView()
                            })
                        case .friendPicker:
                            PopoverButton(type: buttonType, showPopover: $vm.showFriendPicker, popOverContent: {
                                friendPickerView(reader)
                            })
                            .overlay(alignment: .bottomLeading) {
                                onlineFriendsCountLabel
                            }
                        }
                }
            }
            .padding(position.edgeSet, smallerHorizontalPadding - 4)
            .transition(.move(edge: position.edge))
        } else {
            EmptyView()
        }
    }

    var onlineFriendsCountLabel: some View {
        Color.green
            .overlay {
                AppText("\(fakeFriends.compactMap { $0.status == .online }.count)", type: .textSmall)
                    .padding(0.5)
                    .lineLimit(1)
            }
            .clipShape(Circle())
            .frame(width: 16, height: 16)
    }

    @ViewBuilder func friendPickerView(_ reader: GeometryProxy) -> some View {
        FriendPickerView()
            .frame(height: abs(reader.size.height - homeNavBarHeight) / 2.5)
            .presentationBackground(
                Color.black.opacity(0.7)
            )
    }

    @ViewBuilder private func playButtons(_ reader: GeometryProxy) -> some View {
        VStack(spacing: 50) {
            if vm.isOffline {
                practiceButton(reader)

                offlinePlayButton(reader)
            } else {
                playButton(reader)
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .padding(.bottom, 60)
        .padding(.top)
    }

    @ViewBuilder private func playButton(_ reader: GeometryProxy) -> some View {
        AppButton(title: "Play", textType: .buttonLarge, minWidth: reader.size.width * buttonMinWidthMultiplier, maxWidth: reader.size.width * buttonMaxWidthMultiplier) {
            vm.transitionToLoading.send(vm)
        }
    }

    @ViewBuilder private func offlinePlayButton(_ reader: GeometryProxy) -> some View {
        AppButton(title: "Offline", type: .greenCustom, textType: .buttonLarge, minWidth: reader.size.width * buttonMinWidthMultiplier, maxWidth: reader.size.width * buttonMaxWidthMultiplier) {
            vm.transitionToOffline.send(vm)
        }
    }

    @ViewBuilder private func practiceButton(_ reader: GeometryProxy) -> some View {
        AppButton(title: "Practice", type: .tertiaryCustom, textType: .buttonLarge, minWidth: reader.size.width * buttonMinWidthMultiplier, maxWidth: reader.size.width * buttonMaxWidthMultiplier) {
            vm.transitionToPractice.send(vm)
        }
    }
}

#Preview {
    HomeView(vm: HomeViewModel(account: fakeAccount))
}
