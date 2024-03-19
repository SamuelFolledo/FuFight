//
//  Attack.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

enum AttackPosition: Int {
    case leftLight = 1
    case rightLight = 2
    case leftMedium = 3
    case rightMedium = 4
    case leftHard = 5
    case rightHard = 6

    var isLeft: Bool {
        return rawValue % 2 == 1
    }
}

protocol AttackProtocol: MoveProtocol {
    ///The base damage of this attack
    var damage: Double { get }
    ///How fast this attack is and will determine who goes first
    var speed: Double { get }
    ///The percentage amount of damage reduction this attack will apply to the enemy. 0 will not reduce any attack, 1 will fully remove the damage of the next attack
    var damageReduction: Double { get }
    ///Position of the attack in the view
    var position: AttackPosition { get }
    ///Returns true if attack can increase next attack's damage. If true, these attacks can be slightly boosted indicated with small fire
    var canBoost: Bool { get }
}


struct Attack {
    private(set) var move: any AttackProtocol
    ///Attack's current cooldown
    private(set) var cooldown: Int = 0
    private(set) var state: MoveButtonState = .initial
    private(set) var fireState: FireState? = nil
    var isAvailableNextTurn: Bool {
        return cooldown <= 1
    }

    init(_ move: any AttackProtocol) {
        self.move = move
    }

    mutating func setStateTo(_ newState: MoveButtonState) {
        state = newState
        switch newState {
        case .cooldown:
            cooldown = move.cooldown
        case .unselected, .selected:
            break
        case .initial:
            break
        }
    }

    mutating func reduceCooldown() {
        cooldown -= 1
        if cooldown <= 0 {
            setStateTo(.initial)
        }
    }

    mutating func restart() {
        cooldown = 0
        setStateTo(.initial)
        setFireTo(nil)
    }

    mutating func setFireTo(_ newFireState: FireState?) {
        self.fireState = newFireState
    }
}

enum FireState {
    case small
    case big

    var boostMultiplier: CGFloat {
        switch self {
        case .small:
            0.2
        case .big:
            0.35
        }
    }
}
