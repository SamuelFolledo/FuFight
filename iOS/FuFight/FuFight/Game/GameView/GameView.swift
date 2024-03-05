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

            Spacer()

            Button("Attack player") {
                vm.attack(damage: 10, toEnemy: false)
            }

            Spacer()
            
            Button("Attack enemy") {
                vm.attack(damage: 10, toEnemy: true)
            }

            Spacer()

            AccountHpView(player: vm.accountPlayer)
                .padding(.horizontal)
        }
        .alert(title: vm.alertTitle,
               message: vm.alertMessage,
               isPresented: $vm.isAlertPresented)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: vm.isGameOver) {
            if vm.isGameOver {
                path.append(GameRoute.gameOver)
            }
        }
    }
}

#Preview {
    @State var path: NavigationPath = NavigationPath()

    return NavigationView {
        GameView(path: $path)
    }
}
