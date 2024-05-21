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

            createPlayerView(for: .user)
        }
        .background {
            if let enemyPlayer = vm.enemyPlayer {
                GameSceneView(fighter: vm.player.fighter, enemyFighter: enemyPlayer.fighter, isPracticeMode: vm.isPracticeMode)
                    .ignoresSafeArea()
            }
        }
        .alert(title: vm.alertTitle,
               message: vm.alertMessage,
               isPresented: $vm.isAlertPresented)
        .alert(title: vm.player.isDead ? "You lost" : "You won!",
               primaryButton: AlertButton(title: "Rematch", action: vm.rematch),
               secondaryButton: AlertButton(title: "Go home", action: transitionBackToHome),
               isPresented: .constant(vm.state == .gameOver))
        .alert(title: "Game is paused",
               primaryButton: AlertButton(title: "Resume", action: {}),
               secondaryButton: AlertButton(title: "Exit", action: transitionBackToHome),
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
        .allowsHitTesting(vm.loadingMessage == nil)
        .navigationBarBackButtonHidden()
        .onChange(of: scenePhase) {
            vm.scenePhaseChangedHandler(scenePhase)
        }
        .onReceive(vm.timer) { time in
            vm.decrementTimeByOneSecond()
        }
        .toolbar(.hidden, for: .tabBar)
    }

    var timerView: some View {
        CountdownTimerView(timeRemaining: vm.timeRemaining, round: vm.player.rounds.count)
            .frame(width: 160)
            .padding(.bottom, 400)
    }

    ///Returns the player's view including player's name, photo, and HP, and damages
    @ViewBuilder func createPlayerView(for playerType: PlayerType) -> some View {
        if let enemy = vm.enemyPlayer {
            let player = playerType.isEnemy ? enemy : vm.player
            let enemyPlayer = playerType.isEnemy ? vm.player : enemy
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
    }

    ///Returns the attacks and defenses view for a player
    ///Note: For some reason attacks and defenses view is required to be inside an @ViewBuilder function to refresh its state and fire state
    @ViewBuilder func createMovesView(for playerType: PlayerType) -> some View {
        if let enemy = vm.enemyPlayer {
            let player = playerType.isEnemy ? enemy : vm.player
            MovesView(
                attacksView: AttacksView(attacks: player.moves.attacks, playerType: playerType) {
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
}

private extension GameView {
    func transitionBackToHome() {
        vm.didExitGame.send(vm)
        Task {
            do {
                TODO("todo only delete lobby and game if player is owner")
                try await GameNetworkManager.deleteCurrentLobby(lobbyId: vm.player.userId)
                try await GameNetworkManager.deleteGame(vm.player.userId)
            }
        }
    }
}

#Preview {
    NavigationView {
        GameView(vm: GameViewModel(isPracticeMode: true, player: fakePlayer, enemyPlayer: fakeEnemyPlayer))
    }
}
