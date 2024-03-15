//
//  Player.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/11/24.
//

import Foundation

@Observable
class Player {
    private(set) var photoUrl: URL
    private(set) var username: String
    private(set) var hp: CGFloat
    let maxHp: CGFloat
    var attacks: [Attack]
    var defenses: [Defend]
    private(set) var turns: [Turn] = []
    private(set) var boostLevel = 0
    private(set) var didMissAttack = false
    private(set) var hasSpeedBoost = false
    var isDead: Bool { hp <= 0 }
    var hpText: String { String(format: "%.2f", hp) }

    init(photoUrl: URL, username: String, hp: CGFloat, maxHp: CGFloat, attacks: [Attack], defenses: [Defend], turns: [Turn] = [], hasSpeedBoost: Bool = false, boostLevel: Int = 0) {
        self.photoUrl = photoUrl
        self.username = username
        self.hp = hp
        self.maxHp = maxHp
        self.attacks = attacks
        self.defenses = defenses
        self.turns = turns
        self.boostLevel = boostLevel
    }

    func prepareForNextRound() {
        var turn = Turn(round: turns.count + 1, hasSpeedBoost: hasSpeedBoost)
        updateAttacksState(attacks: &attacks, turn: &turn)
        updateFireState(attacks: &attacks, turn: &turn, boostLevel: &boostLevel)
        updateDefensesState(defenses: &defenses, turn: &turn)
        turns.append(turn)
        didMissAttack = false
    }

    func prepareForRematch() {
        hp = maxHp
        for index in attacks.indices {
            attacks[index].restart()
        }
        for index in defenses.indices {
            defenses[index].restart()
        }
        turns.removeAll()
        didMissAttack = false
    }

    func attackMissed() {
        didMissAttack = true
        turns.last?.updateTotalDamage(to: nil)
    }

    func giveSpeedBoost(_ shouldSpeedBoost: Bool) {
        hasSpeedBoost = shouldSpeedBoost
        if turns.last != nil {
            turns.last!.hasSpeedBoost = shouldSpeedBoost
        }
    }

    func damage(amount: CGFloat) {
        hp -= amount
        turns.last?.updateTotalDamage(to: amount)
    }

    func gameOver() {
        hp = 0
    }
}

private extension Player {
    func updateFireState(attacks: inout [Attack], turn: inout Turn, boostLevel: inout Int) {
        if !didMissAttack,
           let selectedAttack = turn.attack,
           selectedAttack.fireState != .big {
            boostLevel += 1
            let isMaxBoost = boostLevel > 1
            for (index, attack) in attacks.enumerated() {
                switch attacks[index].state {
                case .selected, .cooldown, .unselected:
                    continue
                case .initial:
                    ///This works because all of attacks's state are either in cooldown or initial
                    if selectedAttack.move.canBoost {
                        if !isMaxBoost {
                            ///Do not boost the hard attacks on stage 1 boost
                            let indexOfHardAttacks: [AttackPosition] = [.rightHard, .leftHard]
                            if !indexOfHardAttacks.contains(attacks[index].move.position) {
                                if attack.move.canBoost {
                                    attacks[index].setFireTo(.small)
                                } else {
                                    attacks[index].setFireTo(.big)
                                }
                            } else {
                                attacks[index].setFireTo(nil)
                            }
                        } else {
                            ///If stage 2 boost, then make all available attacks have a big fire
                            attacks[index].setFireTo(.big)
                        }
                    } else {
                        removeAllFires()
                    }
                }
            }
            if isMaxBoost {
                boostLevel = 0
            }
        } else {
            removeAllFires()
        }

        func removeAllFires() {
            boostLevel = 0
            attacks.indices.forEach {
                attacks[$0].setFireTo(nil)
            }
        }
    }

    func updateAttacksState(attacks: inout [Attack], turn: inout Turn) {
        for index in attacks.indices {
            switch attacks[index].state {
            case .selected:
                attacks[index].setStateTo(.cooldown)
                turn.update(attack: attacks[index])
            case .cooldown:
                attacks[index].reduceCooldown()
            case .initial, .unselected:
                attacks[index].setStateTo(.initial)
            }
        }
    }

    func updateDefensesState(defenses: inout [Defend], turn: inout Turn) {
        for index in defenses.indices {
            switch defenses[index].state {
            case .selected:
                defenses[index].setStateTo(.cooldown)
                turn.update(defend: defenses[index])
            case .cooldown:
                defenses[index].reduceCooldown()
            case .initial, .unselected:
                defenses[index].setStateTo(.initial)
            }
        }
    }
}
