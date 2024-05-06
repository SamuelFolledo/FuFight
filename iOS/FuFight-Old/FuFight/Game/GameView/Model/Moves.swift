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

    let otherAnimations: [AnimationType] = [.idle, .idleStand, .dodgeHead, .hitHead, .killHead]
    let animationTypes: [AnimationType]
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
        leftLightAttack.reset()
        leftLightAttack.setFireState(to: .initial)
        leftMediumAttack.reset()
        leftMediumAttack.setFireState(to: .initial)
        leftHardAttack.reset()
        leftHardAttack.setFireState(to: .initial)
        rightLightAttack.reset()
        rightLightAttack.setFireState(to: .initial)
        rightMediumAttack.reset()
        rightMediumAttack.setFireState(to: .initial)
        rightHardAttack.reset()
        rightHardAttack.setFireState(to: .initial)

        forwardDefense.reset()
        backwardDefense.reset()
        leftDefense.reset()
        rightDefense.reset()
    }

    mutating func updateAttacksForNextRound(attackLanded: Bool, boostLevel: BoostLevel) {
        if !attackLanded {
            setAttacksFireState(to: .initial)
            setAttacksStateForNextRound()
            return
        }

        let selectedAttackCanBoost: Bool = selectedAttack?.canBoost ?? false
        if !selectedAttackCanBoost {
            setAttacksFireState(to: .initial)
            setAttacksStateForNextRound()
            return
        }

        setAttacksStateForNextRound()
        switch boostLevel {
        case .none:
            setAttacksFireState(to: .initial)
        case .small:
            setAttacksToSmallFireState()
        case .big:
            setAttacksFireState(to: .big)
        }
    }

    mutating func updateDefensesForNextRound() {
        forwardDefense.updateStateForNextRound()
        backwardDefense.updateStateForNextRound()
        leftDefense.updateStateForNextRound()
        rightDefense.updateStateForNextRound()
    }

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

    mutating func setAttacksFireState(to fireState: FireState) {
        if fireState == .small {
            setAttacksToSmallFireState()
            return
        }
        leftLightAttack.setFireState(to: fireState)
        leftMediumAttack.setFireState(to: fireState)
        leftHardAttack.setFireState(to: fireState)
        rightLightAttack.setFireState(to: fireState)
        rightMediumAttack.setFireState(to: fireState)
        rightHardAttack.setFireState(to: fireState)
    }

    mutating func setAttacksToSmallFireState() {
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
