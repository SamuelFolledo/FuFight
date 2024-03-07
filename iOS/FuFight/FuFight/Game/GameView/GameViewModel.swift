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
                attacks[index].state = .initial
            case .cooldown:
                TODO("Reduce cooldown")
            case .initial, .unselected, .bigFire, .smallFire:
                attacks[index].state = .initial
            }
        }
        for index in defenses.indices {
            switch defenses[index].state {
            case .selected:
                turn.defend = defenses[index]
                defenses[index].state = .initial
            case .cooldown:
                TODO("Reduce cooldown")
            case .initial, .unselected:
                defenses[index].state = .initial
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
        self.enemyPlayer = Player(photoUrl: photoUrl, username: "Brandon", hp: 20, maxHp: 100, attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses)
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

    func selectMove(_ selectedMove: any MoveProtocol) {
        if selectedMove.moveType == .attack {
            for (index, attack) in currentPlayer.attacks.enumerated() {
                if attack.id == selectedMove.id {
                    currentPlayer.attacks[index].state = .selected
                } else {
                    currentPlayer.attacks[index].state = .unselected
                }
            }
        } else if selectedMove.moveType == .defend {
            for (index, defense) in currentPlayer.defenses.enumerated() {
                if defense.id == selectedMove.id {
                    currentPlayer.defenses[index].state = .selected
                } else {
                    currentPlayer.defenses[index].state = .unselected
                }
            }
        }
    }

    func attack(_ attack: Attack, toEnemy: Bool) {
        if toEnemy {
            enemyPlayer.hp -= attack.damage
        } else {
            currentPlayer.hp -= attack.damage
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
        isTimerActive = true
    }

    func goToNextRound() {
        currentPlayer.prepareForNextRound()
        enemyPlayer.prepareForNextRound()
        isTimerActive = true
    }
}
