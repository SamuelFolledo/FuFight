//
//  DamagesListView.swift
//  FuFight
//
//  Created by Samuel Folledo on 4/29/24.
//

import SwiftUI

struct DamagesListView: View {
    var enemyRounds: [Round]
    var isPlayerDead: Bool

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                let rounds = isPlayerDead ? enemyRounds.reversed() : enemyRounds.dropLast().reversed()
                ForEach(Array(zip(rounds.indices, rounds)), id: \.1) { index, round in
                    Group {
                        HStack(spacing: 2) {
                            Text("Round \(rounds[index].round):")

                            Text("\(rounds[index].resultValue)")

                            if round.round != 1 {
                                Text(",")
                            }
                        }
                        .foregroundStyle(rounds[index].attackResult?.damageTextColor ?? Color.white)
                    }
                    .font(mediumTextFont)
                }
            }
        }
    }
}
