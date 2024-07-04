//
//  Dash.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

enum Dash: String, CaseIterable, DefenseTypeProtocol {
    case left
    case forward
    case backward
    case right

    var name: String {
        switch self {
        case .left:
            "Dash Left"
        case .forward:
            "Dash Forward"
        case .backward:
            "Dash Backward"
        case .right:
            "Dash Right"
        }
    }
    var id: String { rawValue }
    var iconName: String {
        switch self {
        case .left:
            "defendLeft"
        case .forward:
            "defendForward"
        case .backward:
            "defendBack"
        case .right:
            "defendRight"
        }
    }

    var backgroundIconName: String {
        "moveBackgroundBlue"
    }

    var damageMultiplier: Double {
        switch self {
        case .forward:
            1.35
        case .left, .backward, .right:
            1
        }
    }
    var speedMultiplier: Double {
        switch self {
        case .left, .right:
            1
        case .forward:
            1.5
        case .backward:
            0.5
        }
    }
    var incomingDamageMultiplier: Double {
        switch self {
        case .forward:
            1.1
        case .left, .right:
            1
        case .backward:
            0.6
        }
    }

    var padding: Double {
        switch self {
        case .left, .right:
            20
        case .forward, .backward:
            20
        }
    }

    var position: DefensePosition {
        switch self {
        case .left:
                .left
        case .forward:
                .forward
        case .backward:
                .backward
        case .right:
                .right
        }
    }

    var cooldown: Int {
        1
    }

    var animationType: AnimationType {
        switch self {
        case .forward:
            .idleStand
        case .backward:
            .idleStand
        case .left:
            .idleFight
        case .right:
            .idleFight
        }
    }

    var isAttack: Bool { return false }
}
