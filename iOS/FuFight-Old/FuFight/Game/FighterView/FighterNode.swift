//
//  FighterNode.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/24/24.
//

import SceneKit

///3D model of the fighter
class FighterNode {
    let fighterType: FighterType
    let isEnemy: Bool
    var defaultAnimation: FighterAnimationType

    ///Will contain all of the fighter node
    var daeHolderNode = SCNNode()
    ///parent of all animation nodes
    var animationsNode: SCNNode!
    var currentAnimation: FighterAnimationType?

    init(type: FighterType, isEnemy: Bool) {
        self.fighterType = type
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

    ///Create node from default animation
    private func createNode() {
        daeHolderNode = SCNNode(daePath: fighterType.defaultDaePath)
        //Add materials and images programmatically
        for child in daeHolderNode.childNodes {
            if let partName = child.name,
               let part = FighterBodyPartType(rawValue: partName) {
                child.geometry?.firstMaterial = part.material
            }
        }
        //Assign the daeHolderNode's bones as the node to animate
        animationsNode = daeHolderNode.childNode(withName: fighterType.bonesName, recursively: true)!
    }

    private func positionModel() {
        daeHolderNode.scale = SCNVector3Make(fighterType.scale, fighterType.scale, fighterType.scale)
        let xPosition: Float = isEnemy ? 1.5 : 0    //further
        let yPosition: Float = 0.5                  //vertical position
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
        let path = "3DAssets.scnassets/Characters/\(fighterType.name)/\(animationType.animationPath)"
        let scene = SCNScene(named: path)!
        //Grab the animation from the child or grandchild and add the animation player to the animationsNode
        for child in scene.rootNode.childNodes {
            if !child.animationKeys.isEmpty,
               let animationPlayer = SCNAnimationPlayer.loadAnimation(animationType, fighterType: fighterType, from: child) {
                animationsNode.addAnimationPlayer(animationPlayer, forKey: animationType.rawValue)
                break
            } else {
                //Not needed for my case, but added just in case
                for item in child.childNodes {
                    if !item.animationKeys.isEmpty,
                       let animationPlayer = SCNAnimationPlayer.loadAnimation(animationType, fighterType: fighterType, from: item) {
                        animationsNode.addAnimationPlayer(animationPlayer, forKey: animationType.rawValue)
                        break
                    }
                }
            }
        }
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
