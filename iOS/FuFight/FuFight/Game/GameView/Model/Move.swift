//
//  Move.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/5/24.
//

import SwiftUI

enum MoveType {
    case attack
    case defend
}

protocol Move {
    var name: String { get }
    var id: String { get }
    var backgroundColor: Color { get }
    var imageName: String { get }
    var moveType: MoveType { get }
    var padding: Double { get }
}

protocol Attack: Move {
    ///The base damage of this attack
    var damage: Double { get }
    ///How fast this attack is and will determine who goes first
    var speed: Double { get }
    ///The percentage amount of damage reduction this attack will apply to the enemy. 0 will not reduce any attack, 1 will fully remove the damage of the next attack
    var damageReduction: Double { get }
}

protocol Defend: Move {
    ///The percentage amount of damage boost this move adds to attack's damage. 0 means no additional damage increase from this Defend move
    var damageMultiplier: Double { get }
    ///The percentage amount of speed boost this move adds to attack's speed. 0 means no additional speed increase
    var speedMultiplier: Double { get }
    ///The percentage amount of defense boost this move reduces from incoming damage. 0 means no additional damage reduction
    var defenseMultiplier: Double { get }
}

enum Dash: String, Defend {
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
}

enum Punch: String, Attack {
    case leftPunchLight
    case leftPunchMedium
    case leftPunchHard
    case rightPunchLight
    case rightPunchMedium
    case rightPunchHard

    var id: String {
        rawValue
    }

    var name: String {
        switch self {
        case .leftPunchLight:
            "Light Left Punch"
        case .leftPunchMedium:
            "Medium Left Punch"
        case .leftPunchHard:
            "Hard Left Punch"
        case .rightPunchLight:
            "Light Right Punch"
        case .rightPunchMedium:
            "Medium Right Punch"
        case .rightPunchHard:
            "Hard Right Punch"
        }
    }

    var backgroundColor: Color {
        Color.red
    }

    var imageName: String {
        switch self {
        case .leftPunchLight:
            "punchLeftLight"
        case .leftPunchMedium:
            "punchLeftMedium"
        case .leftPunchHard:
            "punchLeftHard"
        case .rightPunchLight:
            "punchRightLight"
        case .rightPunchMedium:
            "punchRightMedium"
        case .rightPunchHard:
            "punchRightHard"
        }
    }

    var moveType: MoveType { .attack }

    var damage: Double {
        switch self {
        case .leftPunchLight, .rightPunchLight:
            10
        case .leftPunchMedium, .rightPunchMedium:
            15
        case .leftPunchHard, .rightPunchHard:
            25
        }
    }

    var speed: Double {
        switch self {
        case .leftPunchLight, .rightPunchLight:
            50
        case .leftPunchMedium, .rightPunchMedium:
            35
        case .leftPunchHard, .rightPunchHard:
            25
        }
    }

    var damageReduction: Double {
        switch self {
        case .leftPunchLight, .rightPunchLight:
            0.15
        case .leftPunchMedium, .rightPunchMedium:
            0.25
        case .leftPunchHard, .rightPunchHard:
            0.35
        }
    }

    var padding: Double {
        switch self {
        case .leftPunchLight, .rightPunchLight:
            24
        case .leftPunchMedium, .rightPunchMedium:
            20
        case .leftPunchHard, .rightPunchHard:
            18
        }
    }
}
