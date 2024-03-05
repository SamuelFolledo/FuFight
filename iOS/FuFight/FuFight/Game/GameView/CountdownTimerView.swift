//
//  CountdownTimerView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/4/24.
//

import SwiftUI

struct CountdownTimerView: View {
    @Binding var timeRemaining: Int
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var isTimerActive = true
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        Text("\(timeRemaining)")
            .font(extraLargeTitleFont)
            .foregroundStyle(backgroundColor)
            .padding()
            .frame(width: 160, height: 160)
            .background(secondaryColor.opacity(0.75))
            .clipShape(.circle)
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
        CountdownTimerView(timeRemaining: $remain)
    }
}
