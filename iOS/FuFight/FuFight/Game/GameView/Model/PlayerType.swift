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

    var textType: TextType {
        switch self {
        case .user:
            TextType.titleLarge
        case .enemy:
            TextType.buttonMedium
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
