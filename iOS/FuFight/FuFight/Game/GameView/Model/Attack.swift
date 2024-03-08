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
}

enum AttackButtonState: Int {
    case initial = 0
    case unselected = 1
    case selected = 2
    case cooldown = 3
    case smallFire = 4
    case bigFire = 5

    var opacity: CGFloat {
        switch self {
        case .cooldown:
            0.5
        case .selected:
            0.75
        case .initial, .unselected, .smallFire, .bigFire:
            1
        }
    }

    var blurRadius: CGFloat {
        switch self {
        case .cooldown:
            2
        case .selected, .initial, .unselected, .smallFire, .bigFire:
            0
        }
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
}


struct Attack {
    private(set) var move: any AttackProtocol
    private(set) var cooldown: Int = 0
    private(set) var state: AttackButtonState = .initial

    init(_ move: any AttackProtocol) {
        self.move = move
    }

    mutating func setStateTo(_ newState: AttackButtonState) {
        state = newState
        switch newState {
        case .cooldown:
            cooldown = move.cooldown
        case .initial, .unselected, .selected, .smallFire, .bigFire:
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
}
