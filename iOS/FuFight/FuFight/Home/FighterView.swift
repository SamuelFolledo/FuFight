//
//  FighterView.swift
//  FuFight
//
//  Created by Samuel Folledo on 6/19/24.
//

import SwiftUI
import SceneKit

/// A Preview of fighter
struct FighterView: UIViewRepresentable {
    typealias UIViewType = SCNView

    var fighter: Fighter

    var scene = SCNScene()
    let cameraNode = SCNNode()

    init(_ fighter: Fighter) {
        self.fighter = fighter
    }

    func makeUIView(context: Context) -> UIViewType {
        let view = SCNView()
        view.backgroundColor = UIColor.clear
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        setUpCamera()
        setUpFighter()
        view.scene = scene
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

extension FighterView {
    func setUpCamera() {
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 4
        camera.zNear = 0
        camera.zFar = 100
        let cameraNode = SCNNode()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        cameraNode.camera = camera
        let cameraOrbit = SCNNode()
        cameraOrbit.addChildNode(cameraNode)
        scene.rootNode.addChildNode(cameraOrbit)
    }

    func setUpFighter() {
        scene.rootNode.addChildNode(fighter.daeHolderNode)
        fighter.daeHolderNode.position = SCNVector3Make(0, -2, -1)
        fighter.daeHolderNode.scale = .init(x: fighter.fighterType.scale, y: fighter.fighterType.scale, z: fighter.fighterType.scale)
        fighter.playAnimation(fighter.defaultAnimation)
    }
}

#Preview("FighterView", traits: .portrait) {
    let fighter = Fighter(type: .samuel, isEnemy: false)

    return FighterView(fighter)
        .ignoresSafeArea()
        .onTapGesture {
            fighter.playAnimation(.punchHeadLeftHard)
        }
}
