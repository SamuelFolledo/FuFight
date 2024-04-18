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
    @Binding var fighter: Fighter
    @Binding var enemyFighter: Fighter

    typealias UIViewType = SCNView
    let scene = SCNScene(named: "3DAssets.scnassets/GameScene.scn")!
    let cameraNode = SCNNode()
    let lightNode = SCNNode()

    init(fighter: Binding<Fighter>, enemyFighter: Binding<Fighter>) {
        self._fighter = fighter
        self._enemyFighter = enemyFighter
    }

    func makeUIView(context: Context) -> UIViewType {
        setUpCamera()
        setUpLight()
        setUpFighters()

        let sceneView = SCNView()
        //TODO: 1 Set allowsCameraControl to false for production
        // allows the user to manipulate the camera
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene = scene
        return sceneView
    }

    func updateUIView(_ sceneView: UIViewType, context: Context) {}
}

private extension GameSceneView {
    func setUpFighters() {
        scene.rootNode.addChildNode(fighter.daeHolderNode)
        fighter.positionNode(asEnemy: false)
        scene.rootNode.addChildNode(enemyFighter.daeHolderNode)
        enemyFighter.positionNode(asEnemy: true)
    }

    func setUpCamera() {
        // create and add a camera to the scene
        cameraNode.camera = SCNCamera()
        cameraNode.position = .init(x: -6, y: 4, z: 3.2) //X: zooms in and out, Y: shifts vertically, Z: horizontal changes
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
    @State var playerAnimation: AnimationType = animationToTest
    @State var fighter = Fighter(type: .samuel, isEnemy: false)
    @State var enemyAnimation: AnimationType = animationToTest
    @State var enemyFighter = Fighter(type: .samuel, isEnemy: true)

    return GameSceneView(fighter: $fighter, enemyFighter: $enemyFighter)
        .overlay(
            MovesView(attacks: defaultAllPunchAttacks,
                      defenses: defaultAllDashDefenses,
                      sourceType: .user,
                      attackSelected: { attack in
                          switch attack.move.position {
                          case .leftLight:
                              fighter.playAnimation(.punchHeadLeftLight)
                          case .rightLight:
                              fighter.playAnimation(.punchHeadRightLight)
                          case .leftMedium:
                              fighter.playAnimation(.punchHeadLeftMedium)
                          case .rightMedium:
                              fighter.playAnimation(.punchHeadRightMedium)
                          case .leftHard:
                              fighter.playAnimation(.punchHeadLeftHard)
                          case .rightHard:
                              fighter.playAnimation(.punchHeadRightHard)
                          }
                      }, defenseSelected: { defense in
                          switch defense.move.position {
                          case .forward:
                              fighter.playAnimation(.idleStand)
                          case .left:
                              fighter.playAnimation(.idle)
                          case .backward:
                              fighter.playAnimation(.idleStand)
                          case .right:
                              fighter.playAnimation(.idle)
                          }
                      })
        )
        .ignoresSafeArea()
}
