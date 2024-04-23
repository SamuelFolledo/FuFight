//
//  MovesView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/7/24.
//

import SwiftUI

enum MovesViewSourceType {
    ///Current user's MovesView
    case user
    ///Enemy's MovesView which is mini and mirrored at the top
    case enemy

    var font: Font {
        switch self {
        case .user:
            largeTitleFont
        case .enemy:
            smallTitleFont
        }
    }
    var angle: Angle {
        switch self {
        case .user:
                .radians(.zero)
        case .enemy:
                .radians(.pi)
        }
    }
    var shouldFlip: Bool {
        switch self {
        case .user:
            false
        case .enemy:
            true
        }
    }
}

struct MovesView<AttacksView: View, DefensesView: View>: View {
    var attacksView: AttacksView
    var defensesView: DefensesView
    var sourceType: MovesViewSourceType

    var body: some View {
        VStack {
            attacksView

            defensesView
        }
        .scaleEffect(x: sourceType.shouldFlip ? -1 : 1, y: sourceType.shouldFlip ? -1 : 1) // flip vertically and horizontally
        .background(
            Group {
                switch sourceType {
                case .user:
                    Color.clear
                case .enemy:
                    Color.systemGray
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
    MovesView(
        attacksView: AttacksView(
            attacks: defaultAllPunchAttacks,
            sourceType: .enemy) { move in
                LOGD("MovesView Attack is selected \(move.name)")
            },
        defensesView: DefensesView(
            defenses: defaultAllDashDefenses,
            sourceType: .enemy) { move in
                LOGD("MovesView Defense is selected \(move.name)")
            },
        sourceType: .enemy)
}
