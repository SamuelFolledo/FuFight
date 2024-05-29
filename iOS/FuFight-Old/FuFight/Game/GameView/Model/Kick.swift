//
//  Kick.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/28/24.
//

import SwiftUI

enum Kick: String, CaseIterable, AttackTypeProtocol {
    case leftKickLight
    case leftKickMedium
    case leftKickHard
    case rightKickLight
    case rightKickMedium
    case rightKickHard
}

//MARK: - MoveProtocol extension
extension Kick {
    var id: String {
        rawValue
    }

    var name: String {
        animationType.rawValue
    }

    var iconName: String {
//        animationType.iconName ?? ""
        switch animationType {
        case .punchHeadLeftLight:
            "punchLeftLight"
        case .punchHeadLeftMedium:
            "punchLeftMedium"
        case .punchHeadLeftHard:
            "punchLeftHard"
        case .punchHeadRightLight:
            "punchRightLight"
        case .punchHeadRightMedium:
            "punchRightMedium"
        case .punchHeadRightHard:
            "punchRightHard"
        case .kickHeadLeftLight:
            "kickLeftLight"
        case .kickHeadLeftMedium:
            "kickLeftMedium"
        case .kickHeadLeftHard:
            "kickLeftHard"
        case .kickHeadRightLight:
            "kickRightLight"
        case .kickHeadRightMedium:
            "kickRightMedium"
        case .kickHeadRightHard:
            "kickRightHard"
        case .dodgeHeadRight, .dodgeHeadLeft, .hitHeadRightLight, .hitHeadRightMedium, .hitHeadRightHard, .hitHeadLeftLight, .hitHeadLeftMedium, .hitHeadLeftHard, .hitHeadStraightLight, .hitHeadStraightMedium, .hitHeadStraightHard, .killHeadRightLight, .killHeadRightMedium, .killHeadRightHard, .killHeadLeftLight, .killHeadLeftMedium, .killHeadLeftHard, .stop, .idle, .idleStand:
            ""
        }
    }

    var backgroundIconName: String {
        "moveBackgroundRed"
    }

    var padding: Double {
        switch self {
        case .leftKickLight, .rightKickLight:
            24
        case .leftKickMedium, .rightKickMedium:
            20
        case .leftKickHard, .rightKickHard:
            18
        }
    }

    var cooldown: Int {
        switch self {
        case .leftKickLight, .rightKickLight:
            1
        case .leftKickMedium, .rightKickMedium:
            2
        case .leftKickHard, .rightKickHard:
            3
        }
    }

    var animationType: AnimationType {
        switch self {
        case .leftKickLight:
            .kickHeadLeftLight
        case .leftKickMedium:
            .kickHeadLeftMedium
        case .leftKickHard:
            .kickHeadLeftHard
        case .rightKickLight:
            .kickHeadRightLight
        case .rightKickMedium:
            .kickHeadRightMedium
        case .rightKickHard:
            .kickHeadRightHard
        }
    }
}

//MARK: - AttackProtocol extension
extension Kick {
    var damage: Double {
        switch self {
        case .leftKickLight, .rightKickLight:
            10
        case .leftKickMedium, .rightKickMedium:
            15
        case .leftKickHard, .rightKickHard:
            25
        }
    }

    var speed: Double {
        switch self {
        case .leftKickLight, .rightKickLight:
            50
        case .leftKickMedium, .rightKickMedium:
            35
        case .leftKickHard, .rightKickHard:
            25
        }
    }

    var damageReduction: Double {
        switch self {
        case .leftKickLight, .rightKickLight:
            0.85
        case .leftKickMedium, .rightKickMedium:
            0.75
        case .leftKickHard, .rightKickHard:
            0.65
        }
    }

    var position: AttackPosition {
        switch self {
        case .leftKickLight:
                .leftLight
        case .leftKickMedium:
                .leftMedium
        case .leftKickHard:
                .leftHard
        case .rightKickLight:
                .rightLight
        case .rightKickMedium:
                .rightMedium
        case .rightKickHard:
                .rightHard
        }
    }

    var canBoost: Bool {
        switch self {
        case .leftKickLight, .rightKickLight, .leftKickMedium:
            true
        case .rightKickMedium, .leftKickHard, .rightKickHard:
            false
        }
    }

    var isAttack: Bool {
        true
    }
}

