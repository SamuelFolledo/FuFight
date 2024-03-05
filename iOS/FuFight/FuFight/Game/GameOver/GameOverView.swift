//
//  GameOverView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/4/24.
//

import SwiftUI

struct GameOverView: View {
    @State var vm = GameOverViewModel()
    @Binding var path: NavigationPath

    var body: some View {
        VStack(spacing: 0) {

            VStack(spacing: 12) {
                Button("Go to home") {
                    path.removeLast(path.count)
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
        .navigationBarBackButtonHidden()
        .navigationTitle("Game Over")
    }
}

#Preview {
    @State var path: NavigationPath = NavigationPath()

    return NavigationView {
        GameOverView(path: $path)
    }
}
