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
    @Published var selectedFighterType: FighterType? = nil
    @Published var animationType: AnimationType = .idle
    @Published var path = NavigationPath()

    var player: FetchedPlayer!
    var fighterScene: SCNScene?

    let playerType: PlayerType = .user

    //MARK: - Override Methods
    override func onAppear() {
        super.onAppear()
        setupSelectedPlayer()
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

    func switchFighterTo(_ nextFighterType: FighterType) {
        let updatedPlayer = player!
        updatedPlayer.fighterType = nextFighterType
        updatePlayer(with: updatedPlayer)
    }

    func setupSelectedPlayer() {
        guard let player = RoomManager.getPlayer() else { return }
        LOG("ROOM SETTINGUP \(player.fighterType) vs \(selectedFighterType?.rawValue ?? "none")")
        self.player = player
        if let index = allFighters.compactMap({ $0.fighterType }).firstIndex(of: player.fighterType) {
            fighterScene = createFighterScene(fighterType: player.fighterType, animation: animationType)
            selectedFighterType = player.fighterType
        }
    }
}

private extension RoomViewModel {
    func refreshPlayer() {
        guard let player = RoomManager.getPlayer() else { return }
        self.player = player
        guard let selectedFighterType else { return }
        DispatchQueue.main.async {
            self.fighterScene = createFighterScene(fighterType: selectedFighterType, animation: self.animationType)
        }
    }

    func updatePlayer(with updatedPlayer: FetchedPlayer) {
        guard let currentRoom = Room.current else { return }
        currentRoom.updatePlayer(player: updatedPlayer)
        updateLoadingMessage(to: "")
        Task {
            do {
                try await RoomManager.saveCurrent(currentRoom)
                try await RoomNetworkManager.updateOwner(updatedPlayer)
                refreshPlayer()
                updateLoadingMessage(to: nil)
            } catch {
                updateLoadingMessage(to: nil)
            }
        }
    }

    func updateMove(_ position: AttackPosition) {
        let tempPlayer = player!
        tempPlayer.moves.toggleType(at: position)
        updatePlayer(with: tempPlayer)
    }

    func updateAnimation(_ animation: AnimationType) {
        //Play animation
        guard let selectedFighterType else { return }
        animationType = animation
        fighterScene = createFighterScene(fighterType: selectedFighterType, animation: animationType)
        //Go back to default animation after showing the animation
        runAfterDelay(delay: animation.animationDuration(for: selectedFighterType) - 0.2) { [weak self] in
            guard let self else { return }
            animationType = .idle
            fighterScene = createFighterScene(fighterType: selectedFighterType, animation: animationType)
        }
    }
}
