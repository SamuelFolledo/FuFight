//
//  GameView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/4/24.
//

import SwiftUI

struct GameView: View {
    @Binding var path: NavigationPath
    @State var vm: GameViewModel
    @Environment(\.scenePhase) var scenePhase

    init(path: Binding<NavigationPath>, vm: GameViewModel) {
        self._path = path
        self.vm = vm
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .trailing) {
                enemyView

                enemyMovesView
            }

            Spacer()

            playerMovesView

            playerView
        }
        .background {
            GameSceneView(fighter: vm.player.fighter, enemyFighter: vm.enemyPlayer.fighter, isPracticeMode: vm.isPracticeMode)
                .ignoresSafeArea()
        }
        .alert(title: vm.alertTitle,
               message: vm.alertMessage,
               isPresented: $vm.isAlertPresented)
        .alert(title: vm.player.isDead ? "You lost" : "You won!",
               primaryButton: AlertButton(title: "Rematch", action: vm.rematch),
               secondaryButton: AlertButton(title: "Go home", action: { path.removeLast(path.count) }),
               isPresented: .constant(vm.state == .gameOver))
        .alert(title: "Game is paused",
               primaryButton: AlertButton(title: "Resume", action: {}),
               secondaryButton: AlertButton(title: "Exit", action: { path.removeLast(path.count) }),
               isPresented: $vm.isGamePaused)
        .overlay {
            timerView
        }
        .overlay {
            if let message = vm.loadingMessage {
                ProgressView(message)
            }
        }
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
        .allowsHitTesting(vm.loadingMessage == nil)
        .navigationBarBackButtonHidden()
        .onChange(of: scenePhase) {
            vm.scenePhaseChangedHandler(scenePhase)
        }
        .onReceive(vm.timer) { time in
            vm.decrementTimeByOneSecond()
        }
    }

    var timerView: some View {
        CountdownTimerView(timeRemaining: vm.timeRemaining, round: vm.player.rounds.count + 1)
            .frame(width: 160)
            .padding(.bottom, 400)
    }


    var enemyMovesView: some View {
        MovesView(
            attacksView: AttacksView(attacks: vm.enemyPlayer.moves.attacks, sourceType: .enemy),
            defensesView: DefensesView(defenses: vm.enemyPlayer.moves.defenses, sourceType: .enemy),
            sourceType: .enemy)
        .frame(width: 100, height: 120)
        .padding(.trailing)
    }

    var enemyView: some View {
        let player = vm.enemyPlayer
        let enemyPlayer = vm.player
        return PlayerView(player: player,
                   enemyDamagesList: DamagesListView(enemyRounds: enemyPlayer.rounds, isPlayerDead: player.isDead))
            .padding(.horizontal)
    }

    var playerMovesView: some View {
        MovesView(
            attacksView: AttacksView(attacks: vm.player.moves.attacks, sourceType: .user) {
                vm.attackSelected($0, isEnemy: false)
            },
            defensesView: DefensesView(defenses: vm.player.moves.defenses, sourceType: .user) {
                vm.defenseSelected($0, isEnemy: false)
            },
            sourceType: .user)
    }

    var playerView: some View {
        let player = vm.player
        let enemyPlayer = vm.enemyPlayer
        return PlayerView(player: player,
                          enemyDamagesList: DamagesListView(enemyRounds: enemyPlayer.rounds, isPlayerDead: player.isDead),
                   onImageTappedAction: {
            vm.isGamePaused = true
        })
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

#Preview {
    @State var path: NavigationPath = NavigationPath()

    return NavigationView {
        GameView(path: $path, vm: GameViewModel(isPracticeMode: true))
    }
}
