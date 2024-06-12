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
    @Published var path = NavigationPath()
    @Published var animationType: AnimationType = .idle

    let playerType: PlayerType = .user

    //MARK: - Override Methods
    override func onAppear() {
        super.onAppear()
        refreshPlayer()
    }

    //MARK: - Public Methods
    func attackSelected(_ selectedMove: any AttackProtocol) {
        let tempPlayer = player!
        tempPlayer.moves.toggleType(at: selectedMove.position)
        updatePlayer(with: tempPlayer)
    }

    func defenseSelected(_ selectedMove: any MoveProtocol) {

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
    }

    func updatePlayer(with updatedPlayer: FetchedPlayer) {
        guard let currentRoom = RoomManager.getCurrent() else { return }
        currentRoom.updatePlayer(player: player)
        Task {
            try await RoomNetworkManager.updateOwner(updatedPlayer)
        }
        RoomManager.saveCurrent(currentRoom)
        player = updatedPlayer
    }
}
