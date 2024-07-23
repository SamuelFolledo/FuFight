//
//  RoomButtonType.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/23/24.
//

import Foundation

enum RoomButtonType: String, CaseIterable {
    case all
    case owned
    case unowned

    var text: String {
        switch self {
        case .all:
            "All"
        case .owned:
            "Owned"
        case .unowned:
            "Unowned"
        }
    }

    var idx: Int {
        switch self {
        case .all:
            0
        case .owned:
            1
        case .unowned:
            2
        }
    }
}
