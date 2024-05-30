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
        guard let currentRoom = RoomManager.getCurrent() else { return }
        currentRoom.updatePlayer(player: tempPlayer)
        RoomManager.saveCurrent(currentRoom)
        Task {
            try await RoomNetworkManager.createRoom(currentRoom)
        }
        player = tempPlayer
    }

    func defenseSelected(_ selectedMove: any MoveProtocol) {

    }

    func refreshPlayer() {
        guard let player = RoomManager.getPlayer() else { return }
        self.player = player
    }
}
