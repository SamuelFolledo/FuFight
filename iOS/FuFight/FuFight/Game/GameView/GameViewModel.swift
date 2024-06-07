//
//  GameViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/4/24.
//

import Combine
import FirebaseFirestore
import SwiftUI

class GameViewModel: BaseViewModel {
    @Published var state: GameState
    @Published var player: Player
    @Published var enemy: Player
    let gameMode: GameRoute

    let didExitGame = PassthroughSubject<GameViewModel, Never>()
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Published var timeRemaining = defaultMaxTime
    var isCountingDown: Bool = false
    @Published var isGamePaused: Bool = false
    var isDefenderAlive = true
    var secondAttackerDamageDealtReduction: CGFloat = 0
    var secondAttackerDelay: CGFloat = 0

    private var isPlayerRoundReady: Bool = false
    private var isEnemyRoundReady: Bool = false
    private var enemyMovesListener: ListenerRegistration?
    private var subscriptions = Set<AnyCancellable>()

    init(player: Player, enemy: Player, gameMode: GameRoute) {
        self.state = .starting
        self.gameMode = gameMode
        self.player = player
        self.enemy = enemy
        super.init()
    }

    override func onAppear() {
        super.onAppear()
        updateState(.starting)
        listenToEnemyGameDocument()
    }

    override func onDisappear() {
        super.onDisappear()
        player.prepareForRematch()
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
        enemy.prepareForRematch()
        updateState(.starting)
    }

    func attackSelected(_ selectedMove: any MoveProtocol, isEnemy: Bool) {
        guard selectedMove.state != .cooldown,
              let selectedAttack = Attack(moveId: selectedMove.id) else { return }
        isEnemy ? enemy.moves.updateSelected(selectedAttack.position) : player.moves.updateSelected(selectedAttack.position)
        let attackResult = AttackResult.damage(20)
        switch gameMode {
        case .practice:
            //Play that attack's animation
            if let defenderAnimation = GameService.getDefenderAnimation(attack: selectedAttack, attackerType: enemy.fighter.fighterType, attackResult: attackResult) {
                playFightersAnimation(attackAnimation: selectedAttack.animationType, defenderAnimation: defenderAnimation, isAttackerEnemy: false) {
                    runAfterDelay(delay: 0.3) { [weak self] in
                        guard let self else { return }
                        self.enemy.fighter.showResult(attackResult)
                    }
                }
            }
        case .onlineGame, .offlineGame:
            break
        }
    }

    func defenseSelected(_ selectedMove: any MoveProtocol, isEnemy: Bool) {
        guard selectedMove.state != .cooldown,
              let selectedDefense = Defense(moveId: selectedMove.id) else { return }
        isEnemy ? enemy.moves.updateSelected(selectedDefense.position) : player.moves.updateSelected(selectedDefense.position)
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
            enemy.loadAnimations()
            updateState(.gaming)
        case .gaming:
            startNewGame()
        case .gameOver:
            gameOver()
        }
    }

    func exitGame() {
        didExitGame.send(self)
        Task {
            do {
                if player.isGameOwner {
                    try await GameNetworkManager.deleteGame(player.userId)
                }
            }
        }
    }
}

//MARK: - Private Methods
private extension GameViewModel {
    func startNewGame() {
        isDefenderAlive = true
        createNewRound()
    }

    func createNewRound() {
        player.prepareForNewRound()
        print("\n\n=================================== Round \(self.player.rounds.count) ============================================")
        enemy.prepareForNewRound()
        timeRemaining = defaultMaxTime
        secondAttackerDelay = 0
        secondAttackerDamageDealtReduction = 0
        isDefenderAlive = true
        isCountingDown = true
        isPlayerRoundReady = false
        isEnemyRoundReady = false
    }

    func endOfRoundHandler() {
        isCountingDown = false
        /*
         TODO: Send selected moves to database
         TODO: Listen to enemy's move's changes
         TODO: Fetch enemy's moves if available
        */
        switch gameMode {
        case .practice:
            break
        case .offlineGame:
            enemy.moves.randomlySelectMoves()
            enemy.populateSelectedMoves()
            player.populateSelectedMoves()
            damageAndAnimate()
        case .onlineGame:
            player.populateSelectedMoves()
            Task {
                let gameId = player.isGameOwner ? player.userId : enemy.userId
                do {
                    try await GameNetworkManager.uploadSelectedMoves(rounds: player.rounds, isGameOwner: player.isGameOwner, gameId: gameId)
                    if isEnemyRoundReady {
                        LOGD("FETCHED animating from owner")
                        damageAndAnimate()
                    }
                    isPlayerRoundReady = true
                } catch {
                    LOGDE("Error uploading selected moves with: \(error.localizedDescription)")
                }
            }
        }
    }

    ///Handles both player's attack and defend damages and animations
    func damageAndAnimate() {
        enemy.refreshSpeed()
        player.refreshSpeed()

        //1. Apply and play first attacker's animations
        attackingHandler(isFasterAttacker: true)

        //2. Apply and play second attacker's animations after a delay
        runAfterDelay(delay: secondAttackerDelay) { [weak self] in
            guard let self else { return }
            if isDefenderAlive {
                attackingHandler(isFasterAttacker: false)

                if isDefenderAlive {
                    runAfterDelay(delay: secondAttackerDelay) { [weak self] in
                        self?.createNewRound()
                    }
                    return
                }
            }
            updateState(.gameOver)
        }
    }

    func attackingHandler(isFasterAttacker: Bool) {
        //Get the attacker and defender
        let attacker: Player
        let defender: Player
        if isFasterAttacker {
            if player.speed == enemy.speed {
                attacker = player.state.hasSpeedBoost ? player : enemy
                defender = player.state.hasSpeedBoost ? enemy : player
            } else {
                attacker = player.speed > enemy.speed ? player : enemy
                defender = player.speed > enemy.speed ? enemy : player
                //Second attacker will have their damage dealt reduced and have a delay before playing the next animation
            }
            secondAttackerDelay = attacker.currentRound?.attack?.animationType.animationDuration(for: attacker.fighter.fighterType) ?? 0
            secondAttackerDamageDealtReduction = attacker.currentRound?.attack?.damageReduction ?? 1
        } else {
            if player.speed == enemy.speed {
                attacker = player.state.hasSpeedBoost ? enemy : player
                defender = player.state.hasSpeedBoost ? player : enemy
            } else {
                attacker = player.speed > enemy.speed ? enemy : player
                defender = player.speed > enemy.speed ? player : enemy
            }
            secondAttackerDelay = attacker.currentRound?.attack?.animationType.animationDuration(for: attacker.fighter.fighterType) ?? 0
        }

        //Get the damage results
        guard let attackerRound = attacker.currentRound,
              let defenderRound = defender.currentRound else {
            LOGDE("Attacking handler has no current round for \(attacker.currentRound != nil ? attacker.currentRound.debugDescription : "nil") and \(defender.currentRound != nil ? defender.currentRound.debugDescription : "nil")")
            return
        }
        let attackResult = GameService.getAttackResult(attackerRound: attackerRound, defenderRound: defenderRound, defenderHp: defender.hp, damageReduction: isFasterAttacker ? 1 : secondAttackerDamageDealtReduction)

        LOGD("AttackHandler \(attacker.fighter.fighterType.name) (\(attacker.speed)) with \(attackerRound.attack?.name ?? "no attack") \t\t vs \(defenderRound.defend?.name ?? "no defense") \t\t\(attackResult)")

        //Update attacker based on results
        if attackResult.didAttackLand {
            attacker.state.upgradeBoost()
            //First attacker that landed an attack this round will have speedBoost next round
            if isFasterAttacker {
                attacker.state.setSpeedBoost(to: true)
                defender.state.setSpeedBoost(to: false)
            } else {
                if !(defenderRound.attackResult?.didAttackLand ?? true) {
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

        //Play attacker's and defender's animations
        if let attack = attackerRound.attack,
           let defenderAnimation = GameService.getDefenderAnimation(attack: attack, attackerType: attacker.fighter.fighterType, attackResult: attackResult) {
            playFightersAnimation(attackAnimation: attack.animationType, defenderAnimation: defenderAnimation, isAttackerEnemy: attacker.isEnemy) {
                //Show attack result's damage after a little delay
                runAfterDelay(delay: 0.3) {
                    defender.fighter.showResult(attackResult)
                }
            }
        }
    }

    /// - Parameters:
    ///   - attack: attacker's attack choice
    ///   - defend: defender's defend choice
    ///   - isAttackerEnemy: set to true if the attacking fighter is the enemy
    func playFightersAnimation(attackAnimation: AnimationType, defenderAnimation: AnimationType, isAttackerEnemy: Bool, completion: (() -> Void)? = nil) {
        let attackingFighter = isAttackerEnemy ? enemy.fighter : player.fighter
        let defendingFighter = isAttackerEnemy ? player.fighter : enemy.fighter
        attackingFighter.playAnimation(attackAnimation)
        //get delay before playing defender's animation
        //play the defender's animation based on when the attack and defense's delay duration
        let delayForDefenderAnimation = attackAnimation.delayForDefendingAnimation(defenderAnimation, defender: defendingFighter.fighterType, attacker: attackingFighter.fighterType)
        runAfterDelay(delay: delayForDefenderAnimation) {
            defendingFighter.playAnimation(defenderAnimation)
            completion?()
        }
    }

    func gameOver() {
        if enemy.isDead {
            LOGD("Player won", from: GameViewModel.self)
            enemy.defeated()
        } else if player.isDead {
            LOGD("Enemy won", from: GameViewModel.self)
            player.defeated()
        }
    }

    func unsubscribeToEnemyGameDocument() {
        if enemyMovesListener != nil {
            enemyMovesListener?.remove()
            enemyMovesListener = nil
        }
    }

    func listenToEnemyGameDocument() {
        if enemyMovesListener != nil {
            unsubscribeToEnemyGameDocument()
        }
        let gameId = player.isGameOwner ? player.userId : enemy.userId
        let playerDocumentId = player.isGameOwner ? kCHALLENGER : kOWNER
        let query = gamesDb.document(gameId).collection(kPLAYERS).document(playerDocumentId)
        enemyMovesListener = query
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self,
                        let snapshot,
                      snapshot.exists,
                      !snapshot.metadata.hasPendingWrites
                else { return }
                do {
                    let playerDoc = try snapshot.data(as: PlayerDocument.self)
                    if enemy.rounds.count != playerDoc.selectedMoves.count {
                        LOGE("After receiving PlayerDocument changes, the count for enemy rounds and selected moves is not the same")
                        TODO("Test if it goes here. If it does then populate enemy rounds with null selected moves until the rounds count is the same")
                    }
                    enemy.moves.updateSelected(playerDoc.selectedMoves.last!.attackPosition)
                    enemy.moves.updateSelected(playerDoc.selectedMoves.last!.defensePosition)
                    enemy.populateSelectedMoves()
                    if isPlayerRoundReady {
                        damageAndAnimate()
                    }
                    isEnemyRoundReady = true
                } catch {
                    LOGDE("Error creating room with error: \(error.localizedDescription)\t\t and data: \(snapshot.data()?.description ?? "")")
                }
            }
    }
}
