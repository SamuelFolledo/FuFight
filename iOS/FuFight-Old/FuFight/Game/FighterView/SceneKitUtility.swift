//
//  SceneKitUtility.swift
//  FuFight
//
//  Created by Samuel Folledo on 4/9/24.
//

import SceneKit

struct SceneKitUtility {
    ///Convert a grouped SCNAnimation into CAAnimation
    static func animation(for type: FighterAnimationType, from full: SCNAnimation) -> CAAnimation {
        let animation = CAAnimationGroup()
        let sub = full.copy() as! SCNAnimation
        sub.timeOffset = 0
        animation.animations = [CAAnimation(scnAnimation: sub)]
        animation.duration = type.animationDuration
        animation.isRemovedOnCompletion = type.isRemovedFromCompletion
        animation.fadeInDuration = type.fadeInDuration
        animation.fadeOutDuration = type.fadeOutDuration
        animation.usesSceneTimeBase = type.usesSceneTimeBase
        animation.repeatCount = type.repeatCount
        //        animation.delegate = self
        return animation
    }
}
