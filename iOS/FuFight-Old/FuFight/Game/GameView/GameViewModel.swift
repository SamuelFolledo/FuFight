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
    
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var timeRemaining = defaultMaxTime
    var isCountingDown: Bool = false
    var isGamePaused: Bool = false
    var isDefenderAlive = true
    var secondAttackerDamageDealtReduction: CGFloat = 0
    var secondAttackerDelay: CGFloat = 0

    init(isPracticeMode: Bool) {
        self.state = .starting
        self.isPracticeMode = isPracticeMode
        let photoUrl = Account.current?.photoUrl ?? fakePhotoUrl

        self.player = Player(photoUrl: photoUrl,
                             username: Account.current?.displayName ?? "",
                             hp: defaultMaxHp,
                             maxHp: defaultMaxHp,
                             fighter: Fighter(type: .bianca, isEnemy: false),
                             state: PlayerState(boostLevel: .none, hasSpeedBoost: false),
                             moves: Moves(attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses))
        self.enemyPlayer = fakeEnemyPlayer
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
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            endOfRoundHandler()
        }
    }

    func rematch() {
        player.prepareForRematch()
        enemyPlayer.prepareForRematch()
        updateState(.starting)
    }

    func attackSelected(_ selectedMove: any MoveProtocol, isEnemy: Bool) {
        guard selectedMove.state != .cooldown,
            let selectedAttack = Attack(move: selectedMove) else { return }
        isEnemy ? enemyPlayer.moves.updateSelected(selectedAttack.position) : player.moves.updateSelected(selectedAttack.position)
    }

    func defenseSelected(_ selectedMove: any MoveProtocol, isEnemy: Bool) {
        guard selectedMove.state != .cooldown,
              let selectedDefense = Defense(move: selectedMove) else { return }
        isEnemy ? enemyPlayer.moves.updateSelected(selectedDefense.position) : player.moves.updateSelected(selectedDefense.position)
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
            timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
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
        player.state.setSpeedBoost(to: hasSpeedBoost)
        enemyPlayer.state.setSpeedBoost(to: !hasSpeedBoost)
        isDefenderAlive = true
        createNewRound()
    }

    func createNewRound() {
        player.prepareForNewRound()
        print("\n\n=================================== Round \(self.player.rounds.count) ============================================")
        enemyPlayer.prepareForNewRound()
        timeRemaining = defaultMaxTime
        secondAttackerDelay = 0
        secondAttackerDamageDealtReduction = 0
        isDefenderAlive = true
        isCountingDown = true
    }

    func endOfRoundHandler() {
        isCountingDown = false
        if isTestingEnvironment {
            //TODO: Remove this auto generated enemy round
            enemyPlayer.moves.randomlySelectMoves()
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
        attackingHandler(isFasterAttacker: true)

        //2. Apply and play second attacker's animations after a delay
        runAfterDelay(delay: secondAttackerDelay) {
            if self.isDefenderAlive {
                self.attackingHandler(isFasterAttacker: false)

                if self.isDefenderAlive {
                    self.createNewRound()
                    return
                }
            }
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
            secondAttackerDelay = attacker.currentRound.attack?.animationType.animationDuration ?? 0
            secondAttackerDamageDealtReduction = attacker.currentRound.attack?.damageReduction ?? 0

        } else {
            attacker = player.speed > enemyPlayer.speed ? enemyPlayer : player
            defender = player.speed > enemyPlayer.speed ? player : enemyPlayer
            secondAttackerDelay = 0
            secondAttackerDamageDealtReduction = 0
        }

        //Get the damage results
        let attackResult = GameService.getAttackResult(attackerRound: attacker.currentRound, defenderRound: defender.currentRound, defenderHp: defender.hp, damageReduction: secondAttackerDamageDealtReduction)

        LOGD("AttackingHandler \(attacker.fighter.fighterType.name) (\(attacker.speed)) with \(attacker.currentRound.attack?.name ?? "no attack") \t\t vs \(defender.currentRound.defend?.name ?? "no defense") \t\t\(attackResult)")

        //Update attacker based on results
        if attackResult.didAttackLand {
            attacker.state.upgradeBoost()
            //First attacker that landed an attack this round will have speedBoost next round
            if isFasterAttacker {
                attacker.state.setSpeedBoost(to: true)
                defender.state.setSpeedBoost(to: false)
            } else {
                if !(defender.currentRound.attackResult?.didAttackLand ?? true) {
                    attacker.state.setSpeedBoost(to: true)
                    defender.state.setSpeedBoost(to: false)
                }
            }
        } else {
            attacker.state.resetBoost()
        }

        isDefenderAlive = attackResult.isDefenderAlive

        //Set attacker and defender's round results
        attacker.setCurrentRoundAttackResult(attackResult)
        defender.setCurrentRoundDefendResult(attackResult)

        //Play attacker and defender's animations
        if let attack = attacker.currentRound.attack,
           let defenderAnimation = attackResult.defenderAnimation {
            playFightersAnimation(attackAnimation: attack.animationType, defenderAnimation: defenderAnimation, isAttackerEnemy: attacker.isEnemy)
        }
    }

    /// - Parameters:
    ///   - attack: attacker's attack choice
    ///   - defend: defender's defend choice
    ///   - isAttackerEnemy: set to true if the attacking fighter is the enemy
    func playFightersAnimation(attackAnimation: AnimationType, defenderAnimation: AnimationType, isAttackerEnemy: Bool) {
        Task {
            let attackingFighter = isAttackerEnemy ? enemyPlayer.fighter : player.fighter
            let defendingFighter = isAttackerEnemy ? player.fighter : enemyPlayer.fighter
            attackingFighter.playAnimation(attackAnimation)
            //get delay before playing defender's animation
            //play the defender's animation based on when the attack and defense's delay duration
            runAfterDelay(delay: attackAnimation.delayForDefendingAnimation(defenderAnimation)) {
                defendingFighter.playAnimation(defenderAnimation)
            }
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
