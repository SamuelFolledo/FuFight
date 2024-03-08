//
//  GameViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/4/24.
//

import SwiftUI

struct Player {
    var photoUrl: URL
    var username: String
    var hp: CGFloat
    let maxHp: CGFloat
    var attacks: [Attack]
    var defenses: [Defend]
    var turns: [Turn] = []

    mutating func prepareForNextRound() {
        var turn = Turn(round: turns.count + 1)
        for index in attacks.indices {
            switch attacks[index].state {
            case .selected:
                turn.update(attacks[index])
                attacks[index].setStateTo(.cooldown)
            case .cooldown:
                attacks[index].reduceCooldown()
            case .initial, .unselected, .bigFire, .smallFire:
                attacks[index].setStateTo(.initial)
            }
        }
        for index in defenses.indices {
            switch defenses[index].state {
            case .selected:
                turn.update(defenses[index])
                defenses[index].setStateTo(.cooldown)
            case .cooldown:
                defenses[index].reduceCooldown()
            case .initial, .unselected:
                defenses[index].setStateTo(.initial)
            }
        }
        turns.append(turn)
    }
}

struct Turn {
    private(set) var round: Int
    private(set) var attack: Attack?
    private(set) var defend: (Defend)?
    private(set) var speed: CGFloat = 0

    init(round: Int) {
        self.round = round
        self.attack = nil
        self.defend = nil
        self.speed = 0
    }

    init(round: Int, attacks: [Attack], defenses: [Defend]) {
        self.round = round
        self.attack = attacks.first { $0.state == .selected }
        self.defend = defenses.first { $0.state == .selected }
        updateSpeed()
    }

    mutating func update(_ attack: Attack?) {
        self.attack = attack
        updateSpeed()
    }

    mutating func update(_ defend: Defend?) {
        self.defend = defend
        updateSpeed()
    }

    private mutating func updateSpeed() {
        speed = (attack?.move.speed ?? 0) * (1 + (defend?.move.speedMultiplier ?? 0))
    }
}

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

    func applyDamages() {
        let round = currentPlayer.turns.count + 1
        let currentTurn = Turn(round: round, attacks: currentPlayer.attacks, defenses: currentPlayer.defenses)
        var enemyTurn = Turn(round: round, attacks: enemyPlayer.attacks, defenses: enemyPlayer.defenses)
        //TODO: Remove these auto generated enemy turn
        while enemyTurn.attack == nil {
            let randomAttack = Punch.allCases.randomElement()!
            for (index, attack) in enemyPlayer.attacks.enumerated() {
                if attack.move.id == randomAttack.id {
                    if attack.cooldown <= 0 {
                        LOGD("Randomly generated enemy attack is \(attack)")
                        enemyTurn.update(attack)
                        enemyPlayer.attacks[index].setStateTo(.selected)
                    }
                }
            }
        }
        while enemyTurn.defend == nil {
            let randomDefend = Dash.allCases.randomElement()!
            for (index, defend) in enemyPlayer.defenses.enumerated() {
                if defend.move.id == randomDefend.id {
                    if defend.cooldown <= 0 {
                        LOGD("Randomly generated enemy defend is \(defend)")
                        enemyTurn.update(defend)
                        enemyPlayer.defenses[index].setStateTo(.selected)
                    }
                }
            }
        }
        ///1) Check who is faster to see who goes first
        let isCurrentFirst = currentTurn.speed > enemyTurn.speed
        let firstTurn = isCurrentFirst ? currentTurn : enemyTurn
        let secondTurn = isCurrentFirst ? enemyTurn : currentTurn
        LOGD("First attacker is \(isCurrentFirst ? "Player" : "Enemy")")
        ///2) Apply first turn's damage
        var secondAttackDamageReduction: CGFloat = 0
        if let firstAttack = firstTurn.attack {
            if didLand(attackPosition: firstAttack.move.position, opposingDefense: secondTurn.defend) {
                //Total damage = attackDamage * (damageMultiplier + 1) * (1 - enemyDamageReduction)
                let damage = firstAttack.move.damage * ((firstTurn.defend?.move.damageMultiplier ?? 0) + 1) * (1 - (secondTurn.defend?.move.defenseMultiplier ?? 0))
                enemyPlayer.hp -= isCurrentFirst ? damage : 0
                currentPlayer.hp -= isCurrentFirst ? 0 : damage
                secondAttackDamageReduction = firstAttack.move.damageReduction
                LOGD("First and did \(damage) damage in round \(round)")
            } else {
                LOGD("First and missed their attack in round \(round)")
            }
        } else {
            LOGD("First and did not select an attack in round \(round)")
        }
        ///3) Apply second turn's damage
        if let secondAttack = secondTurn.attack {
            if didLand(attackPosition: secondAttack.move.position, opposingDefense: firstTurn.defend) {
                //Total damage = attackDamage * (damageMultiplier + 1) * (1 - enemyDamageReduction)
                let damage = secondAttack.move.damage * ((secondTurn.defend?.move.damageMultiplier ?? 0) + 1) * (1 - (firstTurn.defend?.move.defenseMultiplier ?? 0) + secondAttackDamageReduction)
                enemyPlayer.hp -= isCurrentFirst ? 0 : damage
                currentPlayer.hp -= isCurrentFirst ? damage : 0
                LOGD("Second and did \(damage) damage in round \(round)")
            } else {
                LOGD("Second and missed their attack in round \(round)")
            }
        } else {
            LOGD("Second and did not select an attack in round \(round)")
        }
        if enemyPlayer.hp <= 0 {
            TODO("Player won")
            enemyPlayer.hp = 0
            isGameOver = true
        } else if currentPlayer.hp <= 0 {
            TODO("Enemy won")
            currentPlayer.hp = 0
            isGameOver = true
        }
    }

    func didLand(attackPosition: AttackPosition, opposingDefense: Defend?) -> Bool {
        guard let opposingDefense else { return true }
        switch opposingDefense.move.position {
        case .forward, .backward:
            return true
        case .left:
            let leftAttacks: [AttackPosition] = [.leftLight, .leftMedium, .leftHard]
            let didLand = leftAttacks.contains(attackPosition)
            LOGD("Did land \(didLand) for \(attackPosition) to \(opposingDefense.move.position)")
            return didLand
        case .right:
            let rightAttacks: [AttackPosition] = [.rightLight, .rightMedium, .rightHard]
            let didLand = rightAttacks.contains(attackPosition)
            LOGD("Did land \(didLand) for \(attackPosition) to \(opposingDefense.move.position)")
            return didLand
        }
    }
}

//MARK: - Private Methods
private extension GameViewModel {
    func startGame() {
        goToNextRound()
    }

    func goToNextRound() {
        currentPlayer.prepareForNextRound()
        enemyPlayer.prepareForNextRound()
        isTimerActive = true
    }
}
