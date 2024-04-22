//
//  Fighter.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/24/24.
//

import SceneKit

///3D model of the fighter
class Fighter {
    let fighterType: FighterType
    let isEnemy: Bool
    var defaultAnimation: AnimationType

    ///Will contain all of the fighter node
    var daeHolderNode = SCNNode()
    ///parent of all animation nodes
    var animationsNode: SCNNode!
    var currentAnimation: AnimationType?

    init(type: FighterType, isEnemy: Bool) {
        self.fighterType = type
        self.isEnemy = isEnemy
        defaultAnimation = .idle
        createNode()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func positionNode(asEnemy: Bool, asHorizontal: Bool = false) {
        daeHolderNode.scale = SCNVector3Make(fighterType.scale, fighterType.scale, fighterType.scale)
        var xPosition: Float = isEnemy ? 1.5 : 0    //further
        let yPosition: Float = 0.5                  //vertical position
        var zPosition: Float = isEnemy ? 2.7 : 3    //horizontal position
        var angle: Float = isEnemy ? -89.5 : 90
        if asHorizontal {
            xPosition = 2
            zPosition = isEnemy ? 3 : 1.5
            angle = isEnemy ? 180 : 0
        }
        daeHolderNode.position = SCNVector3Make(xPosition, yPosition, zPosition)
        daeHolderNode.eulerAngles = .init(x: 0, y: angle, z: 0)
//        skinner = nil
//        rotation = .init(1, 0, 0, 0)
    }

    func loadAnimations(animations: [AnimationType]) {
        for animationType in animations {
            addAnimationPlayer(animationType)
        }
    }

    ///Plays an animation if animationType is new
    func playAnimation(_ animationType: AnimationType) {
        let isNewAnimation = currentAnimation == nil || currentAnimation! != animationType
        guard isNewAnimation else { return }
        currentAnimation = animationType
        guard let player = animationsNode.animationPlayer(forKey: animationType.rawValue) else {
            LOGDE("No player found to play for \(animationType)")
            return
        }
        player.play()
        currentAnimation = nil
        if animationType == .killHead {
            //Pause animation after playing kill animation
            DispatchQueue.main.asyncAfter(deadline: .now() + (player.animation.duration - 0.2)) {
                self.pauseAnimations()
            }
        }
    }

    func pauseAnimations() {
        animationsNode.isPaused = true
    }

    func stopAnimations() {
        animationsNode.removeAllAnimations()
    }
}

private extension Fighter {
    ///Create node from default animation
    private func createNode() {
        daeHolderNode = SCNNode(daePath: fighterType.defaultDaePath)
        //Add materials and images programmatically
        for child in daeHolderNode.childNodes {
            if let partName = child.name,
               let part = SkeletonType(rawValue: partName) {
                child.geometry?.firstMaterial = part.material
            }
        }
        //Assign the daeHolderNode's bones as the node to animate
        animationsNode = daeHolderNode.childNode(withName: fighterType.bonesName, recursively: true)!
    }

    ///Adds animation player to the animationsNode with the animationType.rawValue as the key
    private func addAnimationPlayer(_ animationType: AnimationType) {
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
}
