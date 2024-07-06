//
//  Character.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/5/24.
//

import Foundation

struct CharacterObject: Identifiable, Hashable {
    var fighterType: FighterType

    var id: String { fighterType.rawValue }

    static func == (lhs: CharacterObject, rhs: CharacterObject) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
