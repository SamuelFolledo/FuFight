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
        guard let owner = room.owner, let challenger = room.challengers.first else { return }
        do {
            let game = FetchedGame(owner: owner, challenger: challenger, ownerInitiallyHasSpeedBoost: ownerInitiallyHasSpeedBoost)
            try await gamesDb.document(owner.userId).setData(game.asDictionary())
            LOGD("Room owner created a Game document against \(challenger.username). With owner has initial speed boost? \(game.ownerInitiallyHasSpeedBoost)")
        } catch {
            throw error
        }
    }

    static func deleteGame(_ userId: String) async throws {
        do {
            let gameDocument = gamesDb.document(userId)
            try await gameDocument.collection(kPLAYERS).document(kOWNER).delete()
            try await gameDocument.collection(kPLAYERS).document(kCHALLENGER).delete()
            try await gameDocument.delete()
            LOGD("Game document deleted successfully for userId: \(userId)")
        } catch {
            throw error
        }
    }
}

//MARK: - In-Game methods
extension GameNetworkManager {
    static func uploadSelectedMoves(rounds: [Round], isGameOwner: Bool, gameId: String) async throws {
        let documentId = isGameOwner ? kOWNER : kCHALLENGER
        let fetchedRounds = PlayerDocument(rounds: rounds)
        let query = gamesDb.document(gameId).collection(kPLAYERS).document(documentId)
        if rounds.count == 1 {
            try query.setData(from: fetchedRounds)
        } else {
            try await query.updateData(fetchedRounds.asDictionary())
        }
//        LOGD("Game document updated selected moves successfully for userId: \(documentId)")
    }
}
