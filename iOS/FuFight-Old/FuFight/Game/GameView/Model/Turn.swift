//
//  Turn.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/11/24.
//

import Foundation

class Turn {
    private(set) var round: Int
    private(set) var attack: Attack?
    private(set) var defend: Defend?
    var speed: CGFloat = 0
    private var hasSpeedBoost: Bool = false

    ///Initializer for completed turn
    init(round: Round, isEnemy: Bool) {
        self.round = round.id
        if isEnemy {
            attack = round.selectedEnemyAttack
            defend = round.selectedEnemyDefense
            hasSpeedBoost = !round.hasSpeedBoost
        } else {
            attack = round.selectedAttack
            defend = round.selectedDefense
            hasSpeedBoost = round.hasSpeedBoost
        }
        self.speed = 0
        updateSpeed()
    }

    func update(attack: Attack?) {
        self.attack = attack
        updateSpeed()
    }

    func update(defend: Defend?) {
        self.defend = defend
        updateSpeed()
    }

    ///Returns false if the selected defense position can
    func didDodge(_ enemyAttack: Attack?) -> Bool {
        guard let enemyAttack else { return true }
        guard let defend else { return false }
        return defend.didDodge(enemyAttack.move.position)
    }
}

private extension Turn {
    func updateSpeed() {
        let moveSpeed = attack?.move.speed ?? 0
        let speedMultiplier = defend?.move.speedMultiplier ?? 0
        let speedBoostMultiplier = hasSpeedBoost ? 0.1 : 0
        speed = moveSpeed * (1 + speedMultiplier) * (1 + speedBoostMultiplier)
    }
}

extension Turn: Equatable, Hashable {
    static func == (lhs: Turn, rhs: Turn) -> Bool {
        return lhs.round == rhs.round
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(round)
    }
}
