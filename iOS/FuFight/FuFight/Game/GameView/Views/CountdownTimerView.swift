//
//  CountdownTimerView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/4/24.
//

import SwiftUI

struct CountdownTimerView: View {
    var timeRemaining: Int
    var round: Int

    var body: some View {
        Circle()
            .foregroundStyle(.clear)
            .background(
                timerBackgroundImage
                    .padding(.bottom, -40)
            )
            .overlay(
                VStack(spacing: 4) {
//                    AppText("\(String(format: "%.1f", timeRemaining))")
                    AppText("\(timeRemaining)", type: .titleLarge)

                    AppText("Round \(round)", type: .textLarge)
                }
                    .padding(.top, 30)
            )
    }
}

#Preview {
    return NavigationView {
        CountdownTimerView(timeRemaining: 5, round: 3)
    }
}
