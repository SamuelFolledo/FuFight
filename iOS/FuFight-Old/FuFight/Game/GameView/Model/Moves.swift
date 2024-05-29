//
//  Moves.swift
//  FuFight
//
//  Created by Samuel Folledo on 4/25/24.
//

import SwiftUI

struct Moves {
    let animationTypes: [AnimationType]
    var attacks: [Attack]
    var defenses: [Defense]
    let otherAnimations: [AnimationType] = [.idle, .idleStand, .dodgeHeadLeft, .dodgeHeadRight, .hitHeadRightLight, .hitHeadLeftLight, .hitHeadStraightLight, .hitHeadRightMedium, .hitHeadLeftMedium, .hitHeadStraightMedium, .hitHeadRightHard, .hitHeadLeftHard, .hitHeadStraightHard, .killHeadRightLight, .killHeadLeftLight, .killHeadRightMedium, .killHeadLeftMedium, .killHeadRightHard, .killHeadLeftHard]

    var availableAttacks: [Attack] { attacks.filter{ $0.state != .cooldown } }
    var unavailableAttacks: [Attack] { attacks.filter{ $0.state == .cooldown } }
    var availableDefenses: [Defense] { defenses.filter{ $0.state != .cooldown } }
    var unavailableDefenses: [Defense] { defenses.filter{ $0.state == .cooldown } }
    var selectedAttack: Attack? { attacks.first { $0.state == .selected } }
    var selectedDefense: Defense? { defenses.first { $0.state == .selected } }

    //MARK: Initializers
    init(attacks: [Attack], defenses: [Defense]) {
        self.attacks = attacks
        self.defenses = defenses
        self.animationTypes = attacks.compactMap { $0.animationType } + defenses.compactMap { $0.animationType } + otherAnimations
    }

    //MARK: - Public Methods
    mutating func randomlySelectMoves() {
        //TODO: Remove this auto generated enemy round
        guard let randomAttack = availableAttacks.randomElement() else { return }
        updateSelected(randomAttack.position)
//        let randomDefense: Defense = availableDefenses.randomElement()!
        let randomDefense: Defense = availableDefenses.filter { $0.state != .cooldown }.filter { $0.position == .left || $0.position == .right }.randomElement()!
        updateSelected(randomDefense.position)
    }

    mutating func resetMoves() {
        setStates(to: .initial, shouldForce: true)
        setFireStates(to: .initial)
    }

    mutating func updateAttacksForNextRound(attackLanded: Bool, boostLevel: BoostLevel) {
        if !attackLanded {
            setFireStates(to: .initial)
            setAttacksStateForNextRound()
            return
        }

        let selectedAttackCanBoost: Bool = selectedAttack?.canBoost ?? false
        if !selectedAttackCanBoost {
            setFireStates(to: .initial)
            setAttacksStateForNextRound()
            return
        }

        switch boostLevel {
        case .none:
            setFireStates(to: .initial)
        case .small:
            setFireStates(to: .small)
        case .big:
            setFireStates(to: .big)
        }
        setAttacksStateForNextRound()
    }

    mutating func updateDefensesForNextRound() {
        for i in defenses.indices {
            defenses[i].updateStateForNextRound()
        }
    }

    ///Set the selected attack based on the position, the remaining available attacks will become unselected
    mutating func updateSelected(_ position: AttackPosition) {
        for i in attacks.indices {
            if attacks[i].isAvailable() {
                attacks[i].setState(to: attacks[i].position == position ? .selected : .unselected)
            }
        }
    }

    ///Set the selected defense based on the position, the remaining available defense will become unselected
    mutating func updateSelected(_ position: DefensePosition) {
        for i in defenses.indices {
            if defenses[i].isAvailable() {
                defenses[i].setState(to: defenses[i].position == position ? .selected : .unselected)
            }
        }
    }

    mutating func toggleType(at position: AttackPosition) {
        for i in attacks.indices {
            let currentAttack = attacks[i]
            if currentAttack.position == position {
                attacks[i].toggleAttackType(at: currentAttack.position)
                break
            }
        }
    }
}

private extension Moves {
    mutating func setAttacksStateForNextRound() {
        for i in attacks.indices {
            attacks[i].updateStateForNextRound()
        }
    }

    /// - parameter shouldForce: if true, forces the states to the newState.
    mutating func setStates(to newState: MoveButtonState, shouldForce: Bool = false) {
        setAttackStates(to: newState, shouldForce: shouldForce)
        setDefenseStates(to: newState, shouldForce: shouldForce)
    }

    /// - parameter shouldForce: if true, forces the states to the newState.
    mutating func setDefenseStates(to newState: MoveButtonState, shouldForce: Bool = false) {
        for i in defenses.indices {
            if shouldForce || defenses[i].isAvailable() {
                defenses[i].setState(to: newState)
            }
        }
    }

    /// - parameter shouldForce: if true, forces the states to the newState.
    mutating func setAttackStates(to newState: MoveButtonState, shouldForce: Bool = false) {
        for i in attacks.indices {
            if shouldForce || attacks[i].isAvailable() {
                attacks[i].setState(to: newState)
            }
        }
    }

    mutating func setFireStates(to fireState: FireState) {
        switch fireState {
        case .initial, .big:
            for i in attacks.indices {
                if attacks[i].isAvailableNextRound {
                    attacks[i].setFireState(to: fireState)
                }
            }
        case .small:
            setToSmallFireStates()
        }
    }

    mutating func setToSmallFireStates() {
        for i in attacks.indices {
            switch attacks[i].position {
            case .leftLight, .rightLight, .leftMedium, .rightMedium:
                //If attack can boost, set it to small fire, else big fire
                attacks[i].setFireState(to: attacks[i].canBoost ? .small : .big)
            case .leftHard, .rightHard:
                //Do not boost the hard attacks to small boost
                attacks[i].setFireState(to: .initial)
            }

        }
    }
}

//MARK: - Decodable extension
extension Moves: Codable {
    private enum CodingKeys : String, CodingKey {
        case attacks = "attacks"
        case defenses = "defenses"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(attacks, forKey: .attacks)
        try container.encode(defenses, forKey: .defenses)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let attacks = try values.decodeIfPresent([Attack].self, forKey: .attacks)!
        let defenses = try values.decodeIfPresent([Defense].self, forKey: .defenses)!
        self.init(attacks: attacks, defenses: defenses)
    }
}
