//
//  Dash.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

enum Dash: String, CaseIterable, DefendProtocol {
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
    var backgroundColor: Color {
        Color.blue
    }
    var imageName: String {
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
    var moveType: MoveType { .defend }

    var damageMultiplier: Double {
        switch self {
        case .forward:
            0.5
        case .left, .backward, .right:
            0
        }
    }
    var speedMultiplier: Double {
        switch self {
        case .left, .right:
            0
        case .forward:
            1.5
        case .backward:
            0.5
        }
    }
    var defenseMultiplier: Double {
        switch self {
        case .left, .right, .forward:
            0
        case .backward:
            0.4
        }
    }

    var padding: Double {
        switch self {
        case .left, .right:
            32
        case .forward, .backward:
            20
        }
    }

    var position: DefendPosition {
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
}
