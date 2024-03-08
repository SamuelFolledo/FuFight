//
//  GameView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/4/24.
//

import SwiftUI

struct GameView: View {
    @Binding var path: NavigationPath
    @State var vm = GameViewModel()
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .trailing) {
                AccountHpView(player: vm.enemyPlayer, isEnemy: true)
                    .padding(.horizontal)

                enemyMovesPreview
            }

            Spacer()

            MovesView(attacks: $vm.currentPlayer.attacks, defenses: $vm.currentPlayer.defenses, sourceType: .user)

            AccountHpView(player: vm.currentPlayer)
                .padding(.horizontal)
                .padding(.top, 8)
        }
        .alert(title: vm.alertTitle,
               message: vm.alertMessage,
               isPresented: $vm.isAlertPresented)
        .alert(title: vm.currentPlayer.isDead ? "You lost" : "You won!",
               primaryButton: AlertButton(title: "Rematch", action: vm.rematch),
               secondaryButton: AlertButton(title: "Go home", action: { path.removeLast(path.count) }),
               isPresented: $vm.isGameOver)
        .overlay {
            timerView
        }
        .overlay {
            if let message = vm.loadingMessage {
                ProgressView(message)
            }
        }
        .background(
            gameBackgroundImage
                .padding(vm.isBackgroundLeadingPadding ? .leading : .trailing, vm.backgroundPadding)

        )
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
        CountdownTimerView(timeRemaining: vm.timeRemaining, round: vm.currentPlayer.turns.count)
            .frame(width: 160)
            .padding(.bottom, 400)
    }

    var enemyMovesPreview: some View {
        MovesView(attacks: $vm.enemyPlayer.attacks, defenses: $vm.enemyPlayer.defenses, sourceType: .enemy)
            .frame(width: 100, height: 120)
            .padding(.trailing)
    }
}

#Preview {
    @State var path: NavigationPath = NavigationPath()

    return NavigationView {
        GameView(path: $path)
    }
}
