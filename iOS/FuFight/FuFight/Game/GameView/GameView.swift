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
            AccountHpView(player: vm.enemyPlayer, isEnemy: true)
                .padding(.horizontal)

            Spacer()

            AttacksView(attacks: vm.currentPlayer.attacks, selectionHandler: vm.selectMove(_:))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 4)

            DefensesView(defenses: vm.currentPlayer.defenses, selectionHandler: vm.selectMove(_:))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 4)

            AccountHpView(player: vm.currentPlayer)
                .padding(.horizontal)
                .padding(.top, 8)
        }
        .alert(title: vm.alertTitle,
               message: vm.alertMessage,
               isPresented: $vm.isAlertPresented)
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
        .onChange(of: vm.isGameOver) {
            TODO("Show results in an alert with buttons to go back home")
            if vm.isGameOver {
                path.append(GameRoute.gameOver)
            }
        }
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
}

#Preview {
    @State var path: NavigationPath = NavigationPath()

    return NavigationView {
        GameView(path: $path)
    }
}
