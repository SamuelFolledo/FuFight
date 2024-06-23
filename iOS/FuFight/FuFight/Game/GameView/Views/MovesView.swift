//
//  MovesView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/7/24.
//

import SwiftUI

struct MovesView<AttacksView: View, DefensesView: View>: View {
    var attacksView: AttacksView
    var defensesView: DefensesView
    var playerType: PlayerType

    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = playerType.isEnemy ? 2 : 8
            VStack(spacing: spacing) {
                attacksView
                    .frame(height: abs(geometry.size.height * (3/5) - spacing))

                defensesView
                    .frame(height: abs(geometry.size.height * (2/5) - spacing))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .scaleEffect(x: playerType.shouldFlip ? -1 : 1, y: playerType.shouldFlip ? -1 : 1) // flip vertically and horizontally
            .background(
                playerType.background
                    .cornerRadius(16)
                    .opacity(0.5)
                    .padding(.horizontal, 2)
                    .padding(.vertical, -4)
            )
        }
    }
}

#Preview {
    let playerType: PlayerType = .user

    return MovesView(
        attacksView: AttacksView(attacks: defaultAllPunchAttacks, playerType: playerType, isEditing: false) {
            LOGD("Selected attack is \($0)")
        },
        defensesView: DefensesView(defenses: defaultAllDashDefenses, playerType: playerType) {
            LOGD("Selected defense is \($0)")
        },
        playerType: playerType)
}
