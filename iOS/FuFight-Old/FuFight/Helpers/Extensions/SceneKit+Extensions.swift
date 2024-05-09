//
//  SceneKit+Extensions.swift
//  FuFight
//
//  Created by Samuel Folledo on 4/9/24.
//

import SceneKit

extension CAAnimation {
    ///Convert a grouped SCNAnimation into CAAnimation. Used on creating animation player
    class func createCaAnimation(for type: AnimationType, from full: SCNAnimation) -> CAAnimation {
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
        return animation as CAAnimation
    }
}

extension SCNNode {
    convenience init(daePath path: String) {
        self.init()
        guard let url = Bundle.main.url(forResource: path, withExtension: "dae"),
              let scene = try? SCNScene(url: url, options: nil) else { return }
        scene.rootNode.childNodes.forEach { addChildNode($0) }
    }
}

extension SCNAnimationPlayer {
    class func loadAnimation(_ animationType: AnimationType, fighterType: FighterType, from node: SCNNode) -> SCNAnimationPlayer? {
        let path = fighterType.animationPath(animationType)
        // Load the dae file for that animation
        guard let url = Bundle.main.url(forResource: path, withExtension: "dae"),
              let scene = try? SCNScene(url: url, options: nil) else { return nil }
        //Grab the animation from the child or grandchild and add the animation player to the animationsNode
        for child in scene.rootNode.childNodes {
            if !child.animationKeys.isEmpty,
               let caAnimation = getCaAnimation(for: animationType, from: child) {
                return SCNAnimationPlayer(animation: SCNAnimation(caAnimation: caAnimation))
            } else {
                //Not needed for my case, but added just in case
                for item in child.childNodes {
                    if !item.animationKeys.isEmpty,
                       let caAnimation = getCaAnimation(for: animationType, from: item) {
                        return SCNAnimationPlayer(animation: SCNAnimation(caAnimation: caAnimation))
                    }
                }
            }
        }
        return nil
    }

    ///Returns the animation from the node as CAAnimation
    private class func getCaAnimation(for animationType: AnimationType, from node: SCNNode) -> CAAnimation? {
        guard let animationKey = node.animationKeys.first,
              let player = node.animationPlayer(forKey: animationKey) else {
            LOGDE("Failed to add animation player for \(animationType.rawValue) from \(node.name ?? "")")
            return nil
        }
        player.stop()
        return CAAnimation.createCaAnimation(for: animationType, from: player.animation)
    }
}
