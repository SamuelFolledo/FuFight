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
            MovesView(
                attacksView: AttacksView(attacks: vm.player.moves.attacks, playerType: vm.playerType, isEditing: true) {
                    vm.attackSelected($0 as! AttackProtocol)
                },
                defensesView: DefensesView(defenses: vm.player.moves.defenses, playerType: vm.playerType) {
                    vm.defenseSelected($0)
                },
                playerType: vm.playerType)
        }
    }

    @ViewBuilder var fighterView: some View {
        if vm.player != nil {
            DaePreview(fighterType: vm.player.fighterType, animationType: vm.animationType)
        }
    }
}

#Preview {
    RoomView(vm: RoomViewModel(account: fakeAccount))
}
