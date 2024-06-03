//
//  FireState.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/5/24.
//

import Foundation

enum FireState {
    case initial
    case small
    case big

    var boostMultiplier: CGFloat {
        switch self {
        case .initial:
            1
        case .small:
            1.2
        case .big:
            1.35
        }
    }
}
