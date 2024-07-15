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
                            Text("\(vm.selectedGameType.title)")
                                .font(mediumTitleFont)
                                .foregroundStyle(.white)

                            Spacer()

                            Spacer()
                        }

                        Spacer()

                        sideButtonsView(position: .trailing, reader: reader)
                    }

                    Spacer()

                    playButtons
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
                        }
                }
            }
            .padding(position.edgeSet, smallerHorizontalPadding - 4)
            .transition(.move(edge: position.edge))
        } else {
            EmptyView()
        }
    }

    @ViewBuilder func friendPickerView(_ reader: GeometryProxy) -> some View {
        FriendPickerView()
            .frame(width: reader.size.width / 1.8, height: abs(reader.size.height - homeNavBarHeight) / 2.5)
            .presentationBackground(
                Color.black.opacity(0.7)
            )
    }

    @ViewBuilder var playButtons: some View {
        VStack {
            if vm.isOffline {
                practiceButton

                offlinePlayButton
            } else {
                playButton
            }
        }
        .padding(.bottom, 60)
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
}

#Preview {
    HomeView(vm: HomeViewModel(account: fakeAccount))
}
