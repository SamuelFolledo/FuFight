//
//  Animation.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/28/24.
//

import SceneKit

struct FightAnimation {
    var type: FighterAnimationType
    var animation: CAAnimation!
    var delegate: CAAnimationDelegate!

    init(_ animationType: FighterAnimationType, from full: SCNAnimation, startingAtFrame start: Int = 1, endingAtFrame end: Int = 360, fps: Double = 30, delegate: CAAnimationDelegate) {
        self.type = animationType
        self.delegate = delegate
        self.animation = animation(from: full, startingAtFrame: start, endingAtFrame: end, fps: fps)
        self.animation.delegate = delegate
    }

    ///Convert a grouped SCNAnimation into CAAnimation
    private func animation(from full: SCNAnimation, startingAtFrame start: Int, endingAtFrame end: Int, fps: Double) -> CAAnimation {
        let range = timeRange(forStartingAtFrame: start, endingAtFrame: end, fps: fps)
        LOGD("Finished creating animation for \(type.rawValue) IS \(range)")
        let animation = CAAnimationGroup()
        let sub = full.copy() as! SCNAnimation
        sub.timeOffset = range.offset
        animation.animations = [CAAnimation(scnAnimation: sub)]
        animation.duration = range.duration
        animation.isRemovedOnCompletion = type.isRemovedFromCompletion
        animation.fadeInDuration = type.fadeInDuration
        animation.fadeOutDuration = type.fadeOutDuration
        animation.usesSceneTimeBase = type.usesSceneTimeBase
        animation.repeatCount = type.repeatCount
        return animation
    }

    private func timeRange(forStartingAtFrame start: Int, endingAtFrame end: Int, fps: Double = 30) -> (offset: TimeInterval, duration: TimeInterval) {
        let startTime   = TimeInterval(start) / fps
        let endTime     = TimeInterval(end) / fps
        return (offset: startTime, duration: endTime - startTime)
    }
}


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
    case idleTired
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
        case .idle, .idleStand, .idleTired:
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

    ///Returns true if dae file's childNodes has animationKeys
    var hasCaAnimation: Bool {
        switch self {
        case .idle:
            true
        case .punchHighLightRight, .punchHighMediumRight, .punchHighHardRight, .punchHighLightLeft, .punchHighMediumLeft, .punchHighHardLeft, .idleStand, .idleTired, .stop:
            false
        }
    }

    var isRemovedFromCompletion: Bool {
        switch self {
        case .idle, .idleStand, .idleTired, .stop:
            false
        case .punchHighLightRight, .punchHighMediumRight, .punchHighHardRight, .punchHighLightLeft, .punchHighMediumLeft, .punchHighHardLeft:
            true
        }
    }

    var fadeInDuration: CGFloat { 0.2 }
    var fadeOutDuration: CGFloat { 0.2 }
    var usesSceneTimeBase: Bool { false }
    var repeatCount: Float {
        switch self {
        case .idle, .idleStand, .idleTired, .stop:
            0
        case .punchHighLightRight, .punchHighMediumRight, .punchHighHardRight, .punchHighLightLeft, .punchHighMediumLeft, .punchHighHardLeft:
            1
        }
    }

    var duration: CGFloat {
        switch self {
        case .idleStand:
            4.466670036315918
        case .idleTired:
            3.6333301067352295
        case .idle, .stop:
            10
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
}
