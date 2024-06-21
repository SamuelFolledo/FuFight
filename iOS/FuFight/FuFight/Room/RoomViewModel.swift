//
//  RoomViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/25/24.
//

import Combine
import SwiftUI
import SceneKit

final class RoomViewModel: BaseAccountViewModel {
    var player: FetchedPlayer!
    var fighter: Fighter!
    var animationType: AnimationType = .idle
    @Published var path = NavigationPath()
    @Published var fighterScene: SCNScene!
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
        updateAnimation(animation)
    }

    func defenseSelected(_ position: DefensePosition) {
        let animation = player.moves.defenses.getAnimation(at: position)
        updateAnimation(animation)
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
        if let fighter = fighter {
            if player.fighterType != fighter.fighterType {
                fighter.switchFighter()
                fighterScene = createFighterScene(fighterType: fighter.fighterType, animation: animationType)
            }
        } else {
            self.fighter = Fighter(type: player.fighterType, isEnemy: false)
            fighterScene = createFighterScene(fighterType: player.fighterType, animation: animationType)
        }
    }

    func updatePlayer(with updatedPlayer: FetchedPlayer) {
        guard let currentRoom = Room.current else { return }
        currentRoom.updatePlayer(player: updatedPlayer)
        updateLoadingMessage(to: "")
        Task {
            try await RoomManager.saveCurrent(currentRoom)
            refreshPlayer()
            try await RoomNetworkManager.updateOwner(updatedPlayer)
            updateLoadingMessage(to: nil)
        }
    }

    func updateMove(_ position: AttackPosition) {
        let tempPlayer = player!
        tempPlayer.moves.toggleType(at: position)
        updatePlayer(with: tempPlayer)
    }

    func updateAnimation(_ animation: AnimationType) {
        //Play animation
        animationType = animation
        fighterScene = createFighterScene(fighterType: fighter.fighterType, animation: animationType)
        //Go back to default animation after showing the animation
        runAfterDelay(delay: animation.animationDuration(for: fighter.fighterType) - 0.2) { [weak self] in
            guard let self else { return }
            animationType = fighter.defaultAnimation
            fighterScene = createFighterScene(fighterType: fighter.fighterType, animation: animationType)
        }
    }
}
