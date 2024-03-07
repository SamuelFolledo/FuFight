//
//  Punch.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

enum Punch: String, CaseIterable, AttackProtocol {
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
}
