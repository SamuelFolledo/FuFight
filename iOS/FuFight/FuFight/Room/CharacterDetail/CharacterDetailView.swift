//
//  CharacterDetailView.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/25/24.
//

import SwiftUI

struct CharacterDetailView: View {
    @StateObject var vm: CharacterDetailViewModel

    var body: some View {
        ZStack {
            fighterView

            VStack {
                navigationView
                
                Spacer()

                VStack {
                    movesView
                }
                .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
                .padding()

                fightersView
            }
            .padding(.top, homeNavBarHeight + 6)
            .padding(.bottom, UserDefaults.bottomSafeAreaInset + 40)
        }
        .overlay {
            LoadingView(message: vm.loadingMessage)
        }
        .overlay {
            bottomButtons
        }
        .background {
            AnimatingBackgroundView(animate: true, leadingPadding: -500)
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity)
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
        .onChange(of: vm.selectedFighterType ?? .samuel, { oldValue, newValue in
            if newValue != oldValue {
                vm.switchFighterTo(newValue)
            }
        })
        .allowsHitTesting(vm.loadingMessage == nil)
    }

    var navigationView: some View {
        ZStack {
            HStack {
                Spacer()
            }

            HStack {
                Spacer()

                AppText("\(vm.selectedFighterType?.name ?? "")", type: .titleMedium)
                Spacer()
            }
        }
        .padding(.horizontal, smallerHorizontalPadding)
    }

    var bottomButtons: some View {
        VStack {
            Spacer()

            HStack {
                AppButton(title: "Back", color: ColorType.destructive, textType: .buttonSmall, maxWidth: navBarButtonMaxWidth) {
                    vm.didBack.send(vm)
                }

                Spacer()
            }
        }
        .padding(.bottom, UserDefaults.bottomSafeAreaInset)
        .padding(.horizontal, smallerHorizontalPadding)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder var movesView: some View {
        if vm.player != nil {
            let attacks = vm.player.moves.attacks
            let defenses = vm.player.moves.defenses
            MovesView(
                attacksView: AttacksView(attacks: attacks, playerType: vm.playerType, isEditing: true) {
                    vm.attackSelected(attacks.getAttack(with: $0).position)
                },
                defensesView: DefensesView(defenses: defenses, playerType: vm.playerType) {
                    vm.defenseSelected(defenses.getDefense(with: $0).position)
                },
                playerType: vm.playerType)
            .padding(.bottom)
        }
    }

    @ViewBuilder var fightersView: some View {
//        FightersHorizontalView(selectedFighterType: $vm.selectedFighterType)
//            .frame(height: fighterCellSize)
//            .padding(.bottom, UserDefaults.bottomSafeAreaInset)
        EmptyView()
    }

    @ViewBuilder var fighterView: some View {
        if let fighterScene = vm.fighterScene {
            DaePreview(scene: fighterScene)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    CharacterDetailView(vm: CharacterDetailViewModel(account: fakeAccount))
}
