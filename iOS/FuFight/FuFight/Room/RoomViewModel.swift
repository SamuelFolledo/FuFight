//
//  RoomViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/25/24.
//

import Combine
import SwiftUI

final class RoomViewModel: BaseAccountViewModel {
    @Published var player: FetchedPlayer!
    @Published var fighter: Fighter!
    @Published var path = NavigationPath()
    @Published var animationType: AnimationType = .idle

    let playerType: PlayerType = .user

    //MARK: - Override Methods
    override func onAppear() {
        super.onAppear()
        refreshPlayer()
    }

    //MARK: - Public Methods
    func attackSelected(_ position: AttackPosition) {
        updateMove(position)
        let animation = player.moves.attacks.getAnimation(at: position)
        fighter.playAnimation(animation)
    }

    func defenseSelected(_ position: DefensePosition) {
        let animation = player.moves.defenses.getAnimation(at: position)
        fighter.playAnimation(animation)
    }

    func switchButtonSelected() {
        let updatedPlayer = player!
        let nextFighterType: FighterType = updatedPlayer.fighterType == .clara ? .samuel : .clara
        updatedPlayer.fighterType = nextFighterType
        updatePlayer(with: updatedPlayer)
    }
}

private extension RoomViewModel {
    func refreshPlayer() {
        guard let player = RoomManager.getPlayer() else { return }
        self.player = player
        self.fighter = Fighter(type: player.fighterType, isEnemy: false)
    }

    func updatePlayer(with updatedPlayer: FetchedPlayer) {
        guard let currentRoom = Room.current else { return }
        currentRoom.updatePlayer(player: player)
        Task {
            try await RoomNetworkManager.updateOwner(updatedPlayer)
        }
        RoomManager.saveCurrent(currentRoom)
        player = updatedPlayer
    }

    func updateMove(_ position: AttackPosition) {
        let tempPlayer = player!
        tempPlayer.moves.toggleType(at: position)
        updatePlayer(with: tempPlayer)
    }
}
