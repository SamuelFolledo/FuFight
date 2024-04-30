//
//  Defend.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

enum DefendPosition: Int {
    case forward = 1
    case left = 2
    case backward = 3
    case right = 4
}

protocol DefendProtocol: MoveProtocol {
    ///The percentage amount of damage boost this move adds to attack's damage. 1 is default and 0 means no additional damage increase from this DefendProtocol move
    var damageMultiplier: Double { get }
    ///The percentage amount of speed boost this move adds to attack's speed. 1 is default and means no additional speed increase
    var speedMultiplier: Double { get }
    ///The percentage amount of defense boost this move reduces from incoming damage. 1 is default and means no additional damage reduction. In `0 > x > 1 > y`. In x, meaning values between 0 and 1, will reduce incoming damage. In y, meaning values over 1, will increase incoming damage (e.g. dash forward move)
    var incomingDamageMultiplier: Double { get }
    ///Position of the defense in the view
    var position: DefendPosition { get }
}

struct Defend {
    private(set) var move: any DefendProtocol
    private(set) var currentCooldown: Int = 0
    private(set) var state: MoveButtonState = .initial
    var name: String { move.name }

    init(_ move: any DefendProtocol) {
        self.move = move
    }

    mutating func setStateTo(_ newState: MoveButtonState) {
        state = newState
        switch newState {
        case .cooldown:
            currentCooldown = move.cooldown
        case .initial, .unselected, .selected:
            break
        }
    }

    mutating func reduceCooldown() {
        currentCooldown -= 1
        if currentCooldown <= 0 {
            state = .initial
        }
    }

    mutating func restart() {
        currentCooldown = 0
        setStateTo(.initial)
    }
}
