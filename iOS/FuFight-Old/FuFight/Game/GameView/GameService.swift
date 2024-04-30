//
//  GameService.swift
//  FuFight
//
//  Created by Samuel Folledo on 4/22/24.
//

import SceneKit
import SwiftUI

enum GameService {
    static func updateMoveStatesForNextRound(_ attack: inout Attack) {
        switch attack.state {
        case .selected:
            //If selected, set it to cooldown
            attack.setStateTo(.cooldown)
        case .cooldown:
            //If in cooldown, reduce the cooldown
            attack.reduceCooldown()
        case .initial, .unselected:
            //If initial or unselected, set it to initial state again
            attack.setStateTo(.initial)
        }
    }

    static func updateMoveStatesForNextRound(_ defense: inout Defend) {
        switch defense.state {
        case .selected:
            defense.setStateTo(.cooldown)
        case .cooldown:
            defense.reduceCooldown()
        case .initial, .unselected:
            defense.setStateTo(.initial)
        }
    }

    /**
     Check if current attack selection landed on this player's current defense selection
     - parameter enemyAttack: attack dealt to this player. Nil will be dodged
     - returns: Returns false if attacker's attack landed despite of the damage
     */
    static func didDodge(_ attackerPosition: AttackPosition?, defenderPosition: DefendPosition?) -> Bool {
        guard let attackerPosition else { return true }
        guard let defenderPosition else { return false }
        switch defenderPosition {
        case .forward, .backward:
            return false
        case .left:
            return attackerPosition.isLeft
        case .right:
            return !attackerPosition.isLeft
        }
    }

    static func getAttackResult(attackerRound: Round, defenderRound: Round, defenderHp: CGFloat, damageReduction: CGFloat = 1) -> AttackResult {
        if let attack = attackerRound.attack {
            if didDodge(attack.move.position, defenderPosition: defenderRound.defend?.move.position) {
                return .miss
            }
            let totalDamage = getTotalDamage(attackerRound: attackerRound, defenderRound: defenderRound)
            if defenderHp <= totalDamage {
                return .kill(totalDamage)
            }
            return .damage(totalDamage)
        }
        return .noAttack
    }
}

private extension GameService {
    /// Returns the attacker's total damage based on defender's defend choice
    /// - Parameters:
    ///   - attackerRound: attacker's attack
    ///   - defenderRound: defender's defend choice
    ///   - secondAttackDamageReduction: only pass a value if attacker is going second
    static func getTotalDamage(attackerRound: Round, defenderRound: Round, secondAttackerDamageReduction: CGFloat = 1) -> CGFloat {
        let baseDamage = attackerRound.attack?.move.damage ?? 0

        let defendDamageMultiplier = attackerRound.defend?.move.damageMultiplier ?? 1
        let fireBoostDamageMultiplier = attackerRound.attack?.fireState?.boostMultiplier ?? 1

        let enemyDamageReduction = defenderRound.defend?.move.incomingDamageMultiplier ?? 1

        let totalDamage = baseDamage +
            (baseDamage * defendDamageMultiplier - baseDamage) +
            (baseDamage * fireBoostDamageMultiplier - baseDamage)
        let actualDamage = totalDamage * enemyDamageReduction * secondAttackerDamageReduction
//        LOGD("Total damage for \(String(describing: attackerRound.attack?.move.animationType)) vs \(String(describing: defenderRound.defend?.move.animationType)) is \(actualDamage)")
        return actualDamage
    }
}
