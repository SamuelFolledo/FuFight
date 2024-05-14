//
//  GameService.swift
//  FuFight
//
//  Created by Samuel Folledo on 4/22/24.
//

import SceneKit
import SwiftUI

enum GameService {
    static func getDefenderAnimation(attack: Attack, attackerType: FighterType, attackResult: AttackResult) -> AnimationType? {
        switch attackResult {
        case .noAttack:
            break
        case .miss:
            return attack.animationType.isRight ? .dodgeHeadLeft : .dodgeHeadRight
        case .damage(_):
            if let strength = attack.animationType.strength {
                let isStraightAttack = attack.animationType.isStraightAttack(for: attackerType)
                switch strength {
                case .light:
                    return isStraightAttack ? .hitHeadStraightLight : attack.animationType.isRight ? .hitHeadRightLight : .hitHeadLeftLight
                case .medium:
                    return isStraightAttack ? .hitHeadStraightMedium : attack.animationType.isRight ? .hitHeadRightMedium : .hitHeadLeftMedium
                case .hard:
                    return isStraightAttack ? .hitHeadStraightHard : attack.animationType.isRight ? .hitHeadRightHard : .hitHeadLeftHard
                }
            }
        case .kill(_):
            if let strength = attack.animationType.strength {
                switch strength {
                case .light:
                    return attack.animationType.isRight ? .killHeadLeftLight : .killHeadRightLight
                case .medium:
                    return attack.animationType.isRight ? .killHeadLeftMedium : .killHeadRightMedium
                case .hard:
                    return attack.animationType.isRight ? .killHeadLeftHard : .killHeadRightHard
                }
            }
        }
        return nil
    }

    static func getAttackResult(attackerRound: Round, defenderRound: Round, defenderHp: CGFloat, damageReduction: CGFloat = 1) -> AttackResult {
        if let attack = attackerRound.attack {
            if didDodge(attack.position, defenderPosition: defenderRound.defend?.position) {
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
    /**
     Check if current attack selection landed on this player's current defense selection
     - parameter enemyAttack: attack dealt to this player. Nil will be dodged
     - returns: Returns false if attacker's attack landed despite of the damage
     */
    static func didDodge(_ attackerPosition: AttackPosition?, defenderPosition: DefensePosition?) -> Bool {
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

    /// Returns the attacker's total damage based on defender's defend choice
    /// - Parameters:
    ///   - attackerRound: attacker's attack
    ///   - defenderRound: defender's defend choice
    ///   - secondAttackDamageReduction: only pass a value if attacker is going second
    static func getTotalDamage(attackerRound: Round, defenderRound: Round, secondAttackerDamageReduction: CGFloat = 1) -> CGFloat {
        let baseDamage = attackerRound.attack?.damage ?? 0

        let defendDamageMultiplier = attackerRound.defend?.damageMultiplier ?? 1
        let fireBoostDamageMultiplier = attackerRound.attack?.fireState.boostMultiplier ?? 1

        let enemyDamageReduction = defenderRound.defend?.incomingDamageMultiplier ?? 1

        let totalDamage = baseDamage +
            (baseDamage * defendDamageMultiplier - baseDamage) +
            (baseDamage * fireBoostDamageMultiplier - baseDamage)
        let actualDamage = totalDamage * enemyDamageReduction * secondAttackerDamageReduction
//        LOGD("Total damage for \(String(describing: attackerRound.attack?.animationType)) vs \(String(describing: defenderRound.defend?.animationType)) is \(actualDamage)")
        return actualDamage
    }
}
