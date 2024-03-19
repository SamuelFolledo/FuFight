//
//  GameViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/4/24.
//

import SwiftUI

@Observable
class GameViewModel: BaseViewModel {
    var player: Player
    var enemyPlayer: Player
    var isGameOver: Bool = false
    var timeRemaining = defaultMaxTime
    var isTimerActive: Bool = false
    var isBackgroundLeadingPadding = Bool.random()
    //TODO: Check the actual maximum padding I can have
    var backgroundPadding = Double.random(in: 0...1000)
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    ///Contains each round's information. New round is created at the beginning of each round. Meanwhile a turn gets created at the end of the round
    var rounds: [Round] = []
    var currentRound: Round { rounds.last! }
    ///Keeps track of which player gets the speed boost next round. True if current player attacked first and landed it
    var hasSpeedBoostNextRound = Int.random(in: 0...1) == 0 //TODO: Multiplayer game mode should be synced between games

    ///Initializer for testing purposes
    override init() {
        let photoUrl = Account.current?.photoUrl ?? URL(string: "https://firebasestorage.googleapis.com:443/v0/b/fufight-51d75.appspot.com/o/Accounts%2FPhotos%2FS4L442FyMoNRfJEV05aFCHFMC7R2.jpg?alt=media&token=0f185bff-4d16-450d-84c6-5d7645a97fb9")!
        self.player = Player(photoUrl: photoUrl, username: Account.current?.username ?? "", hp: defaultMaxHp, maxHp: defaultMaxHp, attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses)
        self.enemyPlayer = Player(photoUrl: photoUrl, username: "Brandon", hp: defaultEnemyHp, maxHp: defaultEnemyHp, attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses)
        super.init()
    }

    init(enemyPlayer: Player) {
        self.player = Player(photoUrl: Account.current!.photoUrl!, username: Account.current!.displayName, hp: defaultEnemyHp, maxHp: defaultEnemyHp, attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses)
        //TODO: Show enemy
        self.enemyPlayer = enemyPlayer
        super.init()
    }

    override func onAppear() {
        super.onAppear()
        startNewGame()
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
            //1. Create a turn from current user's selection
            player.createTurn(from: currentRound)
            //2. Get/Fetch enemy's turn
            enemyPlayer.createTurn(from: currentRound)
            //TODO: Remove this auto generated enemy turn
            enemyPlayer.generateEnemyTurnIfNeeded(currentRound: currentRound)
            //3. Apply damages
            calculateDamages()
            if !isGameOver {
                createNewRound()
                isTimerActive = true
            }
        }
    }

    func rematch() {
        player.prepareForRematch()
        enemyPlayer.prepareForRematch()
        rounds.removeAll()
        startNewGame()
    }

    func attackSelected(_ selectedMove: Attack, isEnemy: Bool) {
        guard selectedMove.state != .cooldown else { return }
        for (index, attack) in currentRound.attacks.enumerated() {
            if attack.move.id == selectedMove.move.id {
                currentRound.attacks[index].setStateTo(.selected)
            } else {
                guard currentRound.attacks[index].state != .cooldown else { continue }
                currentRound.attacks[index].setStateTo(.unselected)
            }
        }
    }

    func defenseSelected(_ selectedMove: Defend, isEnemy: Bool) {
        guard selectedMove.state != .cooldown else { return }
        for (index, defense) in currentRound.defenses.enumerated() {
            if defense.move.id == selectedMove.move.id {
                currentRound.defenses[index].setStateTo(.selected)
            } else {
                guard currentRound.defenses[index].state != .cooldown else { continue }
                currentRound.defenses[index].setStateTo(.unselected)
            }
        }
    }
}

//MARK: - Private Methods
private extension GameViewModel {
    func startNewGame() {
        createNewRound(isFirstRound: true)
        isTimerActive = true
    }

    func createNewRound(isFirstRound: Bool = false) {
        var nextRound: Round
        if isFirstRound {
            nextRound = Round(round: rounds.count + 1, attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses, hasSpeedBoost: hasSpeedBoostNextRound, enemyAttacks: defaultAllPunchAttacks, enemyDefenses: defaultAllDashDefenses)
        } else {
            nextRound = Round(previousRound: currentRound, hasSpeedBoost: hasSpeedBoostNextRound)
            nextRound.updateAttacksFireStateForNextRound(previousRound: currentRound, boostLevel: player.boostLevel)
        }
        rounds.append(nextRound)
    }

    func gameOver() {
        if enemyPlayer.hp <= 0 {
            LOGD("Player won")
            enemyPlayer.gameOver()
        } else if player.hp <= 0 {
            LOGD("Enemy won")
            player.gameOver()
        }
        isGameOver = true
    }

    func calculateDamages() {
        ///1) Check which player  is faster to see who goes first
        let isCurrentFirst = player.currentTurn.speed > enemyPlayer.currentTurn.speed
        let firstPlayer = isCurrentFirst ? player : enemyPlayer
        let secondPlayer = isCurrentFirst ? enemyPlayer : player
        let firstTurn = firstPlayer.currentTurn
        let secondTurn = secondPlayer.currentTurn
        ///2) Apply first attacker's damage
        var secondAttackDamageReduction: CGFloat = 0
        if let firstAttack = firstTurn.attack {
            if secondTurn.didDodge(firstAttack) {
                applyDamage(nil, to: secondPlayer)
            } else {
                let totalDamage = getTotalDamage(attackerTurn: firstTurn, defenderTurn: secondTurn)
                applyDamage(totalDamage, to: secondPlayer)
                if enemyPlayer.isDead || player.isDead {
                    return gameOver()
                }
                ///Additional damage reduction for the second attacker
                secondAttackDamageReduction = firstAttack.move.damageReduction
            }
        } else {
            applyDamage(0, to: secondPlayer)
        }

        ///3) Apply second attacker's damage
        if let secondAttack = secondTurn.attack {
            if firstTurn.didDodge(secondAttack) {
                applyDamage(nil, to: firstPlayer)
            } else {
                let totalDamage = getTotalDamage(attackerTurn: secondTurn, defenderTurn: firstTurn, secondAttackDamageReduction: secondAttackDamageReduction)
                applyDamage(totalDamage, to: firstPlayer)
                if enemyPlayer.isDead || player.isDead {
                    return gameOver()
                }
            }
        } else {
            applyDamage(0, to: firstPlayer)
        }
        ///4) For the next turn, give the speed boost to whoever went first
        //TODO: Fix who gets the speed boost if dodged here
        hasSpeedBoostNextRound = isCurrentFirst
    }

    /// Returns the attacker's total damage based on defender's defend choice
    /// - Parameters:
    ///   - attackerTurn: attacker's attack
    ///   - defenderTurn: defender's defend choice
    ///   - secondAttackDamageReduction: only pass a value if attacker is going second
    func getTotalDamage(attackerTurn: Turn, defenderTurn: Turn, secondAttackDamageReduction: CGFloat = 0) -> CGFloat {
        let baseDamage = attackerTurn.attack?.move.damage ?? 0
        let defenseDamageMultiplier = attackerTurn.defend?.move.damageMultiplier ?? 0
        let boostDamageMultiplier = attackerTurn.attack?.fireState?.boostMultiplier ?? 0
        let enemyDamageReduction = defenderTurn.defend?.move.defenseMultiplier ?? 0
        let totalDamage = baseDamage * (defenseDamageMultiplier + boostDamageMultiplier + 1) * (1 - enemyDamageReduction - secondAttackDamageReduction)
        return totalDamage
    }

    ///Applies damage to player and update the attacker's boost level
    func applyDamage(_ damage: CGFloat?, to playerToDamage: Player) {
        playerToDamage.damage(amount: damage)
        let didDodge = damage == nil || (damage ?? 0) == 0
        if playerToDamage.isEnemy {
            currentRound.damage = damage
            //Increment boost level if attack landed, or set to 9
            player.setBoostLevel(to: didDodge ? 0 : player.boostLevel + 1)
        } else {
            currentRound.enemyDamage = damage
            enemyPlayer.setBoostLevel(to: didDodge ? 0 : enemyPlayer.boostLevel + 1)
        }
    }
}
