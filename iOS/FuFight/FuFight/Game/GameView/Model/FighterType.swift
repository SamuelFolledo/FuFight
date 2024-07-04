//
//  Fighter.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/21/24.
//

import Foundation
import SceneKit

enum FighterType: String, CaseIterable, Identifiable {
    case samuel
    case clara
    case kim
    case deeJay
    case jad
    case ruby
    case cain
    case andrew
    case corey
    case alexis
//    case marco
    case neverRight

    var id: String { rawValue }

    var name: String {
        switch self {
        case .samuel:
            "Samuel"
        case .clara:
            "Clara"
        case .kim:
            "Kim"
        case .deeJay:
            "Dee Jay"
        case .jad:
            "Jad"
        case .ruby:
            "Ruby"
        case .cain:
            "Cain"
        case .andrew:
            "Andrew"
        case .corey:
            "Corey"
        case .alexis:
            "Alexis"
//        case .marco:
//            "Marco"
        case .neverRight:
            "Never Right"
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
        case .andrew:
            "mixamorig1_Hips"
        case .alexis:
            "mixamorig6_Hips"
        case .jad:
            "mixamorig7_Hips"
        case .corey:
            "mixamorig10_Hips"
        case .ruby, .kim, .deeJay, .cain, .neverRight:
            "mixamorig_Hips"
        }
    }

    var scale: Float {
        switch self {
        case .neverRight:
            0.018
        default:
            0.02
        }
    }

    var daeUrl: URL? {
        return Bundle.main.url(forResource: defaultDaePath, withExtension: "dae")
    }

    var path: String {
        "3DAssets.scnassets/Characters/\(name)"
    }

    private var assetsPath: String {
        "\(path)/assets/"
    }
    private var animationsPath: String {
        "\(path)/animations/"
    }

    var defaultDaePath: String {
        "\(assetsPath)\(rawValue)"
    }

    //MARK: - Public Methods
    func animationPath(_ animationType: AnimationType) -> String {
        "\(path)/\(animationType.animationPath)"
    }

    func getMaterial(for skeletonType: SkeletonType) -> SCNMaterial {
        let material = SCNMaterial()
        material.name = skeletonType.name
        material.diffuse.contents = diffusedMaterial(for: skeletonType)
        material.specular.contents = specularMaterial(for: skeletonType)
        material.transparent.contents = transparentMaterial(for: skeletonType)
        return material
    }
}

private extension FighterType {
    func diffusedMaterial(for skeletonType: SkeletonType) -> Any? {
        switch skeletonType {
        case .samuelGlassesLens:
            //Make samuel's glasses black
            return isBlackGlasses ? UIColor.black : UIColor(red: 0, green: 0, blue: 0, alpha: 0.27)
        default:
            if let url = Bundle.main.url(forResource: "\(assetsPath)\(skeletonType.diffuseImageName)", withExtension: "png"),
               let data = try? Data(contentsOf: url) {
                return UIImage(data: data)
            }
        }
        LOGDE("No diffused material found for \(skeletonType)")
        return nil
    }

    func specularMaterial(for skeletonType: SkeletonType) -> Any? {
        if let imageName = skeletonType.specularImageName,
           let url = Bundle.main.url(forResource: "\(assetsPath)\(imageName)", withExtension: "png"),
           let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return UIColor.black
    }

    func transparentMaterial(for skeletonType: SkeletonType) -> Any? {
        if let imageName = skeletonType.transparentImageName,
           let url = Bundle.main.url(forResource: "\(assetsPath)\(imageName)", withExtension: "png"),
           let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return UIColor.black
    }
}
