//
//  HomeButtonType.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/11/24.
//

import SwiftUI

enum HomeButtonType: String, CaseIterable {
    case leading1
    case leading2
    case leading3
    case trailing1
    case trailing2
    case trailing3

    var iconName: String {
        switch self {
        case .leading1, .leading2, .leading3:
            "coin"
        case .trailing1, .trailing2, .trailing3:
            "diamond"
        }
    }

    var position: Position {
        switch self {
        case .leading1, .leading2, .leading3:
                .leading
        case .trailing1, .trailing2, .trailing3:
                .trailing
        }
    }
}

extension HomeButtonType: Hashable, Identifiable {
    var id: String { rawValue }

    static func == (lhs: HomeButtonType, rhs: HomeButtonType) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}

extension HomeButtonType {
    enum Position {
        case leading
        case trailing

        var edge: Edge {
            switch self {
            case .leading:
                    .leading
            case .trailing:
                    .trailing
            }
        }
        var edgeSet: Edge.Set {
            switch self {
            case .leading:
                    .leading
            case .trailing:
                    .trailing
            }
        }
    }
}
