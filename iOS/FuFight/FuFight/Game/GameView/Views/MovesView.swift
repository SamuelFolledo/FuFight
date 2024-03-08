//
//  MovesView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/7/24.
//

import SwiftUI

enum MovesViewType {
    ///Current user's MovesView
    case user
    ///Enemy's MovesView which is placed mirrored at the top
    case enemy
}

struct MovesView: View {
    var attacks: [Attack]
    var defenses: [Defend]
    var type: MovesViewType

    var body: some View {
        VStack {
            AttacksView(attacks: attacks, selectionHandler: {_ in }, isMini: type == .enemy)

            DefensesView(defenses: defenses, selectionHandler: {_ in }, isMini: type == .enemy)
        }
        .scaleEffect(x: type == .enemy ? -1 : 1, y: 1) // flip horizontally for enemyType
        .scaleEffect(x: 1, y: type == .enemy ? -1 : 1) // flip vertically if isTop
        .background(
            Group {
                if type == .enemy {
                    Color.systemGray
                } else {
                    Color.clear
                }
            }
                .cornerRadius(16)
                .opacity(0.5)
                .padding(.horizontal, 2)
                .padding(.vertical, -4)
        )
    }
}

#Preview {
    MovesView(attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses, type: .enemy)
}
