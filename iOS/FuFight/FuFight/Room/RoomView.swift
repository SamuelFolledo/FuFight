//
//  RoomView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/5/24.
//

import SwiftUI

struct RoomView: View {
    @StateObject var vm: RoomViewModel

    private let bottomOffsetPadding: CGFloat = 24

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader { value in
                ZStack {
                    VStack {
                        Spacer()

                        VStack {
                            CharacterListView(selectedFighterType: $vm.selectedFighterType)
                                .padding(.horizontal, smallerHorizontalPadding)
                        }
                        .padding(.bottom, homeBottomViewHeight)
                    }
                    .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
                    .padding(.top, homeNavBarHeight + 6)
                    .padding(.bottom, UserDefaults.bottomSafeAreaInset - charactersBottomButtonsHeight + bottomOffsetPadding)
                }
            }
        }
        .overlay {
            LoadingView(message: vm.loadingMessage)
        }
        .overlay {
            GeometryReader { reader in
                bottomButtonsView(reader)
            }
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity)
        .background {
            AnimatingBackgroundView(animate: true, leadingPadding: -500)
        }
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
        .allowsHitTesting(vm.loadingMessage == nil)
    }

    @ViewBuilder func bottomButtonsView(_ reader: GeometryProxy) -> some View {
        VStack {
            Spacer()

            DropDownUp(options: vm.roomBottomButtons.compactMap { $0.text }, selectedOptionIndex: $vm.selectedBottomButtonIndex, showDropdown: $vm.showBottomButtonDropDown)
                .frame(height: charactersBottomButtonsHeight)
                .padding(.horizontal, smallerHorizontalPadding)
                .padding(.bottom, homeTabBarHeightPadded + 5)
        }
    }
}

#Preview {
    RoomView(vm: RoomViewModel(account: fakeAccount))
}

