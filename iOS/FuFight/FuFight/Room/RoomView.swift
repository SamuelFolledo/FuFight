//
//  RoomView.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/25/24.
//

import SwiftUI

struct RoomView: View {
    @StateObject var vm: RoomViewModel

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                ZStack {
                    fighterView

                    VStack {
                        navigationView

                        VStack {
                            movesView
                        }
                        .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
                        .padding()
                    }
                }
            }
            .overlay {
                LoadingView(message: vm.loadingMessage)
            }
            .background(
                backgroundImage
                    .padding(.leading, 30)
            )
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
        ZStack {
            HStack {
                Spacer()

                Button {
                    vm.switchButtonSelected()
                } label: {
                    Image(systemName: "arrow.2.squarepath")
                        .foregroundStyle(.white)
                }
            }

            HStack {
                Spacer()

                Text("Edit")
                    .font(mediumTitleFont)
                    .foregroundStyle(.white)

                Spacer()
            }
        }
        .padding(.horizontal, smallerHorizontalPadding)
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
        }
    }

    @ViewBuilder var fighterView: some View {
        if let fighterScene = vm.fighterScene {
            DaePreview(scene: fighterScene)
        }
    }
}

#Preview {
    RoomView(vm: RoomViewModel(account: fakeAccount))
}
