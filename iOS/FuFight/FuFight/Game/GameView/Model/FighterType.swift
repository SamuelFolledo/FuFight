//
//  Fighter.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/21/24.
//

import Foundation

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
}

