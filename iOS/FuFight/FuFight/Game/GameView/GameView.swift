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

    var body: some View {
        VStack(spacing: 0) {
            AccountHpView(player: vm.enemyPlayer, isEnemy: true)
                .padding(.horizontal)
                .padding(.bottom, 30)

            Button("Attack player") {
                vm.attack(damage: 10, toEnemy: false)
            }

            Spacer()

            Button("Attack enemy") {
                vm.attack(damage: 10, toEnemy: true)
            }

            AccountHpView(player: vm.accountPlayer)
                .padding(.horizontal)
                .padding(.top, 30)
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
            Image("gameBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
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
    }

    var timerView: some View {
        VStack {
            Text("Round \(vm.round)")
                .font(largeTitleFont)
                .foregroundStyle(secondaryColor)

            CountdownTimerView(timeRemaining: $vm.timeRemaining, isTimerActive: $vm.isTimerActive)
        }
        .padding(.bottom, 200)
    }
}

#Preview {
    @State var path: NavigationPath = NavigationPath()

    return NavigationView {
        GameView(path: $path)
    }
}
