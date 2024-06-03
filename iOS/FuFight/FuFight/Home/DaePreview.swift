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

    init(fighterType: FighterType, animationType: AnimationType) {
        self.fighterType = fighterType
        self.animationType = animationType
    }

    init() {
        self.fighterType = Room.current?.player?.fighterType ?? .samuel
    }

    func makeUIView(context: Context) -> UIViewType {
        let view = SCNView()
        view.backgroundColor = UIColor.clear
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        view.allowsCameraControl = true
        view.defaultCameraController.interactionMode = .orbitTurntable
        view.defaultCameraController.inertiaEnabled = true
        view.defaultCameraController.maximumVerticalAngle = 89
        view.defaultCameraController.minimumVerticalAngle = -89
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        let path = fighterType.animationPath(animationType)
        uiView.scene = SCNScene(named: path)
    }
}
