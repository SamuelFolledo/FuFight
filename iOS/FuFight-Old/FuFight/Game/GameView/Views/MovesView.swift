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

struct MovesView: View {
    var attacks: [Attack]
    var defenses: [Defend]
    var sourceType: MovesViewSourceType
    var attackSelected: ((Attack) -> Void)?
    var defenseSelected: ((Defend) -> Void)?

    var body: some View {
        VStack {
            AttacksView(attacks: attacks, sourceType: sourceType) {
                attackSelected?($0)
            }

            DefensesView(defenses: defenses, sourceType: sourceType) {
                defenseSelected?($0)
            }
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
    MovesView(attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses, sourceType: .enemy)
}
