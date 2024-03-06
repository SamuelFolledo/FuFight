//
//  CountdownTimerView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/4/24.
//

import SwiftUI

struct CountdownTimerView: View {
    @Binding var timeRemaining: Int
    @Binding var isTimerActive: Bool
    @Binding var round: Int
    @Environment(\.scenePhase) var scenePhase

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Circle()
            .foregroundStyle(.clear)
            .background(
                timerBackgroundImage
                    .padding(.bottom, -40)
            )
            .overlay(
                VStack(spacing: 4) {
                    Text("\(timeRemaining)")
                        .font(extraLargeTitleFont)
                        .foregroundStyle(backgroundColor)

                    Text("Round \(round)")
                        .font(largeTitleFont)
                        .foregroundStyle(backgroundColor)
                }
            )
            .onChange(of: scenePhase) {
                switch scenePhase {
                case .background, .inactive:
                    LOGD("Scene phase is \(scenePhase)")
                    isTimerActive = false
                case .active:
                    isTimerActive = true
                @unknown default:
                    LOGDE("Unknown scene phase \(scenePhase)")
                }

                if scenePhase == .active {
                    isTimerActive = true
                } else {
                    isTimerActive = false
                }
            }
            .onReceive(timer) { time in
                guard isTimerActive else { return }
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    TODO("Analyze moves selected, then either go to next turn OR gameOver")
                    timeRemaining = defaultMaxTime
                }
            }
    }
}

#Preview {
    @State var remain = 5
    return NavigationView {
        CountdownTimerView(timeRemaining: $remain, isTimerActive: .constant(true), round: .constant(3))
    }
}
