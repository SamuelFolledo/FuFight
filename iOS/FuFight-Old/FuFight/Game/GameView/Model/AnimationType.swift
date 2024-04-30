//
//  Animation.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/28/24.
//

import SwiftUI

enum AnimationType: String, CaseIterable {
    //MARK: Punches
    case punchHeadRightLight
    case punchHeadRightMedium
    case punchHeadRightHard
    case punchHeadLeftLight
    case punchHeadLeftMedium
    case punchHeadLeftHard

    //MARK: Defensive moves
    case dodgeHead
    case hitHead
    case killHead

    //MARK: Non attack or defensive moves
    case stop
    case idle
    case idleStand

    //MARK: - Properties

    ///name of the folder containing the animation name
    var subfolder: String {
        if let isHigh {
            return isHigh ? "head" : "body"
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
            "animations/idle/\(subfolder)/\(animationName)"
        case .stop:
            ""
        case .punchHeadRightLight, .punchHeadRightMedium, .punchHeadRightHard:
            "animations/punch/\(subfolder)/\(animationName)"
        case .punchHeadLeftLight, .punchHeadLeftMedium, .punchHeadLeftHard:
            //TODO: Needs to have a left medium and hard attack. Maybe flip/rotate other attacks?
            "animations/punch/\(AnimationType.punchHeadRightMedium.subfolder)/\(AnimationType.punchHeadRightMedium.animationName)"
        case .dodgeHead:
            "animations/dodge/\(subfolder)/\(animationName)"
        case .hitHead:
            "animations/hit/\(subfolder)/\(animationName)"
        case .killHead:
            "animations/kill/\(subfolder)/\(animationName)"
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

    ///the animation's total duration in seconds
    private var duration: CGFloat {
        switch self {
        case .idleStand:
            4.466670036315918
        case .idle, .stop:
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
        case .hitHead:
            0.9333329796791077
        case .dodgeHead:
            1.100000023841858
        case .killHead:
            2.5999999046325684
        }
    }

    ///the animation's duration when attack lands or when to play the defense animation in seconds
    private var hitDuration: CGFloat {
        //Note: these values are estimate and manually inputted after testing animations. The smaller the number, the more sooner the animation will get played
        switch self {
        //MARK: Idle moves
        case .idleStand, .idle, .stop:
            0
        //MARK: Defense moves
        case .hitHead:
            0.2 //0.9333329796791077
        case .dodgeHead:
            0.3 //1.100000023841858
        case .killHead:
            0.2 //2.5999999046325684
        //MARK: Attacks moves
        case .punchHeadLeftLight, .punchHeadLeftMedium, .punchHeadLeftHard:
            //TODO: Fix duration when left attacks is figured out
            0.45 //0.699999988079071
        case .punchHeadRightLight:
            0.4 //1.0666699409484863
        case .punchHeadRightMedium:
            0.8 //1.466670036315918
        case .punchHeadRightHard:
            0.9 //1.36667001247406
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

    var position: AttackPosition? {
        switch self {
        case .stop, .idle, .idleStand, .dodgeHead:
            nil
        case .hitHead:
            nil
        case .killHead:
            nil
        case .punchHeadRightLight:
            .rightLight
        case .punchHeadRightMedium:
            .rightMedium
        case .punchHeadRightHard:
            .rightHard
        case .punchHeadLeftLight:
            .leftLight
        case .punchHeadLeftMedium:
            .leftMedium
        case .punchHeadLeftHard:
            .leftHard
        }
    }

    //MARK: - Public Methods

    ///Returns the duration in seconds how long it takes for the current animation type to land based on the defender's animation
    ///Used to figure out the slight delay before playing the defender's animation
    func delayForDefendingAnimation(_ defenderAnimationType: AnimationType) -> CGFloat {
//        let didDodge = defenderAnimationType.position?.isLeft
        switch defenderAnimationType {
        case .stop, .idle, .idleStand:
            break
        case .dodgeHead, .hitHead, .killHead:
            //Defense moves
            let delay = hitDuration - defenderAnimationType.hitDuration
            return delay
        case .punchHeadRightLight, .punchHeadRightMedium, .punchHeadRightHard, .punchHeadLeftLight, .punchHeadLeftMedium, .punchHeadLeftHard:
            //Attack moves
            break
        }
        return 0
    }
}
