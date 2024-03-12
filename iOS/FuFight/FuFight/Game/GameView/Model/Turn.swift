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
    private(set) var defend: (Defend)?
    private(set) var speed: CGFloat = 0
    ///True if user on this turn had the speed boost
    var hasSpeedBoost: Bool
    ///nil means no attack selected, 0 means dodged
    private(set) var totalDamage: CGFloat? = 0

    init(round: Int, hasSpeedBoost: Bool) {
        self.round = round
        self.attack = nil
        self.defend = nil
        self.speed = 0
        self.hasSpeedBoost = hasSpeedBoost
    }

    init(round: Int, attacks: [Attack], defenses: [Defend], hasSpeedBoost: Bool) {
        self.round = round
        self.attack = attacks.first { $0.state == .selected }
        self.defend = defenses.first { $0.state == .selected }
        self.hasSpeedBoost = hasSpeedBoost
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

    func updateTotalDamage(to amount: CGFloat?) {
        self.totalDamage = amount
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
