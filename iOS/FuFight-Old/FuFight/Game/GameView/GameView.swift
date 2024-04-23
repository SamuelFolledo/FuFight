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
                PlayerView(player: vm.enemyPlayer, rounds: vm.rounds)
                    .padding(.horizontal)

                enemyMovesView
            }

            Spacer()

            playerMovesView

            PlayerView(player: vm.player, rounds: vm.rounds, onImageTappedAction: {
                vm.isGamePaused = true
            })
            .padding(.horizontal)
            .padding(.top, 8)
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
               isPresented: $vm.isGameOver)
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
            switch scenePhase {
            case .background, .inactive:
                LOGD("Scene phase is \(scenePhase)")
                vm.isTimerActive = false
            case .active:
                vm.isTimerActive = true
            @unknown default:
                LOGDE("Unknown scene phase \(scenePhase)")
            }
        }
        .onReceive(vm.timer) { time in
            vm.decrementTimeByOneSecond()
        }
    }

    var timerView: some View {
        CountdownTimerView(timeRemaining: vm.timeRemaining, round: vm.rounds.count)
            .frame(width: 160)
            .padding(.bottom, 400)
    }


    @ViewBuilder var enemyMovesView: some View {
        if !vm.rounds.isEmpty {
            MovesView(attacks: vm.currentRound.enemyAttacks,
                      defenses: vm.currentRound.enemyDefenses,
                      sourceType: .enemy)
            .frame(width: 100, height: 120)
            .padding(.trailing)
        }
    }

    @ViewBuilder var playerMovesView: some View {
        if !vm.rounds.isEmpty {
            MovesView(attacks: vm.currentRound.attacks,
                      defenses: vm.currentRound.defenses,
                      sourceType: .user,
                      attackSelected: { attack in
                vm.attackSelected(attack, isEnemy: false)
            }, defenseSelected: { defense in
                vm.defenseSelected(defense, isEnemy: false)
            })
        }
    }
}

#Preview {
    @State var path: NavigationPath = NavigationPath()

    return NavigationView {
        GameView(path: $path, vm: GameViewModel(isPracticeMode: true))
    }
}
