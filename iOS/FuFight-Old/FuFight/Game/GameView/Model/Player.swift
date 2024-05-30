//
//  Player.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/11/24.
//

import Foundation

struct PlayerState {
    private(set) var boostLevel: BoostLevel
    ///Keeps track of which player gets the speed boost next round. True if current player attacked first and landed it
    private(set) var hasSpeedBoost: Bool //TODO: Multiplayer game mode should be synced between games

    init(boostLevel: BoostLevel, hasSpeedBoost: Bool) {
        self.boostLevel = boostLevel
        self.hasSpeedBoost = hasSpeedBoost
    }

    mutating func upgradeBoost() {
        boostLevel = boostLevel.nextLevel
    }

    mutating func resetBoost() {
        boostLevel = .none
    }

    mutating func setSpeedBoost(to shouldBoost: Bool) {
        hasSpeedBoost = shouldBoost
    }
}

protocol PlayerProtocol: ObservableObject {
    var userId: String { get }
    var username: String { get }
    var photoUrl: URL { get }
    var moves: Moves { get set }
}

@Observable
class Player: PlayerProtocol {
    private(set) var photoUrl: URL
    private(set) var username: String
    private(set) var userId: String
    private(set) var hp: CGFloat
    private(set) var maxHp: CGFloat
    private(set) var isEnemy: Bool
    var fighter: Fighter
    var state: PlayerState
    var moves: Moves
    var rounds: [Round]

    var speed: CGFloat = 0

    var currentRound: Round? { return rounds.last }
    var isDead: Bool { hp <= 0 }
    var hpText: String { String(format: "%.2f", hp) }

    init(userId: String, photoUrl: URL, username: String, hp: CGFloat, maxHp: CGFloat, fighter: Fighter, state: PlayerState, moves: Moves) {
        self.userId = userId
        self.photoUrl = photoUrl
        self.username = username
        self.hp = hp
        self.maxHp = maxHp
        self.isEnemy = username != (Account.current?.username ?? "")
        self.fighter = fighter
        self.state = state
        self.moves = moves
        self.rounds = []
        self.speed = 0
    }

    ///Room owner's initializer
    init(fetchedPlayer: FetchedPlayer, isEnemy: Bool) {
        self.photoUrl = fetchedPlayer.photoUrl
        self.username = fetchedPlayer.username
        self.userId = fetchedPlayer.userId
        self.moves = fetchedPlayer.moves
        self.fighter = Fighter(type: fetchedPlayer.fighterType, isEnemy: isEnemy)
        self.hp = defaultMaxHp
        self.maxHp = defaultMaxHp
        self.rounds = []
        self.speed = 0
        self.isEnemy = isEnemy
        //TODO: hasSpeedBoost should not be false
        self.state = .init(boostLevel: .none, hasSpeedBoost: false)
    }

    func loadAnimations() {
        fighter.loadAnimations(animations: moves.animationTypes)
    }

    func populateSelectedMovesAndSpeed() {
        let selectedAttack = moves.attacks.first(where: { $0.state == .selected })
        let selectedDefend = moves.defenses.first(where: { $0.state == .selected })
        rounds[rounds.count - 1].attack = selectedAttack
        rounds[rounds.count - 1].defend = selectedDefend

        let moveSpeed = selectedAttack?.speed ?? 0
        let speedMultiplier = selectedDefend?.speedMultiplier ?? 1
        let speedBoostMultiplier = state.hasSpeedBoost ? speedBoostMultiplier : 1
        speed = (moveSpeed * speedMultiplier * speedBoostMultiplier).roundDecimalUpTo(1)
    }

    /// - Parameters:
    ///   - amount: Amount of damage this player received. Nil damage means this player dodged the enemy's attack
    func setCurrentRoundDefendResult(_ enemyResult: AttackResult) {
        hp -= enemyResult.damage ?? 0
    }

    func setCurrentRoundAttackResult(_ result: AttackResult) {
        //Populate current round's result
        let currentRoundIndex = rounds.count - 1
        rounds[currentRoundIndex].attackResult = result
        //Update attacks and defenses for next turn
        moves.updateAttacksForNextRound(attackLanded: result.didAttackLand, boostLevel: state.boostLevel)
        moves.updateDefensesForNextRound()
    }

    func prepareForNewRound() {
        speed = 0
        let newRound = Round(round: rounds.count + 1)
        rounds.append(newRound)
    }

    func defeated() {
        hp = 0
    }

    func prepareForRematch() {
        hp = maxHp
        rounds.removeAll()
        state.resetBoost()
        moves.resetMoves()
        fighter.resumeAnimations()
    }
}

extension Player: Equatable {
    static func ==(lhs: Player, rhs: Player) -> Bool {
        return lhs.userId == rhs.userId
    }
}

private extension Player {}
