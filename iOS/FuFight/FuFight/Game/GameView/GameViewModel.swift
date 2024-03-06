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
}

@Observable
class GameViewModel: BaseViewModel {

    var accountPlayer: Player
    var enemyPlayer: Player
    var isGameOver: Bool = false
    var timeRemaining = defaultMaxTime {
        didSet { handleTimeChanges() }
    }
    var isTimerActive: Bool = false
    var round: Int = 1
    var isBackgroundLeadingPadding = Bool.random()
    //TODO: Check the actual maximum padding I can have
    var backgroundPadding = Double.random(in: 0...1000)

    ///Initializer for testing purposes
    override init() {
        let photoUrl = Account.current?.photoUrl ?? URL(string: "https://firebasestorage.googleapis.com:443/v0/b/fufight-51d75.appspot.com/o/Accounts%2FPhotos%2FS4L442FyMoNRfJEV05aFCHFMC7R2.jpg?alt=media&token=0f185bff-4d16-450d-84c6-5d7645a97fb9")!
        self.accountPlayer = Player(photoUrl: photoUrl, username: "Samuel", hp: 100, maxHp: 100)
        self.enemyPlayer = Player(photoUrl: photoUrl, username: "Brandon", hp: 20, maxHp: 100)
        super.init()
    }

    init(enemyPlayer: Player) {
        self.accountPlayer = Player(photoUrl: Account.current!.photoUrl!, username: Account.current!.displayName, hp: 100, maxHp: 100)
        //TODO: Show enemy
        self.enemyPlayer = enemyPlayer
        super.init()
    }

    override func onAppear() {
        super.onAppear()
        startGame()
    }

    //MARK: - Public Methods
    func attack(damage: CGFloat, toEnemy: Bool) {
        if toEnemy {
            enemyPlayer.hp -= damage
        } else {
            accountPlayer.hp -= damage
        }
        if enemyPlayer.hp <= 0 {
            TODO("Player won")
            isGameOver = true
        } else if accountPlayer.hp <= 0 {
            TODO("Enemy won")
            isGameOver = true
        } else {
            TODO("Go to next round")
        }
    }
}

//MARK: - Private Methods
private extension GameViewModel {
    func startGame() {
        isTimerActive = true
    }

    func handleTimeChanges() {
        if timeRemaining == 0 {
            round += 1
        }
    }
}
