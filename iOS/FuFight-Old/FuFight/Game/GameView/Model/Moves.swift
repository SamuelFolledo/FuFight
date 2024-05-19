//
//  Moves.swift
//  FuFight
//
//  Created by Samuel Folledo on 4/25/24.
//

import SwiftUI

struct Moves {
    private(set) var leftLightAttack: Attack
    private(set) var rightLightAttack: Attack
    private(set) var leftMediumAttack: Attack
    private(set) var rightMediumAttack: Attack
    private(set) var leftHardAttack: Attack
    private(set) var rightHardAttack: Attack

    private(set) var forwardDefense: Defense
    private(set) var leftDefense: Defense
    private(set) var backwardDefense: Defense
    private(set) var rightDefense: Defense

    let animationTypes: [AnimationType]

    let otherAnimations: [AnimationType] = [.idle, .idleStand, .dodgeHeadLeft, .dodgeHeadRight, .hitHeadRightLight, .hitHeadLeftLight, .hitHeadStraightLight, .hitHeadRightMedium, .hitHeadLeftMedium, .hitHeadStraightMedium, .hitHeadRightHard, .hitHeadLeftHard, .hitHeadStraightHard, .killHeadRightLight, .killHeadLeftLight, .killHeadRightMedium, .killHeadLeftMedium, .killHeadRightHard, .killHeadLeftHard]
    var attacks: [Attack] {
        [leftLightAttack, leftMediumAttack, leftHardAttack, rightLightAttack, rightMediumAttack, rightHardAttack]
    }
    var defenses: [Defense] {
        [forwardDefense, leftDefense, rightDefense, backwardDefense]
    }
    var availableAttacks: [Attack] { attacks.filter{ $0.state != .cooldown } }
    var unavailableAttacks: [Attack] { attacks.filter{ $0.state == .cooldown } }
    var availableDefenses: [Defense] { defenses.filter{ $0.state != .cooldown } }
    var unavailableDefenses: [Defense] { defenses.filter{ $0.state == .cooldown } }
    var selectedAttack: Attack? { attacks.first { $0.state == .selected } }
    var selectedDefense: Defense? { defenses.first { $0.state == .selected } }

    //MARK: Initializers
    init(attacks: [Attack], defenses: [Defense]) {
        self.leftLightAttack = attacks.first { $0.position == .leftLight }!
        self.rightLightAttack = attacks.first { $0.position == .rightLight }!
        self.leftMediumAttack = attacks.first { $0.position == .leftMedium }!
        self.rightMediumAttack = attacks.first { $0.position == .rightMedium }!
        self.leftHardAttack = attacks.first { $0.position == .leftHard }!
        self.rightHardAttack = attacks.first { $0.position == .rightHard }!

        self.forwardDefense = defenses.first { $0.position == .forward }!
        self.leftDefense = defenses.first { $0.position == .left }!
        self.backwardDefense = defenses.first { $0.position == .backward }!
        self.rightDefense = defenses.first { $0.position == .right }!

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
        forwardDefense.updateStateForNextRound()
        backwardDefense.updateStateForNextRound()
        leftDefense.updateStateForNextRound()
        rightDefense.updateStateForNextRound()
    }

    ///Set the selected attack based on the position, the remaining available attacks will become unselected
    mutating func updateSelected(_ position: AttackPosition) {
        if leftLightAttack.isAvailable() {
            leftLightAttack.setState(to: leftLightAttack.position == position ? .selected : .unselected)
        }
        if rightLightAttack.isAvailable() {
            rightLightAttack.setState(to: rightLightAttack.position == position ? .selected : .unselected)
        }
        if leftMediumAttack.isAvailable() {
            leftMediumAttack.setState(to: leftMediumAttack.position == position ? .selected : .unselected)
        }
        if rightMediumAttack.isAvailable() {
            rightMediumAttack.setState(to: rightMediumAttack.position == position ? .selected : .unselected)
        }
        if leftHardAttack.isAvailable() {
            leftHardAttack.setState(to: leftHardAttack.position == position ? .selected : .unselected)
        }
        if rightHardAttack.isAvailable() {
            rightHardAttack.setState(to: rightHardAttack.position == position ? .selected : .unselected)
        }
    }

    ///Set the selected defense based on the position, the remaining available defense will become unselected
    mutating func updateSelected(_ position: DefensePosition) {
        if leftDefense.isAvailable() {
            leftDefense.setState(to: leftDefense.position == position ? .selected : .unselected)
        }
        if rightDefense.isAvailable() {
            rightDefense.setState(to: rightDefense.position == position ? .selected : .unselected)
        }
        if forwardDefense.isAvailable() {
            forwardDefense.setState(to: forwardDefense.position == position ? .selected : .unselected)
        }
        if backwardDefense.isAvailable() {
            backwardDefense.setState(to: backwardDefense.position == position ? .selected : .unselected)
        }
    }
}

private extension Moves {
    mutating func setAttacksStateForNextRound() {
        leftLightAttack.updateStateForNextRound()
        leftMediumAttack.updateStateForNextRound()
        leftHardAttack.updateStateForNextRound()
        rightLightAttack.updateStateForNextRound()
        rightMediumAttack.updateStateForNextRound()
        rightHardAttack.updateStateForNextRound()
    }

    /// - parameter shouldForce: if true, forces the states to the newState.
    mutating func setStates(to newState: MoveButtonState, shouldForce: Bool = false) {
        setAttackStates(to: newState, shouldForce: shouldForce)
        setDefenseStates(to: newState, shouldForce: shouldForce)
    }

    /// - parameter shouldForce: if true, forces the states to the newState.
    mutating func setDefenseStates(to newState: MoveButtonState, shouldForce: Bool = false) {
        if shouldForce || forwardDefense.isAvailable() {
            forwardDefense.setState(to: .initial)
        }
        if shouldForce || backwardDefense.isAvailable() {
            backwardDefense.setState(to: .initial)
        }
        if shouldForce || leftDefense.isAvailable() {
            leftDefense.setState(to: .initial)
        }
        if shouldForce || rightDefense.isAvailable() {
            rightDefense.setState(to: .initial)
        }
    }

    /// - parameter shouldForce: if true, forces the states to the newState.
    mutating func setAttackStates(to newState: MoveButtonState, shouldForce: Bool = false) {
        if shouldForce || leftLightAttack.isAvailable() {
            leftLightAttack.setState(to: .initial)
        }
        if shouldForce || rightLightAttack.isAvailable() {
            rightLightAttack.setState(to: .initial)
        }
        if shouldForce || leftMediumAttack.isAvailable() {
            leftMediumAttack.setState(to: .initial)
        }
        if shouldForce || rightMediumAttack.isAvailable() {
            rightMediumAttack.setState(to: .initial)
        }
        if shouldForce || leftHardAttack.isAvailable() {
            leftHardAttack.setState(to: .initial)
        }
        if shouldForce || rightHardAttack.isAvailable() {
            rightHardAttack.setState(to: .initial)
        }
    }

    mutating func setFireStates(to fireState: FireState) {
        switch fireState {
        case .initial, .big:
            if leftLightAttack.isAvailableNextRound {
                leftLightAttack.setFireState(to: fireState)
            }
            if leftMediumAttack.isAvailableNextRound {
                leftMediumAttack.setFireState(to: fireState)
            }
            if leftHardAttack.isAvailableNextRound {
                leftHardAttack.setFireState(to: fireState)
            }
            if rightLightAttack.isAvailableNextRound {
                rightLightAttack.setFireState(to: fireState)
            }
            if rightMediumAttack.isAvailableNextRound {
                rightMediumAttack.setFireState(to: fireState)
            }
            if rightHardAttack.isAvailableNextRound {
                rightHardAttack.setFireState(to: fireState)
            }
        case .small:
            setToSmallFireStates()
        }
    }

    mutating func setToSmallFireStates() {
        //If attack can boost, set it to small fire, else big fire
        leftLightAttack.setFireState(to: leftLightAttack.canBoost ? .small : .big)
        leftMediumAttack.setFireState(to: leftMediumAttack.canBoost ? .small : .big)
        rightLightAttack.setFireState(to: rightLightAttack.canBoost ? .small : .big)
        rightMediumAttack.setFireState(to: rightMediumAttack.canBoost ? .small : .big)
        //Do not boost the hard attacks on small boost
        leftHardAttack.setFireState(to: .initial)
        rightHardAttack.setFireState(to: .initial)
    }
}

//MARK: - Decodable extension
extension Moves: Codable {
    private enum CodingKeys : String, CodingKey {
        case leftLightAttack = "leftLightAttack"
        case rightLightAttack = "rightLightAttack"
        case leftMediumAttack = "leftMediumAttack"
        case rightMediumAttack = "rightMediumAttack"
        case leftHardAttack = "leftHardAttack"
        case rightHardAttack = "rightHardAttack"

        case forwardDefense = "forwardDefense"
        case leftDefense = "leftDefense"
        case backwardDefense = "backwardDefense"
        case rightDefense = "rightDefense"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(leftLightAttack, forKey: .leftLightAttack)
        try container.encode(rightLightAttack, forKey: .rightLightAttack)
        try container.encode(leftMediumAttack, forKey: .leftMediumAttack)
        try container.encode(rightMediumAttack, forKey: .rightMediumAttack)
        try container.encode(leftHardAttack, forKey: .leftHardAttack)
        try container.encode(rightHardAttack, forKey: .rightHardAttack)
        try container.encode(forwardDefense, forKey: .forwardDefense)
        try container.encode(leftDefense, forKey: .leftDefense)
        try container.encode(backwardDefense, forKey: .backwardDefense)
        try container.encode(rightDefense, forKey: .rightDefense)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let leftLightAttack = try values.decodeIfPresent(Attack.self, forKey: .leftLightAttack)!
        let rightLightAttack = try values.decodeIfPresent(Attack.self, forKey: .rightLightAttack)!
        let leftMediumAttack = try values.decodeIfPresent(Attack.self, forKey: .leftMediumAttack)!
        let rightMediumAttack = try values.decodeIfPresent(Attack.self, forKey: .rightMediumAttack)!
        let leftHardAttack = try values.decodeIfPresent(Attack.self, forKey: .leftHardAttack)!
        let rightHardAttack = try values.decodeIfPresent(Attack.self, forKey: .rightHardAttack)!
        let forwardDefense = try values.decodeIfPresent(Defense.self, forKey: .forwardDefense)!
        let leftDefense = try values.decodeIfPresent(Defense.self, forKey: .leftDefense)!
        let backwardDefense = try values.decodeIfPresent(Defense.self, forKey: .backwardDefense)!
        let rightDefense = try values.decodeIfPresent(Defense.self, forKey: .rightDefense)!
        let attacks: [Attack] = [leftLightAttack, rightLightAttack, leftMediumAttack, rightMediumAttack, leftHardAttack, rightHardAttack]
        let defenses: [Defense] = [forwardDefense, leftDefense, backwardDefense, rightDefense]
        self.init(attacks: attacks, defenses: defenses)
    }
}
