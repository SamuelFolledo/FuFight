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
    let fighter: Fighter

    private(set) var turns: [Turn] = []
    var currentTurn: Turn {
        return turns.last!
    }
    private(set) var boostLevel = 0
    var isDead: Bool { hp <= 0 }
    var hpText: String { String(format: "%.2f", hp) }
    private(set) var isEnemy: Bool = true

    ///Round 1 initializer
    init(photoUrl: URL, username: String, hp: CGFloat, maxHp: CGFloat, attacks: [Attack], defenses: [Defend], turns: [Turn] = [], hasSpeedBoost: Bool = false, boostLevel: Int = 0, fighter: Fighter) {
        self.photoUrl = photoUrl
        self.username = username
        self.hp = hp
        self.maxHp = maxHp
        self.turns = turns
        self.boostLevel = boostLevel
        if let currentUsername = Account.current?.username {
            self.isEnemy = username != currentUsername
        }
        self.fighter = fighter
    }

    func createTurn(from currentRound: Round) {
        let currentTurn = Turn(round: currentRound, isEnemy: isEnemy)
        turns.append(currentTurn)
    }

    func generateEnemyTurnIfNeeded(currentRound: Round) {
        //TODO: Remove this auto generated enemy turn
        let turn = Turn(round: currentRound, isEnemy: isEnemy)
        while turn.attack == nil {
            let randomAttack = Punch.allCases.randomElement()!
            for (index, attack) in currentRound.enemyAttacks.enumerated() {
                if attack.move.id == randomAttack.id {
                    if attack.cooldown <= 0 {
//                        LOGD("Randomly generated enemy attack is \(attack.move.name)")
                        currentRound.enemyAttacks[index].setStateTo(.selected)
                        turn.update(attack: currentRound.enemyAttacks[index])
                    }
                }
            }
        }
        while turn.defend == nil {
            let randomDefend = Dash.allCases.randomElement()!
            for (index, defend) in currentRound.enemyDefenses.enumerated() {
                if defend.move.id == randomDefend.id {
                    if defend.cooldown <= 0 {
//                        LOGD("Randomly generated enemy defend is \(defend.move.name)")
                        currentRound.enemyDefenses[index].setStateTo(.selected)
                        turn.update(defend: currentRound.enemyDefenses[index])
                    }
                }
            }
        }
        turns[turns.count - 1] = turn
    }

    func prepareForRematch() {
        hp = maxHp
        turns.removeAll()
        setBoostLevel(to: 0)
    }

    func damage(amount: CGFloat?) {
        if let amount {
            hp -= amount
        }
    }

    func gameOver() {
        hp = 0
    }

    func setBoostLevel(to level: Int) {
        boostLevel = level
        if boostLevel > 2 {
            boostLevel = 0
        }
    }
}
