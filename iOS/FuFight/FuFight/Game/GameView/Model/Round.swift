//
//  Round.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/16/24.
//

import Foundation

///Class that holds the data for each round
@Observable
class Round {
    ///round number
    var id: Int

    //MARK: Current player's properties
    ///True if current player has the speed boost this round
    var hasSpeedBoost: Bool
    var attacks: [Attack] = []
    var defenses: [Defend] = []
    ///Current user's damage. Nil means no attack selected, 0 means dodged
    var damage: CGFloat? = nil
    var selectedAttack: Attack? {
        attacks.first { $0.state == .selected }
    }
    var selectedDefense: Defend? {
        defenses.first { $0.state == .selected }
    }

    //MARK: Enemy properties
    var enemyAttacks: [Attack] = []
    var enemyDefenses: [Defend] = []
    var enemyDamage: CGFloat? = nil
    var selectedEnemyAttack: Attack? {
        enemyAttacks.first { $0.state == .selected }
    }
    var selectedEnemyDefense: Defend? {
        enemyDefenses.first { $0.state == .selected }
    }

    ///Initializer for the first round
    init(round: Int, attacks: [Attack], defenses: [Defend], hasSpeedBoost: Bool, enemyAttacks: [Attack], enemyDefenses: [Defend]) {
        self.id = round
        self.attacks = attacks
        self.defenses = defenses
        self.hasSpeedBoost = hasSpeedBoost
        self.enemyAttacks = enemyAttacks
        self.enemyDefenses = enemyDefenses
    }

    ///Initializer used to create a new round from the previous round
    init(previousRound: Round, hasSpeedBoost: Bool) {
        self.id = previousRound.id + 1
        self.hasSpeedBoost = hasSpeedBoost
        updateMovesForNextRound(previousRound: previousRound)
    }

    ///Update attacks's fire state based on previous round and boost level
    func updateAttacksFireStateForNextRound(previousRound: Round, boostLevel: Int) {
        let didLand = previousRound.damage != nil
        let didAttack = previousRound.selectedAttack != nil
        for index in attacks.indices {
            if !didLand || !didAttack {
                //If previous attack is nil or missed, do not boost
                attacks[index].setFireTo(nil)
                continue
            }
            let previousAttack = previousRound.selectedAttack!
            if !previousAttack.move.canBoost {
                //If previous attack cannot boost, do not boost
                attacks[index].setFireTo(nil)
                continue
            }
            //If previous attack landed and can boost, set fire depending on the boost level
            switch boostLevel {
            case 0:
                attacks[index].setFireTo(nil)
            case 1:
                //Do not boost the hard attacks on stage 1 boost
                let hardAttackPositions: [AttackPosition] = [.rightHard, .leftHard]
                if !hardAttackPositions.contains(attacks[index].move.position) {
                    attacks[index].setFireTo(.small)
                }
            case 2:
                attacks[index].setFireTo(.big)
            default:
                attacks[index].setFireTo(nil)
                LOGE("Invalid boost level")
            }
        }
    }
}

private extension Round {
    ///Update current round's attacks and defenses based on previous rounds
    func updateMovesForNextRound(previousRound: Round) {
        self.attacks = getNextRoundAttacksState(from: previousRound.attacks)
        self.defenses = getNextRoundDefensesState(from: previousRound.defenses)
        self.enemyAttacks = getNextRoundAttacksState(from: previousRound.enemyAttacks)
        self.enemyDefenses = getNextRoundDefensesState(from: previousRound.enemyDefenses)
    }

    func getNextRoundAttacksState(from attacks: [Attack]) -> [Attack] {
        var nextAttacks = attacks
        for index in attacks.indices {
            switch attacks[index].state {
            case .selected:
                //If selected, set it to cooldown
                nextAttacks[index].setStateTo(.cooldown)
            case .cooldown:
                //If in cooldown, reduce the cooldown
                nextAttacks[index].reduceCooldown()
            case .initial, .unselected:
                //If initial or unselected, set it to initial state again
                nextAttacks[index].setStateTo(.initial)
            }
        }
        return nextAttacks
    }

    func getNextRoundDefensesState(from defenses: [Defend]) -> [Defend] {
        var nextDefenses = defenses
        for index in defenses.indices {
            switch defenses[index].state {
            case .selected:
                nextDefenses[index].setStateTo(.cooldown)
            case .cooldown:
                nextDefenses[index].reduceCooldown()
            case .initial, .unselected:
                nextDefenses[index].setStateTo(.initial)
            }
        }
        return nextDefenses
    }
}

extension Round: Equatable, Hashable {
    static func == (lhs: Round, rhs: Round) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
