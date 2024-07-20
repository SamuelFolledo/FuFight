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
                    homeButtonsView(position: .topTrailing, reader: reader)

                    HStack(alignment: .top) {
                        homeButtonsView(position: .leading, reader: reader)

                        Spacer()

                        VStack {
                            AppText("\(vm.selectedGameType.title)", type: .titleMedium)

                            Spacer()
                        }

                        Spacer()

                        homeButtonsView(position: .trailing, reader: reader)
                    }
                    .padding(.top, 25)

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
        .overlay {
            GeometryReader { reader in
                homeButtonAlerts(reader)
            }
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

    @ViewBuilder func homeButtonAlerts(_ reader: GeometryProxy) -> some View {
        if vm.showRewards {
            PopupView(isShowing: $vm.showRewards,
                      title: "TODO: Rewards",
                      bodyContent: VStack {

            })
        } else if vm.showInbox {
            PopupView(isShowing: $vm.showInbox,
                      title: "TODO: Inbox",
                      bodyContent: VStack {
                AppText("TODO:::", type: .textMedium)

                AppText("TODO:::", type: .textMedium)
            })
        } else if vm.showSettings {
            PopupView(isShowing: $vm.showSettings,
                      title: "TODO: Settings",
                      bodyContent: VStack {
                AppText("TODO:::", type: .textMedium)

                AppText("TODO:::", type: .textMedium)
            })
        } else if vm.showPromotions {
            PopupView(isShowing: $vm.showPromotions,
                      title: "TODO: Promotions",
                      bodyContent: VStack {
                AppText("TODO:::", type: .textMedium)

                AppText("TODO:::", type: .textMedium)
            })
        } else if vm.showTasks {
            PopupView(isShowing: $vm.showTasks,
                      title: "TODO: Tasks",
                      bodyContent: VStack {
                AppText("TODO:::", type: .textMedium)

                AppText("TODO:::", type: .textMedium)
            })
        } else if vm.showChests {
            PopupView(isShowing: $vm.showChests,
                      title: "TODO: Chests",
                      bodyContent: VStack {
                AppText("TODO:::", type: .textMedium)

                AppText("TODO:::", type: .textMedium)
            })
        } else if vm.showLeaderboards {
            PopupView(isShowing: $vm.showLeaderboards,
                      title: "TODO: Leaderboards",
                      bodyContent: VStack {
                AppText("TODO:::", type: .textMedium)

                AppText("TODO:::", type: .textMedium)
            })
        }
    }

    @ViewBuilder var fighterView: some View {
        if let player = Room.current?.player {
            DaePreview(scene: createFighterScene(fighterType: player.fighterType, animation: .idleStand))
                .ignoresSafeArea()
        }
    }

    @ViewBuilder func homeButtonsView(position: HomeButtonType.Position, reader: GeometryProxy) -> some View {
        if !vm.isOffline {
            if position == .topTrailing {
                HStack {
                    Spacer()

                    ForEach(vm.availableButtonTypes.compactMap({ $0.position == .topTrailing ? $0 : nil }), id: \.id) { buttonType in
                        Button {
                            vm.homeButtonTapped(buttonType)
                        } label: {
                            buttonType.image
                        }
                    }
                }
                .frame(height: 35)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.trailing, smallerHorizontalPadding - 4)
                .transition(.move(edge: .trailing))
            } else {
                //Side buttons
                VStack(alignment: .center, spacing: 16) {
                    ForEach(vm.availableButtonTypes.compactMap { $0.position == position ? $0 : nil }, id: \.id) { buttonType in
                        switch buttonType {
                        case .promotions, .tasks, .chests, .leaderboards, .rewards, .inbox, .profile, .settings:
                            Button {
                                vm.homeButtonTapped(buttonType)
                            } label: {
                                buttonType.image
                            }
                            .background {
                                roundedButtonBackgroundImage
                            }
                        case .friendPicker:
                            PopoverButton(type: buttonType, showPopover: $vm.showFriendPicker, popOverContent: {
                                friendPickerView(reader)
                            })
                            .overlay(alignment: .bottomLeading) {
                                onlineFriendsCountLabel
                            }
                            .background {
                                roundedButtonBackgroundImage
                            }
                        }
                    }
                }
                .frame(width: 60)
                .fixedSize(horizontal: true, vertical: false)
                .padding(position.edgeSet, smallerHorizontalPadding - 4)
                .transition(.move(edge: position.edge))

            }
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
        AppButton(title: "Offline", color: .system, textType: .buttonLarge, minWidth: reader.size.width * buttonMinWidthMultiplier, maxWidth: reader.size.width * buttonMaxWidthMultiplier) {
            vm.transitionToOffline.send(vm)
        }
    }

    @ViewBuilder private func practiceButton(_ reader: GeometryProxy) -> some View {
        AppButton(title: "Practice", color: .main3, textType: .buttonLarge, minWidth: reader.size.width * buttonMinWidthMultiplier, maxWidth: reader.size.width * buttonMaxWidthMultiplier) {
            vm.transitionToPractice.send(vm)
        }
    }
}

#Preview {
    HomeView(vm: HomeViewModel(account: fakeAccount))
}
