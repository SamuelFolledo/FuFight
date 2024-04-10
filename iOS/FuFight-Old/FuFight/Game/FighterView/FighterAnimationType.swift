//
//  Animation.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/28/24.
//

import SwiftUI

enum FighterAnimationType: String, CaseIterable {
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
//    case idleTired
    //    case kickFlying
    //    case kickMMA
    //    case kickDownHard
    //    case kickDownMedium
    //    case kickDownLight
    //    case kickUpHard
    //    case kickUpMedium
    //    case kickUpLight
    case punchHighLightRight
    case punchHighMediumRight
    case punchHighHardRight
    case punchHighLightLeft
    case punchHighMediumLeft
    case punchHighHardLeft
    //    case dashForward
    //    case dashBackward

    var animationPath: String {
        switch self {
        case .idle, .idleStand:
            "animations/idle/\(rawValue)"
        case .stop:
            ""
        case .punchHighLightRight, .punchHighMediumRight, .punchHighHardRight, .punchHighLightLeft:
            "animations/punch/high/\(rawValue)"
        case .punchHighMediumLeft, .punchHighHardLeft:
            //TODO: Needs to have a left medium and hard attack. Maybe flip/rotate other attacks?
            "animations/punch/high/\(FighterAnimationType.punchHighLightLeft.rawValue)"
        }
    }

    var isRemovedFromCompletion: Bool {
        switch self {
        case .idle, .idleStand, .stop:
            false
        case .punchHighLightRight, .punchHighMediumRight, .punchHighHardRight, .punchHighLightLeft, .punchHighMediumLeft, .punchHighHardLeft:
            false
        }
    }

    var fadeInDuration: CGFloat { 0.2 }
    var fadeOutDuration: CGFloat { 0.2 }
    var usesSceneTimeBase: Bool { false }
    ///how many times the animation will be repeated
    var repeatCount: Float {
        switch self {
        case .idle, .idleStand, .stop:
            0
        case .punchHighLightRight, .punchHighMediumRight, .punchHighHardRight, .punchHighLightLeft, .punchHighMediumLeft, .punchHighHardLeft:
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
        case .idle, .stop:
            0
        case .punchHighLightLeft, .punchHighMediumLeft, .punchHighHardLeft:
            //TODO: Fix duration when left attacks is figured out
            0.699999988079071
        case .punchHighLightRight:
            1.0666699409484863
        case .punchHighMediumRight:
            1.466670036315918
        case .punchHighHardRight:
            1.36667001247406
        }
    }

    var iconName: String? {
        switch self {
        case .stop, .idle, .idleStand:
            //TODO: Make defense move's source for icon like Punch
            nil
        case .punchHighLightLeft:
            "punchLeftLight"
        case .punchHighMediumLeft:
            "punchLeftMedium"
        case .punchHighHardLeft:
            "punchLeftHard"
        case .punchHighLightRight:
            "punchRightLight"
        case .punchHighMediumRight:
            "punchRightMedium"
        case .punchHighHardRight:
            "punchRightHard"
        }
    }
}
