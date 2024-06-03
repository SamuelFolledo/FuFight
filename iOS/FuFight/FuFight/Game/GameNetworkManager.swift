//
//  GameNetworkManager.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/16/24.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

class GameNetworkManager {
    private init() {}
}

//MARK: - Game methods
extension GameNetworkManager {
    static func createGameFromRoom(_ room: Room, ownerInitiallyHasSpeedBoost: Bool) async throws {
        guard let player = room.player, let enemyPlayer = room.challengers.first else { return }
        do {
            let game = FetchedGame(player: player, enemyPlayer: enemyPlayer, ownerInitiallyHasSpeedBoost: ownerInitiallyHasSpeedBoost)
            try await gamesDb.document(player.userId).setData(game.asDictionary())
            LOGD("Room owner created a Game document against \(enemyPlayer.username). With owner has initial speed boost? \(game.ownerInitiallyHasSpeedBoost)")
        } catch {
            throw error
        }
    }

    static func deleteGame(_ userId: String) async throws {
        do {
            try await gamesDb.document(userId).delete()
            LOGD("Room owner's game is deleted at: \(userId)")
        } catch {
            throw error
        }
    }
}
