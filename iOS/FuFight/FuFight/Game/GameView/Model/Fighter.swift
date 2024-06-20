//
//  Fighter.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/24/24.
//

import SceneKit

///3D model of the fighter
class Fighter {
    //MARK: Properties
    let fighterType: FighterType
    let isEnemy: Bool
    private(set) var defaultAnimation: AnimationType

    ///The parent node which contain all of the nodes
    private(set) var daeHolderNode = SCNNode()
    ///Bone node that contains the animation players
    private(set) var animationsNode: SCNNode!

    //MARK: Get-only properties
    private(set) lazy var textNode: SCNNode = {
        let node = SCNNode(geometry: damageText)
        node.name = "textNode"
        node.position = textPosition
        let scale: Float = 1.5
        node.scale = SCNVector3(x: scale, y: scale, z: scale)
        let yAngle: Float = isEnemy ? 0 : -91.5
        node.eulerAngles = .init(x: 0, y: yAngle, z: 0)
        node.runAction(SCNAction.hide())
        return node
    }()
    private lazy var damageText: SCNText = {
        let depth: CGFloat = 2
        var text = SCNText(string: "", extrusionDepth: depth)
        let font = UIFont.systemFont(ofSize: 13, weight: .black)
        text.font = font
        text.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        text.firstMaterial?.diffuse.contents = UIColor.white
//        text.firstMaterial?.specular.contents = UIColor.orange
//        text.firstMaterial?.isDoubleSided = true
//        text.chamferRadius = depth
        return text
    }()
    private lazy var textPosition: SCNVector3 = {
        return SCNVector3(x: isEnemy ? -37 : -2, y:120, z: isEnemy ? 10 : -30)
    }()
    private lazy var textNodeAction: SCNAction = {
        let showAction = SCNAction.unhide()
        let zoomInAction = SCNAction.scale(to: 3, duration: 0.15)
        let zoomOutAction = SCNAction.scale(to: 1.5, duration: 0.1)
        let initialActions = SCNAction.sequence([showAction, zoomInAction, zoomOutAction])
        //From current node's location, go up by 100
        let upwardAction = SCNAction.move(by: SCNVector3(x:0, y:100, z:0), duration: 2)
        //Keep going up but slower and begin hiding the node
        let hideAction = SCNAction.hide()
        let upwardAction2 = SCNAction.move(by: SCNVector3(x:0, y:50, z:0), duration: 2)
        let hidingActions = SCNAction.group([hideAction, upwardAction2])
        //Return to original position
        let returnAction = SCNAction.move(to: textPosition, duration: 0)
        let sequence = SCNAction.sequence([initialActions, upwardAction, hidingActions, returnAction])
        return sequence
    }()

    //MARK: - Initializers
    init(type: FighterType, isEnemy: Bool) {
        self.fighterType = type
        self.isEnemy = isEnemy
        defaultAnimation = .idle
        createNode()
        playAnimation(defaultAnimation)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Public Methods.
    func positionNode(asHorizontal: Bool = false) {
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

        //Add textNode to the parent node holder
        daeHolderNode.addChildNode(textNode)
    }

    func showResult(_ attackResult: AttackResult) {
        damageText.string = attackResult.damageText
        textNode.runAction(textNodeAction)
    }

    func loadAnimations(animations: [AnimationType]) {
        for animationType in animations {
            addAnimationPlayer(animationType)
        }
    }

    ///Plays an animation if animationType is new
    func playAnimation(_ animationType: AnimationType) {
        //Get and stop the default animation
        guard let defaultAnimationPlayer = animationsNode.animationPlayer(forKey: defaultAnimation.rawValue) else { return }
        let blendDuration: CGFloat = 0.3
        if animationType != defaultAnimation {
            //Stopping withBlendOutDuration prevents node from going back to T-position before playing the next animation
            defaultAnimationPlayer.stop(withBlendOutDuration: blendDuration)
        }
        //Play next animation
        guard let player = animationsNode.animationPlayer(forKey: animationType.rawValue) else {
            LOGDE("Animation played not loaded \(animationType)", from: Fighter.self)
            return
        }
        player.play()
        //Handle end of animation
        if animationType.isKillAnimationType {
            //Pause fighter's animations after playing the kill animation. Reduce duration by 0.2 to not let the fighter stand back up
            runAfterDelay(delay: player.animation.duration - blendDuration) { [weak self] in
                guard let self else { return }
                pauseAnimations()
            }
        } else {
            //At the end of the played animation, resume to default animation if we're not playing it already
            if animationType != defaultAnimation {
                runAfterDelay(delay: player.animation.duration - blendDuration) {
                    defaultAnimationPlayer.play()
                }
            }
        }
    }

    func resumeAnimations() {
        animationsNode.isPaused = false
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
    func createNode() {
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
    func addAnimationPlayer(_ animationType: AnimationType) {
        // Load the dae file for that animation
        let path = fighterType.animationPath(animationType)
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
