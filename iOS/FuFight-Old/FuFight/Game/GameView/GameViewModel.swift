//
//  GameViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/4/24.
//

import SwiftUI

enum GameState {
    case starting
    case gaming
    case gameOver

    var isGameOver: Bool {
        switch self {
        case .starting, .gaming:
            false
        case .gameOver:
            true
        }
    }
}

@Observable
class GameViewModel: BaseViewModel {
    var state: GameState
    var player: Player
    var enemyPlayer: Player
    let isPracticeMode: Bool

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    var isCountingDown: Bool = false
    var timeRemaining = defaultMaxTime
    var isGamePaused: Bool = false
    var secondAttackerDamageDealtReduction: CGFloat = 0
    ///Delay before the second attacker's animation is played
    var secondAttackerDelay: CGFloat = 0

    init(isPracticeMode: Bool) {
        self.state = .starting
        self.isPracticeMode = isPracticeMode
        let photoUrl = Account.current?.photoUrl ?? fakePhotoUrl

        self.player = Player(photoUrl: photoUrl, username: Account.current?.displayName ?? "", hp: defaultMaxHp, maxHp: defaultMaxHp, fighter: Fighter(type: .bianca, isEnemy: false), attacks: Punch.allCases.map { Attack($0) }, defenses: defaultAllDashDefenses)
        self.enemyPlayer = Player(photoUrl: fakePhotoUrl, username: "Zoro", hp: defaultMaxHp, maxHp: defaultMaxHp, fighter: Fighter(type: .samuel, isEnemy: true), attacks: Punch.allCases.map { Attack($0) }, defenses: defaultAllDashDefenses)
        super.init()
    }

    override func onAppear() {
        super.onAppear()
        updateState(.starting)
    }

    //MARK: - Public Methods
    func decrementTimeByOneSecond() {
        //Only countdown when game's state is .gaming and timer is active
        guard isCountingDown else { return }
        guard state == .gaming else { return }
        if timeRemaining > 0.01 {
            timeRemaining -= 0.1
        } else {
            endOfRoundHandler()
        }
    }

    func rematch() {
        player.prepareForRematch()
        enemyPlayer.prepareForRematch()
        updateState(.starting)
    }

    func attackSelected(_ selectedMove: Attack, isEnemy: Bool) {
        guard selectedMove.state != .cooldown else { return }
        for (index, attack) in player.moves.attacks.enumerated() {
            if attack.move.id == selectedMove.move.id {
                player.moves.attacks[index].setStateTo(.selected)
                //TODO: Remove when done testing animations
                if isPracticeMode, let punch = Punch(rawValue: selectedMove.move.id) {
                    playFightersAnimation(attackAnimation: punch.animationType, defenderAnimation: .hitHead, isAttackerEnemy: false)
                } else if isPracticeMode {
                    playFightersAnimation(attackAnimation: selectedMove.move.animationType, defenderAnimation: .hitHead, isAttackerEnemy: false)
                }
            } else {
                guard player.moves.attacks[index].state != .cooldown else { continue }
                player.moves.attacks[index].setStateTo(.unselected)
            }
        }
    }

    func defenseSelected(_ selectedMove: Defend, isEnemy: Bool) {
        guard selectedMove.state != .cooldown else { return }
        for (index, defense) in player.moves.defenses.enumerated() {
            if defense.move.id == selectedMove.move.id {
                player.moves.defenses[index].setStateTo(.selected)
                //TODO: Remove when done testing animations
//                player.fighter.playAnimation(move.animationType)
                if isPracticeMode,
                   let move = Dash(rawValue: selectedMove.move.id) {
                    switch move.position {
                    case .forward:
                        player.fighter.playAnimation(.dodgeHead)
                    case .left:
                        player.fighter.playAnimation(.hitHead)
                    case .backward:
                        player.fighter.playAnimation(.killHead)
                    case .right:
                        player.fighter.playAnimation(.idleStand)
                    }
                }
            } else {
                guard player.moves.defenses[index].state != .cooldown else { continue }
                player.moves.defenses[index].setStateTo(.unselected)
            }
        }
    }

    func scenePhaseChangedHandler(_ scenePhase: ScenePhase) {
        if isTestingEnvironment {
            switch scenePhase {
            case .background, .inactive:
                isCountingDown = false
            case .active:
                LOGD("Restarting timer now that scene phase is active")
                isCountingDown = true
            @unknown default:
                LOGDE("Unknown scene phase \(scenePhase)")
            }
        }
    }

    func updateState(_ newState: GameState) {
        self.state = newState
        switch newState {
        case .starting:
            player.loadAnimations()
            enemyPlayer.loadAnimations()
            updateState(.gaming)
        case .gaming:
            startNewGame()
        case .gameOver:
            gameOver()
        }
    }
}

//MARK: - Private Methods
private extension GameViewModel {
    func startNewGame() {
        let hasSpeedBoost = Bool.random()
        player.state.hasSpeedBoost = hasSpeedBoost
        enemyPlayer.state.hasSpeedBoost = !hasSpeedBoost
        createNewRound()
    }

    func createNewRound() {
        print("\n\n=================================== Round \(self.player.rounds.count + 1) ============================================")
        timeRemaining = defaultMaxTime
        player.prepareForNewRound()
        enemyPlayer.prepareForNewRound()
        isCountingDown = true
    }

    func endOfRoundHandler() {
        isCountingDown = false
        //TODO: Get enemy's selected attack and move for this round that just ended
        //TODO: Remove this auto generated enemy round
        if isTestingEnvironment {
            enemyPlayer.generateEnemyRoundIfNeeded()
        }
        enemyPlayer.populateSelectedMovesAndSpeed()
        player.populateSelectedMovesAndSpeed()
        if !isPracticeMode {
            damageAndAnimate()
        }
    }

    ///Handles both player's attack and defend damages and animations
    func damageAndAnimate() {
        //1. Apply and play first attacker's animations
        var isFirstDefenderAlive = true
        attackingHandler(isFasterAttacker: true)

        //2. Apply and play second attacker's animations after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + secondAttackerDelay) {
            if isFirstDefenderAlive {
                attackingHandler(isFasterAttacker: false)
                self.createNewRound()
            } else {
                self.updateState(.gameOver)
            }
        }

        func attackingHandler(isFasterAttacker: Bool) {
            //Get the attacker and defender
            let attacker: Player
            let defender: Player
            if isFasterAttacker {
                attacker = player.speed > enemyPlayer.speed ? player : enemyPlayer
                defender = player.speed > enemyPlayer.speed ? enemyPlayer : player
                //Second attacker will have their damage dealt reduced and have a delay before playing the next animation
                secondAttackerDelay = attacker.currentRound.attack?.move.animationType.animationDuration ?? 0
                secondAttackerDamageDealtReduction = attacker.currentRound.attack?.move.damageReduction ?? 0

            } else {
                attacker = player.speed > enemyPlayer.speed ? enemyPlayer : player
                defender = player.speed > enemyPlayer.speed ? player : enemyPlayer
                secondAttackerDelay = 0
                secondAttackerDamageDealtReduction = 0
            }

            //Get the damage results
            let attackResult = GameService.getAttackResult(attackerRound: attacker.currentRound, defenderRound: defender.currentRound, defenderHp: defender.hp, damageReduction: secondAttackerDamageDealtReduction)

//            LOGD("AttackingHandler speed \(attacker.speed) vs \(defender.speed) ATTACKER \(attacker.username) \t\t\(attackResult)")

            //Update attacker based on results
            if attackResult.didAttackLand {
                attacker.state.upgradeBoost()
                //First attacker that landed an attack this round will have speedBoost next round
                if isFasterAttacker {
                    attacker.state.hasSpeedBoost = !attacker.isEnemy
                    defender.state.hasSpeedBoost = attacker.isEnemy
                } else {
                    if defender.state.hasSpeedBoost == false {
                        attacker.state.hasSpeedBoost = true
                    }
                }
            } else {
                attacker.state.resetBoost()
            }
            if !attackResult.isDefenderAlive {
                isFirstDefenderAlive = false
            }

            //Play attacker and defender's animations
            if let attack = attacker.currentRound.attack,
               let defenderAnimation = attackResult.defenderAnimation {
                playFightersAnimation(attackAnimation: attack.move.animationType, defenderAnimation: defenderAnimation, isAttackerEnemy: attacker.isEnemy)
            }

            //Update attacker's moves for next round
            let selectedAttackCanBoost: Bool = attacker.currentRound.attack?.move.canBoost ?? false
            attacker.moves.updateAttacksForNextRound(attackLanded: attackResult.didAttackLand, previousAttackCanBoost: selectedAttackCanBoost, boostLevel: attacker.state.boostLevel)
            attacker.moves.updateDefensesForNextRound()

            //Set attacker and defender's round results
            attacker.setCurrentRoundAttackResult(attackResult)
            defender.setCurrentRoundDefendResult(attackResult)
        }
    }

    /// - Parameters:
    ///   - attack: attacker's attack choice
    ///   - defend: defender's defend choice
    ///   - isAttackerEnemy: set to true if the attacking fighter is the enemy
    func playFightersAnimation(attackAnimation: AnimationType, defenderAnimation: AnimationType, isAttackerEnemy: Bool) {
        let attackingFighter = isAttackerEnemy ? enemyPlayer.fighter : player.fighter
        let defendingFighter = isAttackerEnemy ? player.fighter : enemyPlayer.fighter
        attackingFighter.playAnimation(attackAnimation)
        //get delay before playing defender's animation
        //play the defender's animation based on when the attack and defense's delay duration
        DispatchQueue.main.asyncAfter(deadline: .now() + attackAnimation.delayForDefendingAnimation(defenderAnimation)) {
            defendingFighter.playAnimation(defenderAnimation)
        }
    }

    func gameOver() {
        if enemyPlayer.isDead {
            LOGD("Player won", from: GameViewModel.self)
            enemyPlayer.defeated()
        } else if player.isDead {
            LOGD("Enemy won", from: GameViewModel.self)
            player.defeated()
        }
    }
}
