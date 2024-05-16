//
//  GameLoadingViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/16/24.
//

import SwiftUI
import FirebaseAuth

@Observable
class GameLoadingViewModel: BaseViewModel {
    var player: Player
    var enemyPlayer: Player?

    init(player: Player, enemyPlayer: Player? = nil) {
        self.player = player
        self.enemyPlayer = enemyPlayer
    }

    //MARK: - ViewModel Overrides

    override func onAppear() {
        super.onAppear()
        updateLoadingMessage(to: "Finding Opponent")
    }

    //MARK: - Public Methods
}

//MARK: - Private Methods
private extension GameLoadingViewModel {

}
