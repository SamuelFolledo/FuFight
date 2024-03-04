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

            VStack(spacing: 12) {
                Button {
                    path.append(GameRoute.gameOver)
                } label: {
                    Text("Game over")
                }
            }
        }
        .alert(title: vm.alertTitle,
               message: vm.alertMessage,
               isPresented: $vm.isAlertPresented)
        .padding(.horizontal, horizontalPadding)
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
        .navigationTitle("Game View")
    }
}

#Preview {
    @State var path: NavigationPath = NavigationPath()

    return NavigationView {
        GameView(path: $path)
    }
}
