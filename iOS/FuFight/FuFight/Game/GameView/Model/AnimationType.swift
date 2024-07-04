//
//  Animation.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/28/24.
//

import SwiftUI

enum StrengthType: String {
    case light, medium, hard
}

enum AnimationType: String, CaseIterable {
    //MARK: Punches
    case punchHeadRightLight
    case punchHeadRightMedium
    case punchHeadRightHard
    case punchHeadLeftLight
    case punchHeadLeftMedium
    case punchHeadLeftHard

    //MARK: Kicks
    case kickHeadRightLight
    case kickHeadRightMedium
    case kickHeadRightHard
    case kickHeadLeftLight
    case kickHeadLeftMedium
    case kickHeadLeftHard

    //MARK: Defensive moves
    case dodgeHeadRight
    case dodgeHeadLeft

    case hitHeadRightLight
    case hitHeadRightMedium
    case hitHeadRightHard
    case hitHeadLeftLight
    case hitHeadLeftMedium
    case hitHeadLeftHard
    case hitHeadStraightLight
    case hitHeadStraightMedium
    case hitHeadStraightHard

    case killHeadRightLight
    case killHeadRightMedium
    case killHeadRightHard
    case killHeadLeftLight
    case killHeadLeftMedium
    case killHeadLeftHard

    //MARK: Non attack or defensive moves
    case stop
    case idleFight
    case idleStand

    //MARK: - Properties
    var animationName: String {
        switch self {
        case .punchHeadRightLight, .punchHeadLeftLight, .kickHeadRightLight, .kickHeadLeftLight, .hitHeadRightLight, .hitHeadLeftLight, .hitHeadStraightLight, .killHeadRightLight, .killHeadLeftLight:
            "light\(nameSuffix)"
        case .punchHeadRightMedium, .punchHeadLeftMedium, .kickHeadRightMedium, .kickHeadLeftMedium, .hitHeadRightMedium, .hitHeadLeftMedium, .hitHeadStraightMedium, .killHeadRightMedium, .killHeadLeftMedium:
            "medium\(nameSuffix)"
        case .punchHeadRightHard, .punchHeadLeftHard, .kickHeadRightHard, .kickHeadLeftHard, .hitHeadRightHard, .hitHeadLeftHard, .hitHeadStraightHard, .killHeadRightHard, .killHeadLeftHard:
            "hard\(nameSuffix)"
        case .dodgeHeadRight, .dodgeHeadLeft:
            "dodge\(nameSuffix)"
        case .stop:
            ""
        case .idleFight, .idleStand:
            "idle\(nameSuffix)"
        }
    }

    var nameSuffix: String {
        switch self {
        case .punchHeadRightLight:
            ""
        case .punchHeadRightMedium:
            ""
        case .punchHeadRightHard:
            ""
        case .punchHeadLeftLight, .punchHeadLeftMedium, .punchHeadLeftHard:
            "-m"
        case .kickHeadRightLight:
            ""
        case .kickHeadRightMedium:
            ""
        case .kickHeadRightHard:
            ""
        case .kickHeadLeftLight, .kickHeadLeftMedium, .kickHeadLeftHard:
            "-m"
        case .dodgeHeadRight:
            ""
        case .dodgeHeadLeft:
            "-m"
        case .hitHeadRightLight, .hitHeadRightMedium, .hitHeadRightHard:
            "Right"
        case .hitHeadLeftLight, .hitHeadLeftMedium, .hitHeadLeftHard:
            "Left"
        case .hitHeadStraightLight, .hitHeadStraightMedium, .hitHeadStraightHard:
            "Straight"
        case .killHeadRightLight:
            ""
        case .killHeadRightMedium:
            ""
        case .killHeadRightHard:
            ""
        case .killHeadLeftLight, .killHeadLeftMedium, .killHeadLeftHard:
            "-m"
        case .stop:
            ""
        case .idleFight:
            "Fight"
        case .idleStand:
            "Stand"
        }
    }

    var animationPath: String {
        "animations\(folder)\(subfolder)/\(animationName)"
    }

    var folder: String {
        switch self {
        case .punchHeadRightLight, .punchHeadRightMedium, .punchHeadRightHard, .punchHeadLeftLight, .punchHeadLeftMedium, .punchHeadLeftHard:
            "/punch"
        case .kickHeadRightLight, .kickHeadRightMedium, .kickHeadRightHard, .kickHeadLeftLight, .kickHeadLeftMedium, .kickHeadLeftHard:
            //TODO: Change to Kick
            "/punch"
        case .dodgeHeadRight, .dodgeHeadLeft:
            "/dodge"
        case .hitHeadRightMedium, .hitHeadRightHard, .hitHeadRightLight, .hitHeadLeftLight, .hitHeadLeftMedium, .hitHeadLeftHard, .hitHeadStraightLight, .hitHeadStraightMedium, .hitHeadStraightHard:
            "/hit"
        case .killHeadRightLight, .killHeadRightMedium, .killHeadRightHard, .killHeadLeftLight, .killHeadLeftMedium, .killHeadLeftHard:
            "/kill"
        case .stop:
            ""
        case .idleFight, .idleStand:
            "/idle"
        }
    }
    var subfolder: String {
        if let isHigh {
            return isHigh ? "/head" : "/body"
        }
        return ""
    }

    ///Determines if animation type aims the head or body, nil means no body or head specific
    var isHigh: Bool? {
        switch self {
        case .stop, .idleFight, .idleStand:
            nil
        case .dodgeHeadLeft, .dodgeHeadRight, .hitHeadRightLight, .hitHeadLeftLight, .hitHeadStraightLight, .hitHeadRightMedium, .hitHeadLeftMedium, .hitHeadStraightMedium, .hitHeadRightHard, .hitHeadLeftHard, .hitHeadStraightHard, .killHeadRightLight, .killHeadLeftLight, .killHeadRightMedium, .killHeadLeftMedium, .killHeadRightHard, .killHeadLeftHard, .punchHeadRightLight, .punchHeadRightMedium, .punchHeadRightHard, .punchHeadLeftLight, .punchHeadLeftMedium, .punchHeadLeftHard, .kickHeadRightLight, .kickHeadRightMedium, .kickHeadRightHard, .kickHeadLeftLight, .kickHeadLeftMedium, .kickHeadLeftHard:
            true
        }
    }

    ///If this animation has a mirrored version denoted with -m on the .dae file. Mirrored animations were used for the left animations
//    var hasMirroredVersion: Bool {
//        switch self {
//        case .hitHeadRightLight, .hitHeadLeftLight, .hitHeadStraightLight, .hitHeadRightMedium, .hitHeadLeftMedium, .hitHeadStraightMedium, .hitHeadRightHard, .hitHeadLeftHard, .hitHeadStraightHard:
//            true
//        case .punchHeadRightLight, .punchHeadRightMedium, .punchHeadRightHard, .punchHeadLeftLight, .punchHeadLeftMedium, .punchHeadLeftHard, .dodgeHeadRight, .dodgeHeadLeft, .killHeadRightLight, .killHeadRightMedium, .killHeadRightHard, .killHeadLeftLight, .killHeadLeftMedium, .killHeadLeftHard, .stop, .idle, .idleStand:
//            false
//        }
//    }

    var isRemovedFromCompletion: Bool { false }
    var fadeInDuration: CGFloat { 0.2 }
    var fadeOutDuration: CGFloat { 0.2 }
    var usesSceneTimeBase: Bool { false }
    ///how many times the animation will be repeated
    var repeatCount: Float {
        switch self {
        case .idleFight, .idleStand:
            .greatestFiniteMagnitude
        case .stop:
            0
        case .dodgeHeadLeft, .dodgeHeadRight, .hitHeadRightLight, .hitHeadLeftLight, .hitHeadStraightLight, .hitHeadRightMedium, .hitHeadLeftMedium, .hitHeadStraightMedium, .hitHeadRightHard, .hitHeadLeftHard, .hitHeadStraightHard, .killHeadRightLight, .killHeadLeftLight, .killHeadRightMedium, .killHeadLeftMedium, .killHeadRightHard, .killHeadLeftHard, .punchHeadRightLight, .punchHeadRightMedium, .punchHeadRightHard, .punchHeadLeftLight, .punchHeadLeftMedium, .punchHeadLeftHard, .kickHeadRightLight, .kickHeadRightMedium, .kickHeadRightHard, .kickHeadLeftLight, .kickHeadLeftMedium, .kickHeadLeftHard:
            1
        }
    }

    var iconName: String? {
        switch self {
        case .stop, .idleFight, .idleStand, .dodgeHeadLeft, .dodgeHeadRight, .hitHeadRightLight, .hitHeadLeftLight, .hitHeadStraightLight, .hitHeadRightMedium, .hitHeadLeftMedium, .hitHeadStraightMedium, .hitHeadRightHard, .hitHeadLeftHard, .hitHeadStraightHard, .killHeadRightLight, .killHeadLeftLight, .killHeadRightMedium, .killHeadLeftMedium, .killHeadRightHard, .killHeadLeftHard:
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
        }
    }

    var isKillAnimationType: Bool {
        switch self {
        case .killHeadRightLight, .killHeadLeftLight, .killHeadRightMedium, .killHeadLeftMedium, .killHeadRightHard, .killHeadLeftHard:
            true
        case .stop, .idleFight, .idleStand, .dodgeHeadLeft, .dodgeHeadRight, .hitHeadRightLight, .hitHeadLeftLight, .hitHeadStraightLight, .hitHeadRightMedium, .hitHeadLeftMedium, .hitHeadStraightMedium, .hitHeadRightHard, .hitHeadLeftHard, .hitHeadStraightHard, .punchHeadLeftLight, .punchHeadLeftMedium, .punchHeadLeftHard, .punchHeadRightLight, .punchHeadRightMedium, .punchHeadRightHard, .kickHeadRightLight, .kickHeadRightMedium, .kickHeadRightHard, .kickHeadLeftLight, .kickHeadLeftMedium, .kickHeadLeftHard:
            false
        }
    }

    ///Direction to attack to, and dodge, hit, or kill from
    var isRight: Bool {
        switch self {
        case .punchHeadRightLight, .punchHeadRightMedium, .punchHeadRightHard:
            true
        case .punchHeadLeftLight, .punchHeadLeftMedium, .punchHeadLeftHard:
            false
        case .kickHeadRightLight, .kickHeadRightMedium, .kickHeadRightHard:
            true
        case .kickHeadLeftLight, .kickHeadLeftMedium, .kickHeadLeftHard:
            false
        case .dodgeHeadRight:
            true
        case .dodgeHeadLeft:
            false
        case .hitHeadRightLight, .hitHeadRightMedium, .hitHeadRightHard:
            true
        case .hitHeadLeftLight, .hitHeadLeftMedium, .hitHeadLeftHard, .hitHeadStraightLight, .hitHeadStraightMedium, .hitHeadStraightHard:
            false
        case .killHeadRightLight, .killHeadRightMedium, .killHeadRightHard:
            true
        case .killHeadLeftLight, .killHeadLeftMedium, .killHeadLeftHard, .stop, .idleFight, .idleStand:
            false
        }
    }

    var strength: StrengthType? {
        switch self {
        case .punchHeadRightLight, .punchHeadLeftLight, .kickHeadLeftLight, .kickHeadRightLight, .hitHeadRightLight, .hitHeadLeftLight, .hitHeadStraightLight, .killHeadRightLight, .killHeadLeftLight:
            .light
        case .punchHeadRightMedium, .punchHeadLeftMedium, .kickHeadLeftMedium, .kickHeadRightMedium, .hitHeadRightMedium, .hitHeadLeftMedium, .hitHeadStraightMedium, .killHeadRightMedium, .killHeadLeftMedium:
            .medium
        case .punchHeadRightHard, .punchHeadLeftHard, .kickHeadLeftHard, .kickHeadRightHard, .hitHeadRightHard, .hitHeadLeftHard, .hitHeadStraightHard, .killHeadRightHard, .killHeadLeftHard:
            .hard
        case .dodgeHeadRight, .dodgeHeadLeft, .stop, .idleFight, .idleStand:
            nil
        }
    }

//    var position: AttackPosition? {
//        switch self {
//        case .stop, .idle, .idleStand, .dodgeHead:
//            nil
//        case .hitHead:
//            nil
//        case .killHead:
//            nil
//        case .punchHeadRightLight:
//            .rightLight
//        case .punchHeadRightMedium:
//            .rightMedium
//        case .punchHeadRightHard:
//            .rightHard
//        case .punchHeadLeftLight:
//            .leftLight
//        case .punchHeadLeftMedium:
//            .leftMedium
//        case .punchHeadLeftHard:
//            .leftHard
//        }
//    }

    ///returns how long a single animation takes
    func animationDuration(for fighter: FighterType) -> TimeInterval {
        let startTime = TimeInterval(0)
        let endTime = TimeInterval(getAnimationDuration(for: fighter))
        return endTime - startTime
    }

    ///Returns the duration in seconds how long it takes for the current animation type to land based on the defender's animation
    ///Used to figure out the slight delay before playing the defender's animation
    func delayForDefendingAnimation(_ defenderAnimationType: AnimationType, defender: FighterType, attacker: FighterType) -> CGFloat {
        switch defenderAnimationType {
        case .stop, .idleFight, .idleStand:
            break
        case .dodgeHeadLeft, .dodgeHeadRight, .hitHeadRightLight, .hitHeadLeftLight, .hitHeadStraightLight, .hitHeadRightMedium, .hitHeadLeftMedium, .hitHeadStraightMedium, .hitHeadRightHard, .hitHeadLeftHard, .hitHeadStraightHard, .killHeadRightLight, .killHeadLeftLight, .killHeadRightMedium, .killHeadLeftMedium, .killHeadRightHard, .killHeadLeftHard:
            //Defense moves
            let delay = getHitDuration(for: attacker) - defenderAnimationType.getHitDuration(for: defender)
            return delay <= 0 ? 0 : delay
        case .punchHeadRightLight, .punchHeadRightMedium, .punchHeadRightHard, .punchHeadLeftLight, .punchHeadLeftMedium, .punchHeadLeftHard, .kickHeadRightLight, .kickHeadRightMedium, .kickHeadRightHard, .kickHeadLeftLight, .kickHeadLeftMedium, .kickHeadLeftHard:
            //Attack moves
            break
        }
        return 0
    }

    ///Returns true if the animation's attack is a straight punch. False if attack hits the side
    func isStraightAttack(for fighter: FighterType) -> Bool {
        switch self {
        case .punchHeadRightLight, .punchHeadLeftLight:
            fighter == .samuel ? true : false
        case .punchHeadRightMedium, .punchHeadLeftMedium:
            fighter == .samuel ? false : true
        case .punchHeadRightHard, .punchHeadLeftHard:
            fighter == .samuel ? false : true
        case .kickHeadRightLight, .kickHeadLeftLight:
            fighter == .samuel ? true : false
        case .kickHeadRightMedium, .kickHeadLeftMedium:
            fighter == .samuel ? false : true
        case .kickHeadRightHard, .kickHeadLeftHard:
            fighter == .samuel ? false : true
        case .dodgeHeadRight, .dodgeHeadLeft, .hitHeadRightLight, .hitHeadRightMedium, .hitHeadRightHard, .hitHeadLeftLight, .hitHeadLeftMedium, .hitHeadLeftHard, .hitHeadStraightLight, .hitHeadStraightMedium, .hitHeadStraightHard, .killHeadRightLight, .killHeadRightMedium, .killHeadRightHard, .killHeadLeftLight, .killHeadLeftMedium, .killHeadLeftHard, .stop, .idleFight, .idleStand:
            false
        }
    }
}

//MARK: - Methods
extension AnimationType {
    ///the animation's total duration in seconds
    private func getAnimationDuration(for fighter: FighterType) -> CGFloat {
        //Note: You can only get these values by getting the animations and printing out the duration
        switch self {
        case .idleStand:
            fighter == .samuel ? 4.46667 : 38.833332
        case .stop:
            0
        case .idleFight:
            fighter == .samuel ? 2.2 : 2.966667
        case .punchHeadLeftLight, .punchHeadRightLight:
            fighter == .samuel ? 1.13333 : 1.53333
        case .punchHeadLeftMedium, .punchHeadRightMedium:
            fighter == .samuel ? 1.2 : 1.133333
        case .punchHeadLeftHard, .punchHeadRightHard:
            fighter == .samuel ? 1.96667 : 1.66667
        case .kickHeadLeftLight, .kickHeadRightLight:
            fighter == .samuel ? 1.13333 : 1.53333
        case .kickHeadLeftMedium, .kickHeadRightMedium:
            fighter == .samuel ? 1.2 : 1.133333
        case .kickHeadLeftHard, .kickHeadRightHard:
            fighter == .samuel ? 1.96667 : 1.66667
        case .dodgeHeadRight, .dodgeHeadLeft:
            1.433333
        case .hitHeadRightLight:
            fighter == .samuel ? 0.833333 : 0.933333
        case .hitHeadRightMedium:
            fighter == .samuel ? 1 : 1.166667
        case .hitHeadRightHard:
            fighter == .samuel ? 1 : 1.166667
        case .hitHeadLeftLight:
            fighter == .samuel ? 0.766667 : 1.066667
        case .hitHeadLeftMedium:
            fighter == .samuel ? 1.066667 : 1.233333
        case .hitHeadLeftHard:
            fighter == .samuel ? 1.633333 : 1.666667
        case .hitHeadStraightLight:
            fighter == .samuel ? 0.8 : 1.066667
        case .hitHeadStraightMedium:
            fighter == .samuel ? 0.933333 : 1.233333
        case .hitHeadStraightHard:
            fighter == .samuel ? 1.3 : 1.433333
        case .killHeadRightLight, .killHeadLeftLight:
            fighter == .samuel ? 2.333333 : 2.6
        case .killHeadRightMedium, .killHeadLeftMedium:
            fighter == .samuel ? 2.533333 : 2.2
        case .killHeadRightHard, .killHeadLeftHard:
            fighter == .samuel ? 2.233333 : 3.033333
        }
    }

    ///the animation's duration when attack lands or when to play the defense animation in seconds
    private func getHitDuration(for fighter: FighterType) -> CGFloat {
        //Note: these values are estimate and manually inputted after testing animations. The smaller the number, the more sooner the animation will get played
        switch self {
        //MARK: Idle moves
        case .idleStand, .idleFight, .stop:
            0
        //MARK: Defense moves
        case .dodgeHeadRight, .dodgeHeadLeft:
            getAnimationDuration(for: fighter) * 10/43
        case .hitHeadRightLight:
            getAnimationDuration(for: fighter) * (fighter == .samuel ? 2/25 : 1/28)
        case .hitHeadRightMedium:
            getAnimationDuration(for: fighter) * (fighter == .samuel ? 2/30 : 2/35)
        case .hitHeadRightHard:
            getAnimationDuration(for: fighter) * (fighter == .samuel ? 2/47 : 2/46)
        case .hitHeadLeftLight:
            getAnimationDuration(for: fighter) * (fighter == .samuel ? 2/23 : 2/32)
        case .hitHeadLeftMedium:
            getAnimationDuration(for: fighter) * (fighter == .samuel ? 2/32 : 2/37)
        case .hitHeadLeftHard:
            getAnimationDuration(for: fighter) * (fighter == .samuel ? 2/49 : 2/50)
        case .hitHeadStraightLight:
            getAnimationDuration(for: fighter) * (fighter == .samuel ? 2/24 : 2/32)
        case .hitHeadStraightMedium:
            getAnimationDuration(for: fighter) * (fighter == .samuel ? 2/28 : 2/37)
        case .hitHeadStraightHard:
            getAnimationDuration(for: fighter) * (fighter == .samuel ? 2/30 : 2/43)
        case .killHeadRightLight, .killHeadLeftLight:
            getAnimationDuration(for: fighter) * (fighter == .samuel ? 2/70 : 9/78)
        case .killHeadRightMedium, .killHeadLeftMedium:
            getAnimationDuration(for: fighter) * (fighter == .samuel ? 1/77 : 2/76)
        case .killHeadRightHard, .killHeadLeftHard:
            getAnimationDuration(for: fighter) * (fighter == .samuel ? 1/68 : 1/91)
        //MARK: Attacks
        case .punchHeadLeftLight, .punchHeadRightLight:
            getAnimationDuration(for: fighter) * (fighter == .samuel ? 7/34 : 8/31) //9/46 for clara's light2
        case .punchHeadLeftMedium, .punchHeadRightMedium:
            getAnimationDuration(for: fighter) * (fighter == .samuel ? 16/36 : 22/34) //13/53 for .clara's medium2
        case .punchHeadLeftHard, .punchHeadRightHard:
            getAnimationDuration(for: fighter) * (fighter == .samuel ? 29/59 : 26/50)
        //MARK: Kicks
        case .kickHeadLeftLight, .kickHeadRightLight:
            getAnimationDuration(for: fighter) * (fighter == .samuel ? 7/34 : 8/31) //9/46 for clara's light2
        case .kickHeadLeftMedium, .kickHeadRightMedium:
            getAnimationDuration(for: fighter) * (fighter == .samuel ? 16/36 : 22/34) //13/53 for .clara's medium2
        case .kickHeadLeftHard, .kickHeadRightHard:
            getAnimationDuration(for: fighter) * (fighter == .samuel ? 29/59 : 26/50)
        }
    }
}
