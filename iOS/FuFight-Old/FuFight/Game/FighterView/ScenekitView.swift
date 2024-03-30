//
//  ScenekitView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/24/24.
//

import SwiftUI
import SceneKit

struct ScenekitView: UIViewRepresentable {
    typealias UIViewType = SCNView
    @Binding var animation: FighterAnimationType

    let scene = SCNScene(named: "3DAssets.scnassets/GameScene.scn")!
    @Binding var playerNode: FighterNode
    @Binding var enemyNode: FighterNode
    let cameraNode = SCNNode()
    let lightNode = SCNNode()

    init(animation: Binding<FighterAnimationType>, playerNode: Binding<FighterNode>, enemyNode: Binding<FighterNode>) {
        self._animation = animation
        self._playerNode = playerNode
        self._enemyNode = enemyNode
    }

    func makeUIView(context: Context) -> UIViewType {
        setUpCamera()
        setUpLight()

        scene.rootNode.addChildNode(playerNode)

        scene.rootNode.addChildNode(enemyNode)
        let scnView = SCNView()
        return scnView
    }

    func updateUIView(_ sceneView: UIViewType, context: Context) {
        sceneView.scene = scene

        // allows the user to manipulate the camera
        //TODO: 1 Set allowsCameraControl to false for production
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        controlAnimation(animation, node: playerNode)
    }

    func controlAnimation(_ animationType: FighterAnimationType, node: FighterNode) {
//        LOGD("333 Playing \(animationType.rawValue)--")
        if node == playerNode {
            node.playAnimation(animationType) //TODO: Load other animations and test changing animation
        }
    }
}

private extension ScenekitView {
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
    @State var animationType: FighterAnimationType = animationToTest
    @State var playerNode = FighterNode(fighter: Fighter(type: .samuel, isEnemy: false))
    @State var enemyNode = FighterNode(fighter: Fighter(type: .samuel, isEnemy: true))

    return ScenekitView(animation: $animationType, playerNode: $playerNode, enemyNode: $enemyNode)
        .overlay(
            MovesView(attacks: defaultAllPunchAttacks,
                      defenses: defaultAllDashDefenses,
                      sourceType: .user,
                      attackSelected: { attack in
                          switch attack.move.position {
                          case .leftLight:
                              playerNode.playAnimation(.punchHighLightLeft)
                          case .rightLight:
                              playerNode.playAnimation(.punchHighLightRight)
                          case .leftMedium:
                              playerNode.playAnimation(.punchHighMediumLeft)
                          case .rightMedium:
                              playerNode.playAnimation(.punchHighMediumRight)
                          case .leftHard:
                              playerNode.playAnimation(.punchHighHardLeft)
                          case .rightHard:
                              playerNode.playAnimation(.punchHighHardRight)
                          }
                      }, defenseSelected: { defense in
                          switch defense.move.position {
                          case .forward:
                              playerNode.playAnimation(.idle)
                          case .left:
                              playerNode.playAnimation(.idleStand)
                          case .backward:
                              playerNode.playAnimation(.idleTired)
                          case .right:
                              playerNode.playAnimation(.idleStand)
                          }
                      })
        )
        .ignoresSafeArea()
}
