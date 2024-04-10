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

    var animationType: FighterAnimationType {
        switch self {
        case .leftPunchLight:
                .punchHighLightLeft
        case .leftPunchMedium:
                .punchHighMediumLeft
        case .leftPunchHard:
                .punchHighHardLeft
        case .rightPunchLight:
                .punchHighLightRight
        case .rightPunchMedium:
                .punchHighMediumRight
        case .rightPunchHard:
                .punchHighHardRight
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
            0.15
        case .leftPunchMedium, .rightPunchMedium:
            0.25
        case .leftPunchHard, .rightPunchHard:
            0.35
        }
    }

    var position: AttackPosition {
        switch self {
        case .leftPunchLight:
                .leftLight
        case .leftPunchMedium:
                .leftMedium
        case .leftPunchHard:
                .leftHard
        case .rightPunchLight:
                .rightLight
        case .rightPunchMedium:
                .rightMedium
        case .rightPunchHard:
                .rightHard
        }
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
