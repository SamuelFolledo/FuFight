//
//  FighterBodyPartType.swift
//  FuFight
//
//  Created by Samuel Folledo on 4/9/24.
//

import SceneKit

///Set this to false to make fighter named Samuel to have a transparent blue glasses instead
let isBlackGlasses = true

enum FighterBodyPartType: String {
    case facialHair = "face-001"
    case body = "M_MED_Cat_Burglar-mo"
    case glassesLens = "glases_-003"
    case glassesFrame = "glases_-002"
    case hair = "male01_Mat_male01__bodny_bmp_0-001"
    case head = "face-002"

    var name: String {
        switch self {
        case .facialHair:
            "facial hair"
        case .body:
            "body"
        case .glassesLens:
            "lens"
        case .glassesFrame:
            "frame"
        case .hair:
            "hair"
        case .head:
            "head"
        }
    }

    var diffusedImagePath: String {
        let path =                 "3DAssets.scnassets/Characters/Samuel/assets/"
        switch self {
        case .facialHair:
            return path + "samuelFacialHair"
        case .body:
            return path + "samuelBody"
        case .glassesLens:
            return path + "samuelGlasses"
        case .glassesFrame:
            return path + "samuelGlasses"
        case .hair:
            return path + "samuelHair"
        case .head:
            return path + "samuelFace"
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
        case .glassesLens:
            isBlackGlasses ? UIColor.black : UIColor(red: 0, green: 0, blue: 0, alpha: 0.27)
        case .facialHair, .body, .glassesFrame, .hair, .head:
                .black
        }
    }

    var material: SCNMaterial {
        let material = SCNMaterial()
        material.name = name
        switch self {
        case .glassesLens:
            material.diffuse.contents = isBlackGlasses ? UIColor.black : imageMaterial
        case .facialHair, .body, .glassesFrame, .hair, .head:
            material.diffuse.contents = imageMaterial
        }
        material.transparent.contents = transparentMaterial
        return material
    }
}
