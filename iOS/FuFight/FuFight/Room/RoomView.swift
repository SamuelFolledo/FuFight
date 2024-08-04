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
                                vm.showUnlockFighterAlert(fighterType, isDiamond: isDiamond)
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
        ZStack {
            if vm.showUnlockFighterView,
               let fighterToBuy = vm.fighterToBuy {
                let isDiamond = vm.isPurchasingWithDiamond
                PopupView(isShowing: $vm.showUnlockFighterView,
                          title: "Unlock Fighter?",
                          showOkayButton: false,
                          bodyContent: UnlockFighterView(fighterType: fighterToBuy,
                                                         isShowing: $vm.showUnlockFighterView,
                                                         isDiamond: isDiamond,
                                                         currentCurrency: isDiamond ? vm.account.diamonds : vm.account.coins,
                                                         cost: isDiamond ? fighterToBuy.diamondCost : fighterToBuy.coinCost,
                                                         unlockAction: vm.unlockFighter))
            }
            if vm.showInsufficientCoinsAlert {
                PopupView(isShowing: $vm.showInsufficientCoinsAlert, title: MainErrorType.insufficientDiamonds.title, bodyContent: VStack {
                    AppText("Top up to get more coins", type: .alertMedium)
                })
            }
            if vm.showInsufficientDiamondsAlert {
                PopupView(isShowing: $vm.showInsufficientDiamondsAlert, title: MainErrorType.insufficientDiamonds.title, bodyContent: VStack {
                    AppText("Top up to get more diamonds", type: .alertMedium)
                })
            }
        }
    }
}

#Preview {
    RoomView(vm: RoomViewModel(account: fakeAccount))
}

