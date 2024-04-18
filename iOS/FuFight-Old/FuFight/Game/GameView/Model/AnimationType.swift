//
//  Animation.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/28/24.
//

import SwiftUI

enum AnimationType: String, CaseIterable {
    case stop
    //    case deathBackLight
    //    case deathBackMedium
    //    case deathUpHard
    //    case dodgeRight
    //    case dodgeUp
    //    case hitBodyHard
    //    case hitBodyMedium
    //    case hitHeadHard
    //    case hitHeadMedium
    case idle
    case idleStand
    case dodgeHead
//    case dodgeBody
    case hitHead
//    case hitHeadHard
//    case hitBody
//    case hitBodyHard
    case killHead
//    case killHeadHard
//    case killBody
//    case idleTired
    //    case kickFlying
    //    case kickMMA
    //    case kickDownHard
    //    case kickDownMedium
    //    case kickDownLight
    //    case kickUpHard
    //    case kickUpMedium
    //    case kickUpLight
    case punchHeadRightLight
    case punchHeadRightMedium
    case punchHeadRightHard
    case punchHeadLeftLight
    case punchHeadLeftMedium
    case punchHeadLeftHard
    //    case dashForward
    //    case dashBackward

    ///name of the folder containing the animation name
    var subfolder: String {
        if let isHigh {
            return isHigh ? "head/" : "body/"
        }
        return ""
    }

    ///Determines if animation type aims the head or body, nil means no body or head specific
    var isHigh: Bool? {
        switch self {
        case .stop, .idle, .idleStand:
            nil
        case .dodgeHead, .hitHead, .killHead, .punchHeadRightLight, .punchHeadRightMedium, .punchHeadRightHard, .punchHeadLeftLight, .punchHeadLeftMedium, .punchHeadLeftHard:
            true
        }
    }

    var animationName: String {
        switch self {
        case .stop:
            ""
        case .idle, .idleStand:
            rawValue
        case .dodgeHead:
            "light"
        case .hitHead:
            "light"
        case .killHead:
            "light"
        case .punchHeadRightLight:
            "rightLight"
        case .punchHeadRightMedium:
            "rightMedium"
        case .punchHeadRightHard:
            "rightHard"
        case .punchHeadLeftLight:
            "leftLight"
        case .punchHeadLeftMedium:
            //TODO: Figure out what to do with left attacks, maybe rotate?
//            "leftMedium"
            "leftLight"
        case .punchHeadLeftHard:
//            "leftHard"
            "leftLight"
        }
    }

    var animationPath: String {
        switch self {
        case .idle, .idleStand:
            "animations/idle/\(subfolder)\(animationName)"
        case .stop:
            ""
        case .punchHeadRightLight, .punchHeadRightMedium, .punchHeadRightHard, .punchHeadLeftLight:
            "animations/punch/\(subfolder)\(animationName)"
        case .punchHeadLeftMedium, .punchHeadLeftHard:
            //TODO: Needs to have a left medium and hard attack. Maybe flip/rotate other attacks?
            "animations/punch/\(subfolder)\(animationName)"
        case .dodgeHead:
            "animations/dodge/\(subfolder)\(animationName)"
        case .hitHead:
            "animations/hit/\(subfolder)\(animationName)"
        case .killHead:
            "animations/kill/\(subfolder)\(animationName)"
        }
    }

    var isRemovedFromCompletion: Bool { false }
    var fadeInDuration: CGFloat { 0.2 }
    var fadeOutDuration: CGFloat { 0.2 }
    var usesSceneTimeBase: Bool { false }
    ///how many times the animation will be repeated
    var repeatCount: Float {
        switch self {
        case .idle, .idleStand, .stop:
            0
        case .punchHeadRightLight, .punchHeadRightMedium, .punchHeadRightHard, .punchHeadLeftLight, .punchHeadLeftMedium, .punchHeadLeftHard, .dodgeHead, .hitHead, .killHead:
            1
        }
    }

    ///returns how long a single animation takes
    var animationDuration: TimeInterval {
        let startTime = TimeInterval(0)
        let endTime = TimeInterval(duration)
        return endTime - startTime
    }

    ///duration in seconds
    private var duration: CGFloat {
        switch self {
        case .idleStand:
            4.466670036315918
//        case .idleTired:
//            3.6333301067352295
        case .idle, .stop, .dodgeHead, .hitHead, .killHead:
            0
        case .punchHeadLeftLight, .punchHeadLeftMedium, .punchHeadLeftHard:
            //TODO: Fix duration when left attacks is figured out
            0.699999988079071
        case .punchHeadRightLight:
            1.0666699409484863
        case .punchHeadRightMedium:
            1.466670036315918
        case .punchHeadRightHard:
            1.36667001247406
        }
    }

    var iconName: String? {
        switch self {
        case .stop, .idle, .idleStand, .dodgeHead, .hitHead, .killHead:
            //TODO: Make defense move's source for icon like Punch
            nil
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
        }
    }
}
