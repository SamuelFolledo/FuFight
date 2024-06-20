//
//  DaePreview.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/29/24.
//

import SwiftUI
import SceneKit

/// A Preview of fighter
struct DaePreview: UIViewRepresentable {
    typealias UIViewType = SCNView

    var fighterType: FighterType = .samuel
    var animationType: AnimationType = .idle
    var scene: SCNScene

    private let cameraNode = SCNNode()

    init(fighterType: FighterType, animationType: AnimationType) {
        self.fighterType = fighterType
        self.animationType = animationType
        self.scene = SCNScene(named: fighterType.animationPath(.idle))!
    }

    init() {
        self.fighterType = Room.current?.player.fighterType ?? .samuel
        self.scene = SCNScene(named: fighterType.animationPath(.idle))!
    }

    func makeUIView(context: Context) -> UIViewType {
        let view = SCNView()
        view.backgroundColor = UIColor.clear
        view.autoenablesDefaultLighting = true
        view.allowsCameraControl = true
        view.scene = scene
        setUpCamera()
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        let path = fighterType.animationPath(animationType)
        uiView.scene = SCNScene(named: path)
    }
}

extension DaePreview {
    func setUpCamera() {
        // Using default camera
//        view.defaultCameraController.interactionMode = .orbitTurntable
//        view.defaultCameraController.inertiaEnabled = true
//        view.defaultCameraController.maximumVerticalAngle = 89
//        view.defaultCameraController.minimumVerticalAngle = -89
        
        // Using custom camera
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 9
        camera.zNear = 0
        camera.zFar = 100
        let cameraNode = SCNNode()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        cameraNode.camera = camera
        let cameraOrbit = SCNNode()
        cameraOrbit.addChildNode(cameraNode)
        scene.rootNode.addChildNode(cameraOrbit)
    }
}
