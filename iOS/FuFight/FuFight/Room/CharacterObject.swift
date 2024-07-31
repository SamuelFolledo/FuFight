//
//  Character.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/5/24.
//

import Foundation

enum PurchaseStatus: Int {
    case upcoming
    case locked
    case unlocked
    case selected

    var sortOrder: Int {
        switch self {
        case .upcoming:
            2
        case .locked:
            1
        case .unlocked:
            0
        case .selected:
            0
        }
    }
}

class CharacterObject {
    var fighterType: FighterType
    var status: PurchaseStatus

    init(fighterType: FighterType) {
        self.fighterType = fighterType
        if !fighterType.isReleased {
            self.status = .upcoming
        } else {
            self.status = RoomManager.isPurchased(fighterType) ? .unlocked : .locked
        }
    }
}

extension CharacterObject: Identifiable, Hashable, Comparable {
    var id: String { fighterType.rawValue }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    static func == (lhs: CharacterObject, rhs: CharacterObject) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: CharacterObject, rhs: CharacterObject) -> Bool {
        return lhs.status.sortOrder < rhs.status.sortOrder
    }
}
