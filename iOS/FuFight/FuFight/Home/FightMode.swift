//
//  FightMode.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/10/24.
//

import SwiftUI

enum FightMode: String, CaseIterable {
    case offline
    case casual
    case rank

    var color: Color? {
        switch self {
        case .offline:
            .gray
        case .casual:
            nil
        case .rank:
            .mint
        }
    }
}

extension FightMode: Hashable, Identifiable {
    var id: String { rawValue }

    static func == (lhs: FightMode, rhs: FightMode) -> Bool {
        return lhs.id == lhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
