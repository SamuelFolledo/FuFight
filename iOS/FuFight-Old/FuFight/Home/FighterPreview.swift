//
//  FighterView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/29/24.
//

import SwiftUI
import SceneKit

/// A Preview of fighter
struct FighterPreview: UIViewRepresentable {
    typealias UIViewType = SCNView

    var fighter: FighterType = .samuel
    var animation: FighterAnimationType = .idleStand

    func makeUIView(context: Context) -> UIViewType {
        let view = SCNView()
        view.backgroundColor = UIColor.clear
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        let path = "3DAssets.scnassets/Characters/\(fighter.name)/\(animation.animationPath)"
        view.scene = SCNScene(named: path)
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
