//
//  Fighter.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/21/24.
//

import Foundation
import SceneKit

enum FighterType: String, CaseIterable, Identifiable {
    case samuel, clara

    var id: String { rawValue }

    var name: String {
        switch self {
        case .samuel:
            "Samuel"
        case .clara:
            "Clara"
        }
    }

    var headShotImageName: String {
        "\(rawValue)HeadShot"
    }

    var bonesName: String {
        switch self {
        case .samuel:
            "Armature"
        case .clara:
            "Armature-001"
        }
    }

    var daeUrl: URL? {
        return Bundle.main.url(forResource: defaultDaePath, withExtension: "dae")
    }

    var defaultDaePath: String {
        "3DAssets.scnassets/Characters/\(name)/assets/\(name.lowercased())"
    }

    var scale: Float {
        switch self {
        case .samuel:
            0.02
        case .clara:
            0.02
        }
    }

    func animationPath(_ animationType: AnimationType) -> String {
        "3DAssets.scnassets/Characters/\(name)/\(animationType.animationPath)"
    }

    func animationUrl(_ animationType: AnimationType) -> URL? {
        return Bundle.main.url(forResource: animationPath(animationType), withExtension: "dae")
    }

    func getMaterial(for skeletonType: SkeletonType) -> SCNMaterial {
        let material = SCNMaterial()
        material.name = skeletonType.name
        switch skeletonType {
        case .samuelGlassesLens:
            material.diffuse.contents = isBlackGlasses ? UIColor.black : imageMaterial(for: skeletonType)
            material.transparent.contents = transparentMaterial(for: skeletonType)
        case .samuelFacialHair, .samuelBody, .samuelGlassesFrame, .samuelHair, .samuelHead, .claraBody:
            material.diffuse.contents = imageMaterial(for: skeletonType)
            material.transparent.contents = transparentMaterial(for: skeletonType)
        }
        return material
    }
}

private extension FighterType {
    func diffusedImagePath(for skeletonType: SkeletonType) -> String {
        let path = "3DAssets.scnassets/Characters/\(name)/assets/"
        switch skeletonType {
        case .samuelFacialHair:
            return path + "samuelFacialHair"
        case .samuelBody:
            return path + "samuelBody"
        case .samuelGlassesLens:
            return path + "samuelGlasses"
        case .samuelGlassesFrame:
            return path + "samuelGlasses"
        case .samuelHair:
            return path + "samuelHair"
        case .samuelHead:
            return path + "samuelFace"
        case .claraBody:
            return path + "ClaraFullTexture"
        }
    }

    func imageMaterial(for skeletonType: SkeletonType) -> UIImage? {
        if let url = Bundle.main.url(forResource: diffusedImagePath(for: skeletonType), withExtension: "png"),
           let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }

    func transparentMaterial(for skeletonType: SkeletonType) -> UIColor {
        switch skeletonType {
        case .samuelGlassesLens:
            isBlackGlasses ? UIColor.black : UIColor(red: 0, green: 0, blue: 0, alpha: 0.27)
        case .samuelFacialHair, .samuelBody, .samuelGlassesFrame, .samuelHair, .samuelHead, .claraBody:
                .black
        }
    }
}
