//
//  FighterNode.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/24/24.
//

import SceneKit

///3D model of the fighter
class FighterNode: SCNNode {

    private var fighter: Fighter

    //MARK: Nodes
    private var daeHolderNode = SCNNode()
    ///node that can be animated
    var bonesNode: SCNNode!
    var currentAnimation: FighterAnimationType?

    init(fighter: Fighter) {
        self.fighter = fighter
        super.init()
        LOGD("===========================================================================")
        setupModel()
        loadAnimations()
        positionModel()
        LOGD("===========================================================================\n\n")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupModel() {
        LOGD("Setting up \(fighter.type.name)")
        let fighterScene = try! SCNScene(url: fighter.type.daeUrl!, options: nil)
        //Correct way of loading a dae model
        for child in fighterScene.rootNode.childNodes {
            daeHolderNode.addChildNode(child)
        }
        addChildNode(daeHolderNode)
        bonesNode = daeHolderNode.childNode(withName: fighter.type.bonesName, recursively: true)!
    }

    private func positionModel() {
        scale = SCNVector3Make(fighter.type.scale, fighter.type.scale, fighter.type.scale)
        let xPosition: Float = fighter.isEnemy ? 1.5 : 0    //further
        let yPosition: Float = 0.5                          //vertical position
        let zPosition: Float = fighter.isEnemy ? 3.2 : 3    //horizontal position
        position = SCNVector3Make(xPosition, yPosition, zPosition)
        let angle: Float = fighter.isEnemy ? -90 : 90
        eulerAngles = .init(x: 0, y: angle, z: 0)
//        skinner = nil
//        rotation = .init(1, 0, 0, 0)
    }

    func loadAnimations() {
        fighter.animations.removeAll()

        loadAnimation(.idle)
        loadAnimation(.idleStand)
        loadAnimation(.idleTired)
        loadAnimation(.punchHighLightLeft)
        loadAnimation(.punchHighMediumLeft)
        loadAnimation(.punchHighHardLeft)
        loadAnimation(.punchHighLightRight)
        loadAnimation(.punchHighMediumRight)
        loadAnimation(.punchHighHardRight)
        LOGD("Loaded CA animations count: \(fighter.animations.count)")
    }

    //MARK: - Load animation
    func loadAnimation(_ animationType: FighterAnimationType) {
        // Load the dae file for that animation
        let path = "3DAssets.scnassets/Characters/\(fighter.name)/\(animationType.animationPath)"
        let scene = SCNScene(named: path)!

        // This node will be parent of all the animation models
        let animationsNode = SCNNode()
        animationsNode.name = animationType.rawValue
        for child in scene.rootNode.childNodes {
            if animationType.hasCaAnimation {
                for item in child.childNodes {
                    if let animationKey = item.animationKeys.first,
                       let oldplayer = item.animationPlayer(forKey: animationKey) {
                        LOGD("Loading animated animation: \(animationType.rawValue), adding animation \"\(animationKey)\" to \"\(item.name ?? "")\"")
                        // initially stop player
                        oldplayer.stop()
                        // make an animation for each animation group
                        let fightAnimation = FightAnimation(animationType, from: oldplayer.animation, delegate: self)
                        fighter.animations.append(fightAnimation)
                        let animationPlayer = SCNAnimationPlayer(animation: SCNAnimation(caAnimation: fightAnimation.animation))
                        item.addAnimationPlayer(animationPlayer, forKey: animationType.rawValue)
                    }
                }
            }
            animationsNode.addChildNode(child)
            animationsNode.isHidden = true
        }

        // Add the node to the holder
        daeHolderNode.addChildNode(animationsNode)
    }

    ///Plays an animation if animationType is new
    func playAnimation(_ animationType: FighterAnimationType, completion: @escaping () -> Void) {
        let isNewAnimation = currentAnimation == nil || currentAnimation! != animationType
        guard isNewAnimation else { return }
        currentAnimation = animationType
        switch animationType {
        case .idle:
            for animation in fighter.animations {
                bonesNode.removeAnimation(forKey: animation.type.rawValue, blendOutDuration: 0.2)
                if animation.type == animationType {
                    LOGD("Found IDLE animation to play")
                    bonesNode.addAnimation(animation.animation, forKey: animationType.rawValue)
                } else {
                    LOGD("Found non IDLE animation to remove")
                }
            }
//            Figure out if we still need this to play CAAnimation
//            for child in bonesNode.childNodes {
//                LOGD("Searching anim of \(animationType.rawValue) in \(child.name ?? "") has animations: \(child.animationKeys)")
//                if let player = child.animationPlayer(forKey: animationType.rawValue) {
//                    player.animation.repeatCount = CGFloat(Float.greatestFiniteMagnitude)
//                    player.animation.blendInDuration = TimeInterval(CGFloat(0.2))
//                    player.animation.blendOutDuration = TimeInterval(CGFloat(0.2))
//                    let event = SCNAnimationEvent(keyTime: 1) { (animation, object, backwards) in
//                        print("animation ended")
//                        player.stop()
//                    }
//                    LOGD("1111 Playing \(animationType.rawValue) animation")
//                    player.animation.animationEvents = [event]
//                    player.play()
//                    LOGD("Found \(animationType.rawValue) animation at \(player.animationKeys)")
//                    break
//                }
//            }
        case .stop:
            stopAnimations()
        case .punchHighLightRight, .punchHighMediumRight, .punchHighHardRight, .punchHighLightLeft, .punchHighMediumLeft, .punchHighHardLeft, .idleStand, .idleTired:
            if let newNode = daeHolderNode.childNode(withName: animationType.rawValue, recursively: true) {
                //Note: Uncomment below to check the DAE's animation's full duration
                //                printAnimationDuration(for: animationType)
                //                LOGD("PLAYING \(bonesNode.animationKeys) at \(bonesNode.name ?? "")")
                ///Play Animation
                daeHolderNode.removeFromParentNode()
                bonesNode.removeFromParentNode()
                daeHolderNode.removeAllAnimations(withBlendOutDuration: animationType.fadeOutDuration * 2)
                daeHolderNode = SCNNode()
                bonesNode = SCNNode()
                let attackScene = try! SCNScene(url: fighter.type.animationUrl(animationType)!, options: nil)
                //Correct way of loading a dae model
                for child in attackScene.rootNode.childNodes {
                    daeHolderNode.addChildNode(child)
                }
                bonesNode = daeHolderNode.childNode(withName: fighter.type.bonesName, recursively: true)!
                addChildNode(daeHolderNode)

                ///Go back to idle state
                let deadline: DispatchTime = .now() + CGFloat(animationType.duration - 0.15)
                DispatchQueue.main.asyncAfter(deadline: deadline) {
                    self.daeHolderNode.removeFromParentNode()
                    self.bonesNode.removeFromParentNode()
                    self.daeHolderNode = SCNNode()
                    self.bonesNode = SCNNode()
                    self.setupModel()
                    self.loadAnimations()
                    self.currentAnimation = nil
                    completion()
                }
            }
        }
    }

    func stopAnimations() {
        bonesNode.removeAllAnimations()
    }
}

extension FighterNode: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        for animation in fighter.animations {
            if anim == animation.animation {
                LOGD("GOT MATCHING ANIMATION!!!!!! Too good to be true")
            }
        }
    }
}

private extension FighterNode {
    ///Prints the whole duration of the animation's
    func printAnimationDuration(for animationType: FighterAnimationType) {
        for child in daeHolderNode.childNodes {
            if let childName = child.name,
               childName == animationType.rawValue {
                //                        LOGD("55 Child Got a matching \(childName) animation with keys \(child.animationKeys)")
                for item in child.childNodes {
                    LOGD("555 Grandchild \(item.name ?? "") animation to play at \(item.animationKeys)")
                    if let animationKey = item.animationKeys.first,
                       let oldplayer = item.animationPlayer(forKey: animationKey) { //it goes here instead
                        LOGD("5555 Playing animation for duration: \(oldplayer.animation.duration) with events \(oldplayer.animation.animationEvents?.count ?? 0)")
                        //                                oldplayer.play()
                        break
                    }
                }
                break
            }
        }
    }

    //MARK: - IGNORE THIS FUNCTION!
    //TODO: Try if these 2 functions work (animateEntireNodeTreeOnce, and onlyAnimateThisNodeOnce)
    //    Source: https://stackoverflow.com/questions/29692388/scenekit-stop-continuously-looping-collada-animation
//    func animateEntireNodeTreeOnce(mostRootNode node: SCNNode) {
//        onlyAnimateThisNodeOnce(node)
//        for childNode in node.childNodes {
//            animateEntireNodeTreeOnce(mostRootNode: childNode)
//        }
//    }
//
//    func onlyAnimateThisNodeOnce(_ node: SCNNode) {
//        if node.animationKeys.count > 0 {
//            for key in node.animationKeys {
//                //TODO: Alternative for this
//                //Source: https://stackoverflow.com/questions/46009032/alternative-to-animationforkey-now-deprecated
//                //And maybe investigate this https://stackoverflow.com/questions/75090481/how-to-get-a-ordinary-mixamo-character-animation-working-in-scenekit/75093081#75093081
//                let animation = node.animation(forKey: key)!
//                animation.repeatCount = 1
//                animation.isRemovedOnCompletion = false
//                node.removeAllAnimations()
//                node.addAnimation(animation, forKey: key)
//            }
//        } else {
//            LOGE("onlyAnimateThisNodeOnce() Called with no animation")
//        }
//    }

    //    func loadAnimatio2(_ type: FighterAnimationType) {
    //        let animationName = type.rawValue
    //        LOGD("Began loading \(animationName)")
    //        let path = "3DAssets.scnassets/Characters/\(fighter.name)/\(type.animationPath)"
    //        guard let sceneUrl = Bundle.main.url(forResource: path, withExtension: "dae") else {
    //            LOGE("Failed to create a url from path \(path)")
    //            return
    //        }
    //        let sceneSource = SCNSceneSource(url: sceneUrl, options: nil)!
    //        let group = CAAnimationGroup()
    //        group.duration = 2.0
    //        group.repeatCount = 3
    //        group.fillMode = .forwards
    //        group.animations = []
    //        for id in fighter.animationIds(for: type) {
    //            let entryIds = sceneSource.identifiersOfEntries(withClass: CAAnimation.self)
    //            for entryId in entryIds {
    //                //MARK: - IGNORE THIS FUNCTION!
    //                if id != entryId { continue }
    //                LOG("Got a match for \(id)")
    ////                let animation: CAAnimation = sceneSource.entryWithIdentifier(id, withClass: CAAnimation.self)!
    //                let animation: CAAnimation = sceneSource.entryWithIdentifier("unnamed_animation__1", withClass: CAAnimation.self)!
    //                switch type {
    //                case .idle:
    //                    animation.repeatCount = Float.greatestFiniteMagnitude
    //                case .punchHighLightRight, .punchHighMediumRight, .punchHighHardRight, .punchHighLightLeft, .punchHighMediumLeft, .punchHighHardLeft:
    //                    animation.setValue(type.rawValue, forKey: type.rawValue)
    //                    animation.isRemovedOnCompletion = false
    //                case .stop:
    //                    break
    //                }
    //                group.animations?.append(animation)
    //            }
    //        }
    //        group.delegate = self
    //        group.repeatCount = 0
    //        group.fadeInDuration = CGFloat(0.2)
    //        group.fadeOutDuration = CGFloat(0.2)
    //        group.usesSceneTimeBase = false
    //        group.fillMode = .forwards
    //        let fightAnimation = FightAnimation(type: type, animation: group)
    //        fighter.animations.append(fightAnimation)
    //        LOGD("IGNORE THIS FUNCTION!!! Done loading animation \(animationName)")
    //    }

    //    private func loadAnimations() {
    //        loadAnimation(.idle)
    //        loadAnimation(.punchHighHardLeft)
    ////        let id = "idle"
    ////        let path = "3DAssets.scnassets/Characters/Samuel/animations/idle/idle"
    ////        guard let sceneUrl = Bundle.main.url(forResource: path, withExtension: "dae") else {
    ////            LOGE("idle doesnt exist")
    ////            return
    ////        }
    //////        let animPlayer = SCNAnimationPlayer(animation: SCNAnimation(contentsOf: sceneUrl))
    //////        print("444 player has \(animPlayer.animationKeys.count)")
    ////
    ////        let sceneSource = SCNSceneSource(url: sceneUrl, options: nil)!
    ////        //find top level animation
    ////        var animationPlayers: [SCNAnimationPlayer] = []
    ////        animationPlayerKeys[id] = []
    ////        try! sceneSource.scene().rootNode.enumerateChildNodes { (child, stop) in
    ////            var index = 0
    ////            let childName = child.name ?? String(index)
    ////            let childWithAnimationKeys = child.animationKeys.compactMap { $0.isEmpty ? nil : $0 }
    //////            if !childWithAnimationKeys.isEmpty {
    //////                LOGD("Child \(childName) has \(child.animationKeys)")
    //////            }
    ////            for i in childWithAnimationKeys.indices {
    ////                let key = childWithAnimationKeys[i]
    ////                let indexedKey = "\(key)_\(i)"
    ////                LOGD("CHILD \(childName) has a player to add \(key)")
    ////                let player = child.animationPlayer(forKey: key)!
    ////                player.stop()
    //////                addAnimationPlayer(player, forKey: indexedKey)
    ////                bonesNode.addAnimationPlayer(player, forKey: key)
    ////                animationPlayers.append(player)
    ////                animationPlayerKeys[id]?.append(key)
    ////                index += 1
    ////            }
    ////        }
    ////        if !animationPlayers.isEmpty {
    ////            LOGD("Total animations is \(animationPlayers.count)")
    ////            fighterAnimations[id] = animationPlayers
    ////            LOGD("Next child\n")
    ////        }
    //    }

    //    func loadIdleAnimation() {
    //        let id = "idle"
    //        let path = "3DAssets.scnassets/Characters/Samuel/animations/idle/idle"
    //        guard let sceneUrl = Bundle.main.url(forResource: path, withExtension: "dae") else {
    //            LOGE("idle doesnt exist")
    //            return
    //        }
    //
    //        let sceneSource = SCNSceneSource(url: sceneUrl, options: nil)!
    //        //find top level animation
    //        var animationPlayers: [SCNAnimationPlayer] = []
    //        animationPlayerKeys[id] = []
    //        try! sceneSource.scene().rootNode.enumerateChildNodes { (child, stop) in
    //            var index = 0
    //            let childName = child.name ?? String(index)
    //            let childWithAnimationKeys = child.animationKeys.compactMap { $0.isEmpty ? nil : $0 }
    //            for animationKey in childWithAnimationKeys {
    //                LOGD("CHILD \(childName) has a player to add \(animationKey)")
    //                let player = child.animationPlayer(forKey: animationKey)!
    //                player.stop()
    //
    //                bonesNode.addAnimationPlayer(player, forKey: animationKey)
    //                animationPlayers.append(player)
    //                animationPlayerKeys[id]?.append(animationKey)
    //                index += 1
    //            }
    //        }
    //        if !animationPlayers.isEmpty {
    //            LOGD("Total animations is \(animationPlayers.count)")
    //            fighterAnimations[id] = animationPlayers
    //            LOGD("Next child\n")
    //        }
    //    }
}
