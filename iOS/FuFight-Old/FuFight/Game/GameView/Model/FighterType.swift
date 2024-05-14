//
//  Fighter.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/21/24.
//

import Foundation

enum FighterType {
    case samuel, clara

    var daeUrl: URL? {
        return Bundle.main.url(forResource: defaultDaePath, withExtension: "dae")
    }

    var defaultDaePath: String {
        switch self {
        case .samuel:
//            return "3DAssets.scnassets/Characters/Samuel/assets/samuel"
            animationPath(.idle)
        case .clara:
            animationPath(.idle)
        }
    }

    var name: String {
        switch self {
        case .samuel:
            "Samuel"
        case .clara:
            "Clara"
        }
    }

    var bonesName: String {
        switch self {
        case .samuel:
            "Armature"
        case .clara:
            "Armature-001"
        }
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

