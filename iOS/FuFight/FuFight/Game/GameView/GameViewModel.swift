//
//  GameViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/4/24.
//

import SwiftUI

@Observable
class GameViewModel: BaseViewModel {
    var currentPlayer: Player
    var enemyPlayer: Player
    var isGameOver: Bool = false
    var timeRemaining = defaultMaxTime
    var isTimerActive: Bool = false
    var isBackgroundLeadingPadding = Bool.random()
    //TODO: Check the actual maximum padding I can have
    var backgroundPadding = Double.random(in: 0...1000)
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    ///Initializer for testing purposes
    override init() {
        let photoUrl = Account.current?.photoUrl ?? URL(string: "https://firebasestorage.googleapis.com:443/v0/b/fufight-51d75.appspot.com/o/Accounts%2FPhotos%2FS4L442FyMoNRfJEV05aFCHFMC7R2.jpg?alt=media&token=0f185bff-4d16-450d-84c6-5d7645a97fb9")!
        self.currentPlayer = Player(photoUrl: photoUrl, username: "Samuel", hp: 100, maxHp: 100, attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses)
        self.enemyPlayer = Player(photoUrl: photoUrl, username: "Brandon", hp: 100, maxHp: 100, attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses)
        super.init()
    }

    init(enemyPlayer: Player) {
        self.currentPlayer = Player(photoUrl: Account.current!.photoUrl!, username: Account.current!.displayName, hp: 100, maxHp: 100, attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses)
        //TODO: Show enemy
        self.enemyPlayer = enemyPlayer
        super.init()
    }

    override func onAppear() {
        super.onAppear()
        startGame()
    }

    //MARK: - Public Methods
    func decrementTimeByOneSecond() {
        guard isTimerActive else { return }
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            timeRemaining = defaultMaxTime
        }
        if timeRemaining == 0 {
            isTimerActive = false
            applyDamages()
            if !isGameOver {
                goToNextRound()
            }
        }
    }

    func rematch() {
        currentPlayer.prepareForRematch()
        enemyPlayer.prepareForRematch()
        startGame()
    }
}

//MARK: - Private Methods
private extension GameViewModel {
    func startGame() {
        let isCurrentSpeedBoosted = Int.random(in: 0...1) == 0
        currentPlayer.giveSpeedBoost(isCurrentSpeedBoosted)
        enemyPlayer.giveSpeedBoost(!isCurrentSpeedBoosted)
        goToNextRound()
    }

    func goToNextRound() {
        currentPlayer.prepareForNextRound()
        enemyPlayer.prepareForNextRound()
        isTimerActive = true
    }

    func gameOver() {
        if enemyPlayer.hp <= 0 {
            LOGD("Player won")
            enemyPlayer.gameOver()
        } else if currentPlayer.hp <= 0 {
            LOGD("Enemy won")
            currentPlayer.gameOver()
        }
        isGameOver = true
    }

    func generateEnemyTurn(_ turn: inout Turn) {
        while turn.attack == nil {
            let randomAttack = Punch.allCases.randomElement()!
            for (index, attack) in enemyPlayer.attacks.enumerated() {
                if attack.move.id == randomAttack.id {
                    if attack.cooldown <= 0 {
                        LOGD("Randomly generated enemy attack is \(attack.move.name)")
                        turn.update(attack: attack)
                        enemyPlayer.attacks[index].setStateTo(.selected)
                    }
                }
            }
        }
        while turn.defend == nil {
            let randomDefend = Dash.allCases.randomElement()!
            for (index, defend) in enemyPlayer.defenses.enumerated() {
                if defend.move.id == randomDefend.id {
                    if defend.cooldown <= 0 {
                        LOGD("Randomly generated enemy defend is \(defend.move.name)")
                        turn.update(defend: defend)
                        enemyPlayer.defenses[index].setStateTo(.selected)
                    }
                }
            }
        }
    }


    /// Returns the attacker's total damage based on defender's defend choice
    /// - Parameters:
    ///   - attackerTurn: attacker's attack
    ///   - defenderTurn: defender's defend choice
    ///   - secondAttackDamageReduction: only pass a value if attacker is going second
    func calculateDamage(attackerTurn: Turn, defenderTurn: Turn, secondAttackDamageReduction: CGFloat = 0) -> CGFloat {
        let baseDamage = attackerTurn.attack?.move.damage ?? 0
        let defenseDamageMultiplier = attackerTurn.defend?.move.damageMultiplier ?? 0
        let boostDamageMultiplier = attackerTurn.attack?.fireState?.boostMultiplier ?? 0
        let enemyDamageReduction = defenderTurn.defend?.move.defenseMultiplier ?? 0
        //Total damage = baseDamage * (damageMultiplier + fireDamageMultiplier + 1) * (1 - enemyDamageReduction)
        let totalDamage = baseDamage * (defenseDamageMultiplier + boostDamageMultiplier + 1) * (1 - enemyDamageReduction - secondAttackDamageReduction)
        return totalDamage
    }

    func applyDamages() {
        let round = currentPlayer.turns.count + 1
        let currentTurn = Turn(round: round, attacks: currentPlayer.attacks, defenses: currentPlayer.defenses, hasSpeedBoost: currentPlayer.hasSpeedBoost)
        var enemyTurn = Turn(round: round, attacks: enemyPlayer.attacks, defenses: enemyPlayer.defenses, hasSpeedBoost: enemyPlayer.hasSpeedBoost)
        //TODO: Remove these auto generated enemy turn
        generateEnemyTurn(&enemyTurn)
        ///1) Check who is faster to see who goes first
        let isCurrentFirst = currentTurn.speed > enemyTurn.speed
        let firstTurn = isCurrentFirst ? currentTurn : enemyTurn
        let secondTurn = isCurrentFirst ? enemyTurn : currentTurn
        ///2) Apply first attacker's damage
        var secondAttackDamageReduction: CGFloat = 0
        if let firstAttack = firstTurn.attack {
            if didLand(attackPosition: firstAttack.move.position, opposingDefense: secondTurn.defend) {
                let totalDamage = calculateDamage(attackerTurn: firstTurn, defenderTurn: secondTurn)
                if isCurrentFirst {
                    enemyPlayer.damage(amount: totalDamage)
                } else {
                    currentPlayer.damage(amount: totalDamage)
                }
                if enemyPlayer.isDead || currentPlayer.isDead {
                    return gameOver()
                }
                ///Additional damage reduction for the second attacker
                secondAttackDamageReduction = firstAttack.move.damageReduction
            } else {
                isCurrentFirst ? currentPlayer.attackMissed() : enemyPlayer.attackMissed()
            }
        } else {
            isCurrentFirst ? enemyPlayer.damage(amount: 0) : currentPlayer.damage(amount: 0)
        }
        ///3) Apply second attacker's damage
        if let secondAttack = secondTurn.attack {
            if didLand(attackPosition: secondAttack.move.position, opposingDefense: firstTurn.defend) {
                let totalDamage = calculateDamage(attackerTurn: secondTurn, defenderTurn: firstTurn, secondAttackDamageReduction: secondAttackDamageReduction)
                if isCurrentFirst {
                    currentPlayer.damage(amount: totalDamage)
                } else {
                    enemyPlayer.damage(amount: totalDamage)
                }
                if enemyPlayer.isDead || currentPlayer.isDead {
                    return gameOver()
                }
            } else {
                isCurrentFirst ? enemyPlayer.attackMissed() : currentPlayer.attackMissed()
            }
        } else {
            isCurrentFirst ? currentPlayer.damage(amount: 0) : enemyPlayer.damage(amount: 0)
        }
        ///4) For the next turn, give the speed boost to whoever went first
        currentPlayer.giveSpeedBoost(isCurrentFirst)
        enemyPlayer.giveSpeedBoost(!isCurrentFirst)
    }

    func didLand(attackPosition: AttackPosition, opposingDefense: Defend?) -> Bool {
        guard let opposingDefense else { return true }
        switch opposingDefense.move.position {
        case .forward, .backward:
            return true
        case .left:
            return !attackPosition.isLeft
        case .right:
            return attackPosition.isLeft
        }
    }
}
