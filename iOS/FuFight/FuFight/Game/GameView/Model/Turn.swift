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
    private(set) var hasSpeedBoost: Bool

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

    func update(_ attack: Attack?) {
        self.attack = attack
        updateSpeed()
    }

    func update(_ defend: Defend?) {
        self.defend = defend
        updateSpeed()
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
