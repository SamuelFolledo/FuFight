//
//  Move.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/5/24.
//

import SwiftUI

protocol Move {
    var name: String { get }
    var id: String { get }
    var backgroundColor: Color { get }
    var imageName: String { get }
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
    ///The percentage amount of damage boost this move adds to attack's damage
    var damageMultiplier: Double { get }
    ///The percentage amount of speed boost this move adds to attack's speed
    var speedMultiplier: Double { get }
    ///The percentage amount of defense boost this move reduces from incoming damage
    var defenseMultiplier: Double { get }
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
        ""
//        switch self {
//        case .leftPunchLight:
//            <#code#>
//        case .leftPunchMedium:
//            <#code#>
//        case .leftPunchHard:
//            <#code#>
//        case .rightPunchLight:
//            <#code#>
//        case .rightPunchMedium:
//            <#code#>
//        case .rightPunchHard:
//            <#code#>
//        }
    }

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
}
