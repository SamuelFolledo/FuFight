//
//  Player.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/11/24.
//

import Foundation

class PlayerState {
    private(set) var boostLevel: BoostLevel
    ///Keeps track of which player gets the speed boost next round. True if current player attacked first and landed it
    var hasSpeedBoost: Bool //TODO: Multiplayer game mode should be synced between games

    init(boostLevel: BoostLevel, hasSpeedBoost: Bool) {
        self.boostLevel = boostLevel
        self.hasSpeedBoost = hasSpeedBoost
    }

    func upgradeBoost() {
        boostLevel = boostLevel.nextLevel
    }

    func resetBoost() {
        boostLevel = .none
    }
}

@Observable
class Player {
    private(set) var photoUrl: URL
    private(set) var username: String
    private(set) var hp: CGFloat
    private(set) var maxHp: CGFloat
    private(set) var isEnemy: Bool
    private(set) var fighter: Fighter
    private(set) var state: PlayerState
    var moves: Moves
    var rounds: [Round]

    var speed: CGFloat = 0

    var currentRound: Round { return rounds.last! }
    var isDead: Bool { hp <= 0 }
    var hpText: String { String(format: "%.2f", hp) }

    ///Round 1 initializer
    init(photoUrl: URL, username: String, hp: CGFloat, maxHp: CGFloat, fighter: Fighter, rounds: [Round] = [], boostLevel: BoostLevel = .none, hasSpeedBoost: Bool = false, attacks: [Attack], defenses: [Defend]) {
        self.photoUrl = photoUrl
        self.username = username
        self.hp = hp
        self.maxHp = maxHp
        self.fighter = fighter
        self.rounds = rounds
        self.state = PlayerState(boostLevel: boostLevel, hasSpeedBoost: hasSpeedBoost)
        self.isEnemy = username != (Account.current?.username ?? "")
        self.moves = Moves(attacks: attacks, defenses: defenses)
    }

    func loadAnimations() {
        fighter.loadAnimations(animations: moves.animationTypes)
    }

    func populateSelectedMovesAndSpeed() {
        let selectedAttack = moves.attacks.first(where: { $0.state == .selected })
        let selectedDefend = moves.defenses.first(where: { $0.state == .selected })
        rounds[rounds.count - 1].attack = selectedAttack
        rounds[rounds.count - 1].defend = selectedDefend

        let moveSpeed = selectedAttack?.move.speed ?? 0
        let speedMultiplier = selectedDefend?.move.speedMultiplier ?? 1
        let speedBoostMultiplier = state.hasSpeedBoost ? speedBoostMultiplier : 1
        speed = (moveSpeed * speedMultiplier * speedBoostMultiplier).roundDecimalUpTo(1)
    }

    func generateEnemyRoundIfNeeded() {
        //TODO: Remove this auto generated enemy round
        let randomAttack = moves.attacks.filter{ $0.state != .cooldown }.randomElement()!
        for (index, attack) in moves.attacks.enumerated() {
            if attack.move.id == randomAttack.move.id {
                if attack.currentCooldown <= 0 {
//                    LOGD("Randomly generated enemy attack is \(moves.attacks[index].name)")
                    moves.attacks[index].setStateTo(.selected)
                }
            }
        }
        let randomDefend: Dash = [Dash.left, Dash.right].randomElement()!
        for (index, defend) in moves.defenses.enumerated() {
            if defend.move.id == randomDefend.id {
                if defend.currentCooldown <= 0 {
//                    LOGD("Randomly generated enemy defend is \(defend.name)")
                    moves.defenses[index].setStateTo(.selected)
                }
            }
        }
    }

    /// - Parameters:
    ///   - amount: Amount of damage this player received. Nil damage means this player dodged the enemy's attack
    func setCurrentRoundDefendResult(_ enemyResult: AttackResult) {
        hp -= enemyResult.damage ?? 0
    }

    func setCurrentRoundAttackResult(_ result: AttackResult) {
        let currentRoundIndex = rounds.count - 1
        rounds[currentRoundIndex].attackResult = result
    }

    func prepareForNewRound() {
        speed = 0
        if rounds.isEmpty {
            rounds.append(Round(round: 1))
        } else {
            let newRound = Round(round: rounds.count + 1)
            rounds.append(newRound)
        }
    }

    func defeated() {
        hp = 0
    }

    func prepareForRematch() {
        hp = maxHp
        rounds.removeAll()
        state.resetBoost()
        moves.resetMoves()
    }
}

private extension Player {}
