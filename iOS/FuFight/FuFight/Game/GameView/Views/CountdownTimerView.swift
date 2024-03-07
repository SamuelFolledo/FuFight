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
                    Text("\(timeRemaining)")
                        .font(extramediumTitleFont)
                        .foregroundStyle(backgroundColor)

                    Text("Round \(round)")
                        .font(mediumTitleFont)
                        .foregroundStyle(backgroundColor)
                }
            )
    }
}

#Preview {
    return NavigationView {
        CountdownTimerView(timeRemaining: 5, round: 3)
    }
}
