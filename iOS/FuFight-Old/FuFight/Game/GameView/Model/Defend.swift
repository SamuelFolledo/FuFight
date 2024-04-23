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
    ///The percentage amount of damage boost this move adds to attack's damage. 0 means no additional damage increase from this DefendProtocol move
    var damageMultiplier: Double { get }
    ///The percentage amount of speed boost this move adds to attack's speed. 0 means no additional speed increase
    var speedMultiplier: Double { get }
    ///The percentage amount of defense boost this move reduces from incoming damage. 0 means no additional damage reduction
    var defenseMultiplier: Double { get }
    ///Position of the defense in the view
    var position: DefendPosition { get }
}

struct Defend {
    private(set) var move: any DefendProtocol
    private(set) var cooldown: Int = 0
    private(set) var state: MoveButtonState = .initial
    var name: String { move.name }

    init(_ move: any DefendProtocol) {
        self.move = move
    }

    mutating func setStateTo(_ newState: MoveButtonState) {
        state = newState
        switch newState {
        case .cooldown:
            cooldown = move.cooldown
        case .initial, .unselected, .selected:
            break
        }
    }

    mutating func reduceCooldown() {
        cooldown -= 1
        if cooldown <= 0 {
            state = .initial
        }
    }

    mutating func restart() {
        cooldown = 0
        setStateTo(.initial)
    }

    func didDodge(_ enemyAttackPosition: AttackPosition) -> Bool {
        switch move.position {
        case .forward, .backward:
            return false
        case .left:
            return enemyAttackPosition.isLeft
        case .right:
            return !enemyAttackPosition.isLeft
        }
    }
}
