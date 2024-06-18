//
//  GameView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/4/24.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var vm: GameViewModel
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .trailing) {
                createPlayerView(for: .enemy)

                createMovesView(for: .enemy)
            }

            Spacer()

            createMovesView(for: .user)
                .allowsHitTesting(vm.loadingMessage == nil)
                .allowsHitTesting(!vm.isBuffering)
                .opacity(vm.isBuffering ? 0.4 : 1)

            createPlayerView(for: .user)
        }
        .background {
            GameSceneView(fighter: vm.player.fighter, enemyFighter: vm.enemy.fighter, isPracticeMode: vm.gameMode == .practice)
                .ignoresSafeArea()
        }
        .alert(title: vm.alertTitle,
               message: vm.alertMessage,
               isPresented: $vm.isAlertPresented)
        .alert(title: vm.player.isDead ? "You lost" : "You won!",
               primaryButton: AlertButton(title: "Rematch", action: vm.rematch),
               secondaryButton: AlertButton(title: "Go home", action: vm.exitGame),
               isPresented: .constant(vm.player.isDead || vm.enemy.isDead))
        .alert(title: "You won!",
               message: "Congrats! Enemy rage quitted",
               primaryButton: AlertButton(title: "Go home", action: vm.exitGame),
               isPresented: $vm.enemyExited)
        .alert(title: "Game is paused",
               primaryButton: AlertButton(title: "Resume", action: {}),
               secondaryButton: AlertButton(title: "Exit", action: vm.exitGame),
               isPresented: $vm.isGamePaused)
        .overlay {
            timerView
        }
        .overlay {
            LoadingView(message: vm.loadingMessage)
        }
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
        .navigationBarBackButtonHidden()
        .onChange(of: scenePhase) {
            vm.scenePhaseChangedHandler(scenePhase)
        }
        .onReceive(vm.timer) { time in
            vm.decrementTimeByOneSecond()
        }
        .toolbar(.hidden, for: .tabBar)
        .task {
            //Must be started here in order to avoid duplicated calls on createNewRound()
            vm.updateState(.starting)
        }
    }

    var timerView: some View {
        CountdownTimerView(timeRemaining: vm.timeRemaining, round: vm.player.rounds.count)
            .frame(width: 160)
            .padding(.bottom, 400)
    }

    ///Returns the player's view including player's name, photo, and HP, and damages
    @ViewBuilder func createPlayerView(for playerType: PlayerType) -> some View {
        let player = playerType.isEnemy ? vm.enemy : vm.player
        let enemyPlayer = playerType.isEnemy ? vm.player : vm.enemy
        PlayerView(player: player,
                   enemyDamagesList: DamagesListView(enemyRounds: enemyPlayer.rounds, isPlayerDead: player.isDead),
                   onImageTappedAction: {
            if playerType == .user {
                vm.isGamePaused = true
            }
        })
        .padding(.horizontal)
        .padding(.top, playerType.isEnemy ? 0 : 8)
    }

    ///Returns the attacks and defenses view for a player
    ///Note: For some reason attacks and defenses view is required to be inside an @ViewBuilder function to refresh its state and fire state
    @ViewBuilder func createMovesView(for playerType: PlayerType) -> some View {
        let player = playerType.isEnemy ? vm.enemy : vm.player
        MovesView(
            attacksView: AttacksView(attacks: player.moves.attacks, playerType: playerType, isEditing: false) {
                vm.attackSelected($0, isEnemy: playerType.isEnemy)
            },
            defensesView: DefensesView(defenses: player.moves.defenses, playerType: playerType) {
                vm.defenseSelected($0, isEnemy: playerType.isEnemy)
            },
            playerType: playerType)
        .frame(width: playerType.isEnemy ? 100 : nil, height: playerType.isEnemy ? 120 : nil)
        .padding(playerType.isEnemy ? [.trailing] : [])
    }
}

#Preview {
    NavigationView {
        GameView(vm: GameViewModel(player: fakePlayer, enemy: fakeEnemyPlayer, gameMode: .offlineGame))
    }
}
