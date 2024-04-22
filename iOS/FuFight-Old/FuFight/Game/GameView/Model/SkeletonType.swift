//
//  SkeletonType.swift
//  FuFight
//
//  Created by Samuel Folledo on 4/9/24.
//

import SceneKit

///Set this to false to make fighter named Samuel to have a transparent blue glasses instead
let isBlackGlasses = true

enum SkeletonType: String {
    //MARK: Bianca's skeletons
    case biancaBody = "body-003"

    //MARK: Samuel's skeletons
    case samuelFacialHair = "face-001"
    case samuelBody = "M_MED_Cat_Burglar-mo"
    case samuelGlassesLens = "glases_-003"
    case samuelGlassesFrame = "glases_-002"
    case samuelHair = "male01_Mat_male01__bodny_bmp_0-001"
    case samuelHead = "face-002"

    var name: String {
        switch self {
        case .biancaBody:
            "bianca body"
        case .samuelFacialHair:
            "facial hair"
        case .samuelBody:
            "samuel body"
        case .samuelGlassesLens:
            "lens"
        case .samuelGlassesFrame:
            "frame"
        case .samuelHair:
            "hair"
        case .samuelHead:
            "head"
        }
    }

    var diffusedImagePath: String {
        let fighterName = self == .biancaBody ? "Bianca" : "Samuel"
        let path = "3DAssets.scnassets/Characters/\(fighterName)/assets/"
        switch self {
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
        case .biancaBody:
            return path + "BiancaFullTexture"
        }
    }

    var imageMaterial: UIImage? {
        if let url = Bundle.main.url(forResource: diffusedImagePath, withExtension: "png"),
           let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }

    var transparentMaterial: UIColor {
        switch self {
        case .samuelGlassesLens:
            isBlackGlasses ? UIColor.black : UIColor(red: 0, green: 0, blue: 0, alpha: 0.27)
        case .samuelFacialHair, .samuelBody, .samuelGlassesFrame, .samuelHair, .samuelHead, .biancaBody:
                .black
        }
    }

    var material: SCNMaterial {
        let material = SCNMaterial()
        material.name = name
        switch self {
        case .samuelGlassesLens:
            material.diffuse.contents = isBlackGlasses ? UIColor.black : imageMaterial
        case .samuelFacialHair, .samuelBody, .samuelGlassesFrame, .samuelHair, .samuelHead, .biancaBody:
            material.diffuse.contents = imageMaterial
        }
        material.transparent.contents = transparentMaterial
        return material
    }
}
