//
//  FighterNode.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/24/24.
//

import SceneKit

///3D model of the fighter
class FighterNode {
    let type: FighterType
    let isEnemy: Bool
    var defaultAnimation: FighterAnimationType

    ///Will contain all of the fighter node
    var daeHolderNode = SCNNode()
    ///parent of all animation nodes
    var animationsNode: SCNNode!
    var currentAnimation: FighterAnimationType?

    init(type: FighterType, isEnemy: Bool) {
        self.type = type
        self.isEnemy = isEnemy
        LOGD("===========================================================================")
        defaultAnimation = .idle
        createNode()
        let idleAnimations: [FighterAnimationType] = [.idle, .idleStand]
        let attacks: [FighterAnimationType] = [.punchHighLightLeft, .punchHighMediumLeft, .punchHighHardLeft, .punchHighLightRight, .punchHighMediumRight, .punchHighHardRight]
        loadAnimations(animations: idleAnimations + attacks)
        positionModel()
        LOGD("===========================================================================\n\n")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    ///Create a dae model with default animation
    private func createNode() {
        let animationScene = try! SCNScene(url: type.animationUrl(defaultAnimation)!, options: nil)
        for child in animationScene.rootNode.childNodes {
            daeHolderNode.addChildNode(child)
        }
        animationsNode = daeHolderNode.childNode(withName: type.bonesName, recursively: true)!
    }

    private func positionModel() {
        daeHolderNode.scale = SCNVector3Make(type.scale, type.scale, type.scale)
        let xPosition: Float = isEnemy ? 1.5 : 0    //further
        let yPosition: Float = 0.5                          //vertical position
        let zPosition: Float = isEnemy ? 2.7 : 3    //horizontal position
        daeHolderNode.position = SCNVector3Make(xPosition, yPosition, zPosition)
        let angle: Float = isEnemy ? -89.5 : 90
        daeHolderNode.eulerAngles = .init(x: 0, y: angle, z: 0)
//        skinner = nil
//        rotation = .init(1, 0, 0, 0)
    }

    func loadAnimations(animations: [FighterAnimationType]) {
        for animationType in animations {
            addAnimationPlayer(animationType)
        }
    }

    ///Adds animation player to the animationsNode with the animationType.rawValue as the key
    private func addAnimationPlayer(_ animationType: FighterAnimationType) {
        // Load the dae file for that animation
        let path = "3DAssets.scnassets/Characters/\(type.name)/\(animationType.animationPath)"
        let scene = SCNScene(named: path)!
        //Grab the animation from the child or grandchild and add the animation player to the animationsNode
        outerLoop: for child in scene.rootNode.childNodes {
            if !child.animationKeys.isEmpty,
               let animationPlayer = getPlayerAnimation(for: animationType, from: child) {
                animationsNode.addAnimationPlayer(animationPlayer, forKey: animationType.rawValue)
                LOGD("Added animation player for \(animationType.rawValue)")
                break
            } else {
                //Not needed for my case, but added just in case
                for item in child.childNodes {
                    if !item.animationKeys.isEmpty,
                       let animationPlayer = getPlayerAnimation(for: animationType, from: item) {
                        LOGD("Added animation player for \(animationType.rawValue) is in grandchild")
                        animationsNode.addAnimationPlayer(animationPlayer, forKey: animationType.rawValue)
                        //Break outer loop since it is safe to assume that there will be only one item with animation
                        break outerLoop
                    }
                }
            }
        }
    }

    private func getPlayerAnimation(for animationType: FighterAnimationType, from node: SCNNode) -> SCNAnimationPlayer? {
        guard let caAnimation = getCaAnimation(for: animationType, from: node) else {
            LOGDE("Missing caAnimation for \(animationType.rawValue) from \(node.name ?? "")")
            return nil
        }
        let animationPlayer = SCNAnimationPlayer(animation: SCNAnimation(caAnimation: caAnimation))
        return animationPlayer
    }

    ///Returns the animation from the node as CAAnimation
    private func getCaAnimation(for animationType: FighterAnimationType, from node: SCNNode) -> CAAnimation? {
        guard let animationKey = node.animationKeys.first,
              let player = node.animationPlayer(forKey: animationKey) else {
            LOGDE("Failed to add animation player for \(animationType.rawValue) from \(node.name ?? "")")
            return nil
        }
        player.stop()
        return SceneKitUtility.animation(for: animationType, from: player.animation)
    }

    ///Plays an animation if animationType is new
    func playAnimation(_ animationType: FighterAnimationType) {
        let isNewAnimation = currentAnimation == nil || currentAnimation! != animationType
        guard isNewAnimation else { return }
        currentAnimation = animationType
        guard let player = animationsNode.animationPlayer(forKey: animationType.rawValue) else {
            LOGDE("No player found to play for \(animationType)")
            return
        }
        player.play()
        currentAnimation = nil
    }

    func stopAnimations() {
        animationsNode.removeAllAnimations()
    }
}

private extension FighterNode {
    ///Prints the whole duration of the animation's
    func printAnimationDuration(for animationType: FighterAnimationType) {
        for child in daeHolderNode.childNodes {
            if let childName = child.name,
               childName == animationType.rawValue {
                for item in child.childNodes {
                    LOGD("Grandchild \(item.name ?? "") animation to play at \(item.animationKeys)")
                    if let animationKey = item.animationKeys.first,
                       let oldplayer = item.animationPlayer(forKey: animationKey) { //it goes here instead
                        LOGD("Playing animation for duration: \(oldplayer.animation.duration) with events \(oldplayer.animation.animationEvents?.count ?? 0)")
                        break
                    }
                }
                break
            }
        }
    }
}
