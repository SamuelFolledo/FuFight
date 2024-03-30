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

    init(fighter: Fighter) {
        self.fighter = fighter
        super.init()
        LOGD("===========================================================================")
        setupModel()
        loadAnimations()
        positionModel(self)
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

    private func positionModel(_ node: SCNNode) {
        if node == self {
            node.scale = SCNVector3Make(fighter.type.scale, fighter.type.scale, fighter.type.scale)
            let xPosition: Float = fighter.isEnemy ? 1.5 : 0    //further
            let yPosition: Float = 0.5                          //vertical position
            let zPosition: Float = fighter.isEnemy ? 3.2 : 3    //horizontal position
            node.position = SCNVector3Make(xPosition, yPosition, zPosition)
//            node.skinner = nil
            let angle: Float = fighter.isEnemy ? -90 : 90
            node.eulerAngles = .init(x: 0, y: angle, z: 0)
            //        node.rotation = .init(1, 0, 0, 0)
        } else {
//            node.skinner = nil //uncommenting this makes the node not animate
            LOGD("Positioninggg \(node.name ?? "")")
            node.position = position
            node.eulerAngles = eulerAngles
            node.scale = scale
        }
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

        LOGD("Loaded animations count: \(fighter.animations.count)")
    }

    //MARK: - Load animation
    func loadAnimation(_ animationType: FighterAnimationType) {
        // Load the character in the idle animation
        let path = "3DAssets.scnassets/Characters/\(fighter.name)/\(animationType.animationPath)"
        let scene = SCNScene(named: path)!

        // This node will be parent of all the animation models
        let animationsNode = SCNNode()
        animationsNode.name = animationType.rawValue
        for child in scene.rootNode.childNodes {
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

                    //                            DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                    //                                if let player: SCNAnimationPlayer = item.animationPlayer(forKey: animationType.rawValue) {
                    //                                    player.animation.repeatCount = CGFloat(Float.greatestFiniteMagnitude)
                    //                                    player.animation.blendInDuration = TimeInterval(CGFloat(0.2))
                    //                                    player.animation.blendOutDuration = TimeInterval(CGFloat(0.2))
                    //
                    //                                    let event = SCNAnimationEvent(keyTime: 1) { (animation, object, backwards) in
                    //                                        print("animation ended")
                    //                                        player.stop()
                    //                                    }
                    //                                    LOGD("1111 Playing \(animationType.rawValue) animation")
                    //                                    player.animation.animationEvents = [event]
                    ////                                    player.play() //call not needed to play animation
                    //                                }
                    //                            }
                }
            }
            animationsNode.addChildNode(child)
            animationsNode.isHidden = true
        }

        // Add the node to the holder
        daeHolderNode.addChildNode(animationsNode)
    }

    //MARK: - Play animation
    func playAnimation(_ animationType: FighterAnimationType) {
        LOGD("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++1")
        LOGD("Attempting to play animation: \(animationType.rawValue)")
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
//            for child in bonesNode.childNodes {
//                LOGD("Searching anim of \(animationType.rawValue) in \(child.name ?? "") has animations: \(child.animationKeys)")
//                if let player = child.animationPlayer(forKey: animationType.rawValue) {
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
                let deadline: DispatchTime = .now() + CGFloat(animationType.duration)
                DispatchQueue.main.asyncAfter(deadline: deadline) {
                    self.daeHolderNode.removeFromParentNode()
                    self.bonesNode.removeFromParentNode()
                    self.daeHolderNode = SCNNode()
                    self.bonesNode = SCNNode()
                    self.setupModel()
                    self.loadAnimations()
                }
//                daeHolderNode.replaceChildNode(bonesNode, with: newNode)
            }
        }
        LOGD("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++2\n")
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
                        LOGD("5555 Playing animation for duration: \(oldplayer.animation.duration)")
                        //                                oldplayer.play()
                        break
                    }
                }
                break
            }
        }
    }
}
