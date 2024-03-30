//
//  GameSceneView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/24/24.
//

import SwiftUI
import SceneKit

///UIView representable for the GameScene and Fighters
struct GameSceneView: UIViewRepresentable {
    @Binding var playerAnimation: FighterAnimationType
    @Binding var enemyAnimation: FighterAnimationType
    @Binding var playerNode: FighterNode
    @Binding var enemyNode: FighterNode

    typealias UIViewType = SCNView
    let scene = SCNScene(named: "3DAssets.scnassets/GameScene.scn")!
    let cameraNode = SCNNode()
    let lightNode = SCNNode()

    init(playerNode: Binding<FighterNode>, playerAnimation: Binding<FighterAnimationType>, enemyNode: Binding<FighterNode>, enemyAnimation: Binding<FighterAnimationType>) {
        self._playerNode = playerNode
        self._playerAnimation = playerAnimation
        self._enemyNode = enemyNode
        self._enemyAnimation = enemyAnimation
    }

    func makeUIView(context: Context) -> UIViewType {
        setUpCamera()
        setUpLight()

        scene.rootNode.addChildNode(playerNode)

        scene.rootNode.addChildNode(enemyNode)

        let sceneView = SCNView()
        //TODO: 1 Set allowsCameraControl to false for production
        // allows the user to manipulate the camera
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene = scene
        return sceneView
    }

    func updateUIView(_ sceneView: UIViewType, context: Context) {
        controlAnimation(playerAnimation, node: playerNode)
    }

    func controlAnimation(_ animationType: FighterAnimationType, node: FighterNode) {
        if animationType != .idle {
            if node == playerNode {
                node.playAnimation(animationType) {
                    playerAnimation = .idle
                }
            }
        }
    }
}

private extension GameSceneView {
    func setUpCamera() {
        // create and add a camera to the scene
        cameraNode.camera = SCNCamera()
        cameraNode.position = .init(x: -5, y: 3.5, z: 3.2) //X: zooms in and out, Y: shifts vertically, Z: horizontal changes
        cameraNode.eulerAngles = .init(x: 0, y: -89.5, z: 0) //X: zooms in and out, Y: rotates horizontally, Z: rotates vertically
        scene.rootNode.addChildNode(cameraNode)
    }

    func setUpLight() {
        lightNode.light = SCNLight()
        lightNode.position = .init(x: -5, y: 3.5, z: 3.2)
        lightNode.eulerAngles = .init(x: 0, y: -89.5, z: 0)
        scene.rootNode.addChildNode(lightNode)

        //TODO: Investigate adding more lights
//        // Create ambient light
//        let ambientLightNode = SCNNode()
//        ambientLightNode.light = SCNLight()
//        ambientLightNode.light!.type = .ambient
//        ambientLightNode.light!.color = UIColor(white: 0.70, alpha: 1.0)
//
//        // Add ambient light to scene
//        scene.rootNode.addChildNode(ambientLightNode)
//
//        // Create directional light
//        let directionalLight = SCNNode()
//        directionalLight.light = SCNLight()
//        directionalLight.light!.type = .directional
//        directionalLight.light!.color = UIColor(white: 1.0, alpha: 1.0)
//        directionalLight.eulerAngles = SCNVector3(x: 0, y: 0, z: 0)
//
//        // Add directional light to camera
//        let cameraNode = sceneView.pointOfView!
//        cameraNode.addChildNode(directionalLight)
    }
}

#Preview("Game's Preview", traits: .portrait) {
    @State var playerAnimation: FighterAnimationType = animationToTest
    @State var playerNode = FighterNode(fighter: Fighter(type: .samuel, isEnemy: false))
    @State var enemyAnimation: FighterAnimationType = animationToTest
    @State var enemyNode = FighterNode(fighter: Fighter(type: .samuel, isEnemy: true))

    return GameSceneView(playerNode: $playerNode, playerAnimation: $playerAnimation, enemyNode: $enemyNode, enemyAnimation: $enemyAnimation)
        .overlay(
            MovesView(attacks: defaultAllPunchAttacks,
                      defenses: defaultAllDashDefenses,
                      sourceType: .user,
                      attackSelected: { attack in
                          switch attack.move.position {
                          case .leftLight:
                              playerNode.playAnimation(.punchHighLightLeft, completion: goToIdle)
                          case .rightLight:
                              playerNode.playAnimation(.punchHighLightRight, completion: goToIdle)
                          case .leftMedium:
                              playerNode.playAnimation(.punchHighMediumLeft, completion: goToIdle)
                          case .rightMedium:
                              playerNode.playAnimation(.punchHighMediumRight, completion: goToIdle)
                          case .leftHard:
                              playerNode.playAnimation(.punchHighHardLeft, completion: goToIdle)
                          case .rightHard:
                              playerNode.playAnimation(.punchHighHardRight, completion: goToIdle)
                          }
                      }, defenseSelected: { defense in
                          switch defense.move.position {
                          case .forward:
                              playerNode.playAnimation(.idle, completion: goToIdle)
                          case .left:
                              playerNode.playAnimation(.idleStand, completion: goToIdle)
                          case .backward:
                              playerNode.playAnimation(.idleTired, completion: goToIdle)
                          case .right:
                              playerNode.playAnimation(.idleStand, completion: goToIdle)
                          }
                      })
        )
        .ignoresSafeArea()

    func goToIdle() {
        playerAnimation = .idle
    }
}
