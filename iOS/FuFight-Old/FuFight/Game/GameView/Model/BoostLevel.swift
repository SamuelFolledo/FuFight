//
//  BoostLevel.swift
//  FuFight
//
//  Created by Samuel Folledo on 4/25/24.
//

import Foundation

enum BoostLevel: Int {
    case none = 0
    case small = 1
    case big = 2

    var fireState: FireState? {
        switch self {
        case .none:
            nil
        case .small:
            .small
        case .big:
            .big
        }
    }

    ///Get the next level when attack lands
    var nextLevel: BoostLevel {
        switch self {
        case .none:
            .small
        case .small:
            .big
        case .big:
            .none
        }
    }
}
