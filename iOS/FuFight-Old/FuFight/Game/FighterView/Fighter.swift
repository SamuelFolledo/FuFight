//
//  Fighter.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/21/24.
//

import Foundation

class Fighter {
    var isEnemy: Bool
    var node: FighterNode!

    var name: String { node.type.name }

    init(type: FighterType, isEnemy: Bool) {
        self.isEnemy = isEnemy
        self.node = FighterNode(type: type, isEnemy: isEnemy)
    }
}

enum FighterType {
    case samuel, bianca

    var daeUrl: URL? {
        return Bundle.main.url(forResource: defaultDaePath, withExtension: "dae")
    }

    var defaultDaePath: String {
        switch self {
        case .samuel:
//            return "3DAssets.scnassets/Characters/Samuel/assets/samuel"
            animationPath(.idle)
        case .bianca:
            animationPath(.idle)
        }
    }

    var name: String {
        switch self {
        case .samuel:
            "Samuel"
        case .bianca:
            "Bianca"
        }
    }

    var fileName: String {
        name.lowercased()
    }

    var bonesName: String {
        switch self {
        case .samuel:
            "Armature"
        case .bianca:
            "Armature-001"
        }
    }

    var scale: Float {
        switch self {
        case .samuel:
            0.02
        case .bianca:
            0.02
        }
    }

    func animationPath(_ animationType: FighterAnimationType) -> String {
        "3DAssets.scnassets/Characters/\(name)/\(animationType.animationPath)"
    }

    func animationUrl(_ animationType: FighterAnimationType) -> URL? {
        return Bundle.main.url(forResource: animationPath(animationType), withExtension: "dae")
    }
}

