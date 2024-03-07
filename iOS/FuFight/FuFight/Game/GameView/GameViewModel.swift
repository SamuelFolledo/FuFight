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
                turn.attack = attacks[index]
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
                turn.defend = defenses[index]
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
    var round: Int
    var attack: Attack?
    var defend: (Defend)?
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
            for selectedAttack in currentPlayer.attacks where selectedAttack.state == .selected {
                attack(selectedAttack, toEnemy: true)
            }
            if !isGameOver {
                goToNextRound()
            }
        }
    }

    func selectAttack(_ selectedMove: Attack) {
        guard selectedMove.state != .cooldown else { return }
        for (index, attack) in currentPlayer.attacks.enumerated() {
            if attack.move.id == selectedMove.move.id {
                currentPlayer.attacks[index].setStateTo(.selected)
            } else {
                guard currentPlayer.attacks[index].state != .cooldown else { continue }
                currentPlayer.attacks[index].setStateTo(.unselected)
            }
        }
    }

    func selectDefense(_ selectedMove: Defend) {
        guard selectedMove.state != .cooldown else { return }
        for (index, defense) in currentPlayer.defenses.enumerated() {
            if defense.move.id == selectedMove.move.id {
                currentPlayer.defenses[index].setStateTo(.selected)
            } else {
                guard currentPlayer.defenses[index].state != .cooldown else { continue }
                currentPlayer.defenses[index].setStateTo(.unselected)
            }
        }
    }

    func attack(_ attack: Attack, toEnemy: Bool) {
        if toEnemy {
            enemyPlayer.hp -= attack.move.damage
        } else {
            currentPlayer.hp -= attack.move.damage
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
