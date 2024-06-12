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

final class GameNetworkManager {
    private init() {}
}

//MARK: - Game methods
extension GameNetworkManager {
    static func createGame(_ game: FetchedGame) async throws {
        try gamesDb.document(game.player.userId).setData(from: game)
        LOGD("Successfully created a Game document. PlayerHasInitialSpeedBoost: \(game.playerInitiallyHasSpeedBoost)")
    }

    static func deleteGame(_ userId: String) async throws {
        let gameDocument = gamesDb.document(userId)
        try await gameDocument.delete()
        LOGD("Game document deleted successfully for userId: \(userId)")
    }
}

//MARK: - In-Game methods
extension GameNetworkManager {
    static func uploadSelectedMoves(_ player: Player) async throws {
        let selectedMoves = player.rounds.compactMap {
            [
                kATTACKPOSITION: $0.attack?.position.rawValue,
                kDEFENSEPOSITION: $0.defend?.position.rawValue,
            ]
        }
        let selectedMovesDic: [String: Any] = [
            kSELECTEDMOVES: selectedMoves
        ]
        let query = gamesDb.document(player.userId)
        try await query.setData(selectedMovesDic, merge: true)
    }

    ///get enemy's selected moves as dictionary
    static func getEnemySelectedMoves(enemyId: String) async throws -> DocumentSnapshot {
        let query = gamesDb.document(enemyId)
        return try await query.getDocument()
    }
}
