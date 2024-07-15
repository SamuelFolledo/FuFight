//
//  GameType.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/10/24.
//

import SwiftUI

//MARK: - GameType
enum GameType: String, CaseIterable, Hashable, Identifiable {
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

    var requiresWifi: Bool {
        switch self {
        case .offline:
            false
        case .casual, .rank:
            true
        }
    }

    var id: String { rawValue }

    static func == (lhs: GameType, rhs: GameType) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
