//
//  Punch.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

enum Punch: String, CaseIterable {
    case leftPunchLight
    case leftPunchMedium
    case leftPunchHard
    case rightPunchLight
    case rightPunchMedium
    case rightPunchHard
}

//MARK: - MoveProtocol extension
extension Punch {
    var id: String {
        rawValue
    }

    var name: String {
        animationType.rawValue
    }

    var iconName: String {
        animationType.iconName ?? ""
    }

    var backgroundIconName: String {
        "moveBackgroundRed"
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

    var cooldown: Int {
        switch self {
        case .leftPunchLight, .rightPunchLight:
            1
        case .leftPunchMedium, .rightPunchMedium:
            2
        case .leftPunchHard, .rightPunchHard:
            3
        }
    }

    var animationType: AnimationType {
        switch self {
        case .leftPunchLight:
                .punchHeadLeftLight
        case .leftPunchMedium:
                .punchHeadLeftMedium
        case .leftPunchHard:
                .punchHeadLeftHard
        case .rightPunchLight:
                .punchHeadRightLight
        case .rightPunchMedium:
                .punchHeadRightMedium
        case .rightPunchHard:
                .punchHeadRightHard
        }
    }
}

//MARK: - AttackProtocol extension
extension Punch: AttackProtocol {
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
            0.85
        case .leftPunchMedium, .rightPunchMedium:
            0.75
        case .leftPunchHard, .rightPunchHard:
            0.65
        }
    }

    var position: AttackPosition? {
        animationType.position
    }

    var canBoost: Bool {
        switch self {
        case .leftPunchLight, .rightPunchLight, .rightPunchMedium:
            true
        case .leftPunchMedium, .leftPunchHard, .rightPunchHard:
            false
        }
    }
}
