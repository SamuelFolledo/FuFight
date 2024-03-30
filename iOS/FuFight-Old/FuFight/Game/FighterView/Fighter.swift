//
//  Fighter.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/21/24.
//

import Foundation

enum FighterType {
    case samuel, bianca

    var daeUrl: URL? {
        return Bundle.main.url(forResource: defaultDaePath, withExtension: "dae")
    }

    var defaultDaePath: String {
        switch self {
        case .samuel:
//            return "3DAssets.scnassets/Characters/Samuel/assets/samuel"
            return "3DAssets.scnassets/Characters/\(name)/\(FighterAnimationType.idle.animationPath)"
        case .bianca:
            return "3DAssets.scnassets/Characters/\(name)/\(FighterAnimationType.idle.animationPath)"
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

    func animationUrl(_ animationType: FighterAnimationType) -> URL? {
        let path = "3DAssets.scnassets/Characters/\(name)/\(animationType.animationPath)"
        return Bundle.main.url(forResource: path, withExtension: "dae")
    }
}

class Fighter {
    var type: FighterType
    var isEnemy: Bool
    var animations: [FightAnimation] = []

    var name: String { type.name }
    var postFix: String { isEnemy ? "Back" : "Front" }
    ///for 2D
    var idleImageName: String { "\(name)-idle\(postFix)" }
    ///for 2D
    var dodgeImageName: String { "\(name)-dodge\(postFix)" }

    init(type: FighterType, isEnemy: Bool) {
        self.type = type
        self.isEnemy = isEnemy
    }
}
