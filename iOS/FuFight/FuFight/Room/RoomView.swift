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
                            CharacterListView(selectedFighterType: $vm.selectedFighterType, fighters: vm.fighters) { fighterType, isDiamond in
                                vm.buyFighter(fighterType, isDiamond: isDiamond)
                            }
                            .padding(.horizontal, smallerHorizontalPadding)
                        }
                        .padding(.bottom, homeBottomViewHeight)
                    }
                    .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
                    .padding(.top, homeNavBarHeight + 6)
                    .padding(.bottom, UserDefaults.bottomSafeAreaInset - charactersBottomButtonsHeight + bottomOffsetPadding + charactersBottomButtonsHeight)
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
        .overlay {
            GeometryReader { reader in
                alertViews(reader)
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
        .task {
            vm.loadFighters()
        }
    }

    @ViewBuilder func bottomButtonsView(_ reader: GeometryProxy) -> some View {
        VStack {
            Spacer()

            DropDownUp(options: vm.roomBottomButtons.compactMap { $0.text }, selectedOptionIndex: $vm.selectedBottomButtonIndex, showDropdown: $vm.showBottomButtonDropDown)
                .frame(maxWidth: .infinity)
                .frame(height: charactersBottomButtonsHeight)
                .padding(.horizontal, smallerHorizontalPadding)
                .padding(.bottom, homeTabBarHeightPadded + 5)
        }
    }

    @ViewBuilder func alertViews(_ reader: GeometryProxy) -> some View {
        if vm.showBuyFighterAlert,
           let fighterToBuy = vm.fighterToBuy {
            PopupView(isShowing: $vm.showBuyFighterAlert,
                      title: "Unlock fighter?",
                      showOkayButton: false,
                      bodyContent: UnlockFighterView(fighterType: fighterToBuy,
                                                     isShowing: $vm.showBuyFighterAlert,
                                                     currentCurrency: vm.isPurchasingWithDiamond ? vm.account.diamonds : vm.account.coins,
                                                     isDiamond: vm.isPurchasingWithDiamond,
                                                     cost: vm.isPurchasingWithDiamond ? fighterToBuy.diamondCost : fighterToBuy.coinCost,
                                                     buyAction: vm.unlockFighter))
        }
    }
}

#Preview {
    RoomView(vm: RoomViewModel(account: fakeAccount))
}

