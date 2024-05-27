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
    static func createGameFromRoom(_ room: Room?) async throws {
        guard let room, let player = room.player, let enemyPlayer = room.challengers.first else { return }
        do {
            let gameDic: [String: Any] = [
                kOWNERID: room.ownerId,
                kUSERPLAYER: try player.asDictionary(),
                kENEMYPLAYER: try enemyPlayer.asDictionary(),
            ]
            try await gamesDb.document(player.userId).setData(gameDic)
            LOGD("Room owner \(player.username) created a Game document against \(enemyPlayer.username)")
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
