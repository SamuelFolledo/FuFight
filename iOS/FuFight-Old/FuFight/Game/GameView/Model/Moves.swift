//
//  Moves.swift
//  FuFight
//
//  Created by Samuel Folledo on 4/25/24.
//

import SwiftUI

struct Moves {
    var attacks: [Attack]
    var defenses: [Defend]
    var leftLightAttack: Attack
    var rightLightAttack: Attack
    var leftMediumAttack: Attack
    var rightMediumAttack: Attack
    var leftHardAttack: Attack
    var rightHardAttack: Attack

    let otherAnimations: [AnimationType] = [.idle, .idleStand, .dodgeHead, .hitHead, .killHead]

    var animationTypes: [AnimationType] {
        attacks.compactMap { $0.move.animationType } +
        defenses.compactMap { $0.move.animationType } +
        otherAnimations
    }

    //MARK: Initializers
    init(attacks: [Attack], defenses: [Defend]) {
        self.attacks = attacks
        self.defenses = defenses
        self.leftLightAttack = attacks.first { $0.move.position == .leftLight }!
        self.rightLightAttack = attacks.first { $0.move.position == .rightLight }!
        self.leftMediumAttack = attacks.first { $0.move.position == .leftMedium }!
        self.rightMediumAttack = attacks.first { $0.move.position == .rightMedium }!
        self.leftHardAttack = attacks.first { $0.move.position == .leftHard }!
        self.rightHardAttack = attacks.first { $0.move.position == .rightHard }!
    }

    //MARK: - Public Methods

    mutating func resetMoves() {
        for index in attacks.indices {
            attacks[index].setStateTo(.initial)
        }
        for index in defenses.indices {
            defenses[index].setStateTo(.initial)
        }
    }

    mutating func updateAttacksForNextRound(attackLanded: Bool, previousAttackCanBoost: Bool, boostLevel: BoostLevel) {
        for index in attacks.indices {
            if !attackLanded {
                //If previous attack is nil or missed, do not boost
                attacks[index].setFireTo(nil)
                continue
            }

            if !previousAttackCanBoost {
                //If previous attack cannot boost, do not boost
                attacks[index].setFireTo(nil)
                continue
            }
            //If previous attack landed and can boost, set fire depending on the boost level
            switch boostLevel {
            case .none:
                attacks[index].setFireTo(nil)
            case .small:
                //Do not boost the hard attacks on small boost
                let hardAttackPositions: [AttackPosition] = [.rightHard, .leftHard]
                if let position = attacks[index].move.position,
                   !hardAttackPositions.contains(position) {
                    if attacks[index].move.canBoost {
                        //If light or medium attack can boost, set it to small fire
                        attacks[index].setFireTo(.small)
                    } else {
                        //If light or medium attack cannot boost, then set it to big fire
                        attacks[index].setFireTo(.big)
                    }
                } else {
                    attacks[index].setFireTo(nil)
                }
            case .big:
                attacks[index].setFireTo(.big)
            }
        }

        for index in attacks.indices {
            GameService.updateMoveStatesForNextRound(&attacks[index])
        }
    }

    mutating func updateDefensesForNextRound() {
        for index in defenses.indices {
            GameService.updateMoveStatesForNextRound(&defenses[index])
        }
    }
}
