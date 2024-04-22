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
    var fighter: Fighter!
    var enemyPlayer: Player
    var enemyFighter: Fighter!
    var isGameOver: Bool = false
    ///Note this will not pause the game for online games
    var isGamePaused: Bool = false
    var timeRemaining = defaultMaxTime
    var isTimerActive: Bool = false
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    ///Contains each round's information. New round is created at the beginning of each round. Meanwhile a turn gets created at the end of the round
    var rounds: [Round] = []
    var currentRound: Round { rounds.last! }
    ///Keeps track of which player gets the speed boost next round. True if current player attacked first and landed it
    var hasSpeedBoostNextRound = Int.random(in: 0...1) == 0 //TODO: Multiplayer game mode should be synced between games
    var isPracticeMode = false

    init(isPracticeMode: Bool) {
        self.isPracticeMode = isPracticeMode
        let photoUrl = Account.current?.photoUrl ?? URL(string: "https://firebasestorage.googleapis.com:443/v0/b/fufight-51d75.appspot.com/o/Accounts%2FPhotos%2FS4L442FyMoNRfJEV05aFCHFMC7R2.jpg?alt=media&token=0f185bff-4d16-450d-84c6-5d7645a97fb9")!
        self.player = Player(photoUrl: photoUrl, username: Account.current?.username ?? "", hp: defaultMaxHp, maxHp: defaultMaxHp, attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses)
        self.enemyPlayer = Player(photoUrl: photoUrl, username: "Brandon", hp: defaultEnemyHp, maxHp: defaultEnemyHp, attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses)
        super.init()
        populateFighters()
    }

    func populateFighters() {
        let attacks: [AnimationType] = [.punchHeadLeftLight, .punchHeadLeftMedium, .punchHeadLeftHard, .punchHeadRightLight, .punchHeadRightMedium, .punchHeadRightHard]
        let otherAnimations: [AnimationType] = [.idle, .idleStand, .dodgeHead, .hitHead, .killHead]
        fighter = Fighter(type: .bianca, isEnemy: false)
        fighter.loadAnimations(animations: otherAnimations + attacks)

        enemyFighter = Fighter(type: .samuel, isEnemy: true)
        enemyFighter.loadAnimations(animations: otherAnimations + attacks)
    }

    override func onAppear() {
        super.onAppear()
        startNewGame()
    }

    //MARK: - Public Methods
    func decrementTimeByOneSecond() {
        guard isTimerActive else { return }
        if timeRemaining > 0.01 {
            timeRemaining -= 0.1
        } else {
            endOfRoundHandler()
            timeRemaining = defaultMaxTime
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
                //TODO: Remove when done testing animations
                if isPracticeMode,
                   let move = Punch(rawValue: selectedMove.move.id) {
//                    fighter.playAnimation(move.animationType)
                    playAnimation(attack: selectedMove.move, defenderAnimation: .hitHead, isAttackerEnemy: false)
                }
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
                //TODO: Remove when done testing animations
//                fighter.playAnimation(.killHead)
                if isPracticeMode,
                   let move = Dash(rawValue: selectedMove.move.id) {
                    switch move.position {
                    case .forward:
                        fighter.playAnimation(.dodgeHead)
                    case .left:
                        fighter.playAnimation(.hitHead)
                    case .backward:
                        fighter.playAnimation(.killHead)
                    case .right:
                        fighter.playAnimation(.idleStand)
                    }
//                    fighter.playAnimation(move.animationType)
                }
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

    func endOfRoundHandler() {
        isTimerActive = false
        //1. Create a turn from current user's selection
        player.createTurn(from: currentRound)
        //2. Get/Fetch enemy's turn
        enemyPlayer.createTurn(from: currentRound)
        //TODO: Remove this auto generated enemy turn
        enemyPlayer.generateEnemyTurnIfNeeded(currentRound: currentRound)
        //3. Apply damages
        if !isPracticeMode {
            calculateDamages()
        }
        if enemyPlayer.hp <= 0 {
            LOGD("Player won")
            isGameOver = true
            enemyPlayer.gameOver()
        } else if player.hp <= 0 {
            LOGD("Enemy won")
            isGameOver = true
            player.gameOver()
        } else {
            createNewRound()
            isTimerActive = true
        }
    }

    func createNewRound(isFirstRound: Bool = false) {
        var nextRound: Round
        if isFirstRound {
            nextRound = Round(round: rounds.count + 1, attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses, hasSpeedBoost: hasSpeedBoostNextRound, enemyAttacks: defaultAllPunchAttacks, enemyDefenses: defaultAllDashDefenses)
        } else {
            nextRound = Round(previousRound: currentRound, hasSpeedBoost: hasSpeedBoostNextRound)
            updateAttacksWithFireForNextRound(previousRound: currentRound, attacksToUpdate: &nextRound.attacks, player: player)
            updateAttacksWithFireForNextRound(previousRound: currentRound, attacksToUpdate: &nextRound.enemyAttacks, player: enemyPlayer)
        }
        rounds.append(nextRound)
    }
    
    ///Update attacks's fire state based on previous round and boost level
    func updateAttacksWithFireForNextRound(previousRound: Round, attacksToUpdate: inout [Attack], player: Player) {
        let isEnemy = player.isEnemy
        let didLand: Bool
        let didAttack: Bool
        if isEnemy {
            didLand = previousRound.enemyDamage != nil
            didAttack = previousRound.selectedEnemyAttack != nil
        } else {
            didLand = previousRound.damage != nil
            didAttack = previousRound.selectedAttack != nil
        }
        for index in attacksToUpdate.indices {
            if !didLand || !didAttack {
                //If previous attack is nil or missed, do not boost
                attacksToUpdate[index].setFireTo(nil)
                continue
            }
            let previousAttack = isEnemy ? previousRound.selectedEnemyAttack! : previousRound.selectedAttack!
            if !previousAttack.move.canBoost {
                //If previous attack cannot boost, do not boost
                attacksToUpdate[index].setFireTo(nil)
                continue
            }
            //If previous attack landed and can boost, set fire depending on the boost level
            switch player.boostLevel {
            case 0:
                attacksToUpdate[index].setFireTo(nil)
            case 1:
                //Do not boost the hard attacks on stage 1 boost
                let hardAttackPositions: [AttackPosition] = [.rightHard, .leftHard]
                if let position = attacksToUpdate[index].move.position,
                   !hardAttackPositions.contains(position) {
                    if attacksToUpdate[index].move.canBoost {
                        //If light or medium attack can boost, set it to small fire
                        attacksToUpdate[index].setFireTo(.small)
                    } else {
                        //If light or medium attack cannot boost, then set it to big fire
                        attacksToUpdate[index].setFireTo(.big)
                    }
                } else {
                    attacksToUpdate[index].setFireTo(nil)
                }
            case 2:
                attacksToUpdate[index].setFireTo(.big)
            default:
                attacksToUpdate[index].setFireTo(nil)
                LOGE("Invalid boost level")
            }
        }
    }

    func calculateDamages() {
        ///1) Check which player  is faster to see who goes first
        let isCurrentFirst = player.currentTurn.speed > enemyPlayer.currentTurn.speed
        let firstPlayer = isCurrentFirst ? player : enemyPlayer
        let secondPlayer = isCurrentFirst ? enemyPlayer : player
        let firstTurn = firstPlayer.currentTurn
        let secondTurn = secondPlayer.currentTurn
        let firstFighter = isCurrentFirst ? fighter! : enemyFighter!
        let secondFighter = isCurrentFirst ? enemyFighter! : fighter!
        var nextAttackDelayDuration: CGFloat = 0
        ///2) Apply first attacker's damage
        var secondAttackDamageReduction: CGFloat = 0
        if let firstAttack = firstTurn.attack {
            nextAttackDelayDuration = firstAttack.move.animationType.animationDuration
                //TODO: Get the delay from first attack before playing the second fighter's defense animation
            if secondTurn.didDodge(firstAttack) {
                applyDamage(nil, to: secondPlayer)
                playAnimation(attack: firstAttack.move, defenderAnimation: .dodgeHead, isAttackerEnemy: firstFighter.isEnemy)
            } else {
                let totalDamage = getTotalDamage(attackerTurn: firstTurn, defenderTurn: secondTurn)
                applyDamage(totalDamage, to: secondPlayer)
                if enemyPlayer.isDead || player.isDead {
                    playAnimation(attack: firstAttack.move, defenderAnimation: .killHead, isAttackerEnemy: firstFighter.isEnemy)
                    return
                } else {
                    playAnimation(attack: firstAttack.move, defenderAnimation: .hitHead, isAttackerEnemy: firstFighter.isEnemy)
                }
                ///Additional damage reduction for the second attacker
                secondAttackDamageReduction = firstAttack.move.damageReduction
            }
        } else {
            applyDamage(0, to: secondPlayer)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + (nextAttackDelayDuration + 0.2)) {
            ///3) Apply second attacker's damage
            if let secondAttack = secondTurn.attack {
                if firstTurn.didDodge(secondAttack) {
                    self.applyDamage(nil, to: firstPlayer)
                    self.playAnimation(attack: secondAttack.move, defenderAnimation: .dodgeHead, isAttackerEnemy: secondFighter.isEnemy)
                } else {
                    let totalDamage = self.getTotalDamage(attackerTurn: secondTurn, defenderTurn: firstTurn, secondAttackDamageReduction: secondAttackDamageReduction)
                    self.applyDamage(totalDamage, to: firstPlayer)
                    if self.enemyPlayer.isDead || self.player.isDead {
                        self.playAnimation(attack: secondAttack.move, defenderAnimation: .killHead, isAttackerEnemy: secondFighter.isEnemy)
                        return
                    } else {
                        self.playAnimation(attack: secondAttack.move, defenderAnimation: .hitHead, isAttackerEnemy: secondFighter.isEnemy)
                    }
                }
            } else {
                self.applyDamage(0, to: firstPlayer)
            }
            ///4) For the next turn, give the speed boost to whoever went first
            //TODO: Fix who gets the speed boost if dodged here
            self.hasSpeedBoostNextRound = isCurrentFirst
        }
    }

    /// - Parameters:
    ///   - attack: attacker's attack choice
    ///   - defend: defender's defend choice
    ///   - isAttackerEnemy: set to true if the attacking fighter is the enemy
    func playAnimation(attack: any AttackProtocol, defenderAnimation: AnimationType, isAttackerEnemy: Bool) {
        let attackingFighter = isAttackerEnemy ? enemyFighter : fighter
        let defendingFighter = isAttackerEnemy ? fighter : enemyFighter
        DispatchQueue.main.async {
            attackingFighter?.playAnimation(attack.animationType)
        }
        //get delay before playing defender's animation
        //play the defender's animation based on when the attack lands
        DispatchQueue.main.asyncAfter(deadline: .now() + attack.animationType.delayForDefendingAnimation(defenderAnimation)) {
            defendingFighter?.playAnimation(defenderAnimation)
        }
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
            //Increment boost level if attack landed, or set to 0
            player.setBoostLevel(to: didDodge ? 0 : player.boostLevel + 1)
        } else {
            currentRound.enemyDamage = damage
            enemyPlayer.setBoostLevel(to: didDodge ? 0 : enemyPlayer.boostLevel + 1)
        }
    }
}
