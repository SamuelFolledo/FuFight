//
//  PlayerType.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/5/24.
//

import SwiftUI

enum PlayerType {
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
    var background: some View {
        switch self {
        case .user:
            Color.clear
        case .enemy:
            Color.systemGray
        }
    }
    var isEnemy: Bool {
        self == .enemy
    }
}
