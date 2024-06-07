//
//  GameState.swift
//  FuFight
//
//  Created by Samuel Folledo on 6/6/24.
//

import Foundation

enum GameState {
    case starting
    case gaming
    case gameOver

    var isGameOver: Bool {
        switch self {
        case .starting, .gaming:
            false
        case .gameOver:
            true
        }
    }
}
