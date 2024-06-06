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
            try await gameDocument.collection(kSELECTEDMOVES).document(kOWNER).delete()
            try await gameDocument.collection(kSELECTEDMOVES).document(kCHALLENGER).delete()
            try await gameDocument.delete()
            LOGD("Room owner's game is deleted at: \(userId)")
        } catch {
            throw error
        }
    }
}

//MARK: - In-Game methods
extension GameNetworkManager {
    static func uploadSelectedMoves(moves: Moves, round: Int, isGameOwner: Bool, gameId: String) async throws {
        let documentId = isGameOwner ? kOWNER : kCHALLENGER
        let selectedMovesDic: [String: Any] = [
            kSELECTEDATTACKPOSITION: moves.selectedAttack?.position.rawValue as Any,
            kSELECTEDDEFENSEPOSITION: moves.selectedDefense?.position.rawValue as Any,
        ]
        let movesDic: [String: Any] = [kROUNDS: FieldValue.arrayUnion([selectedMovesDic])]
        let query = gamesDb.document(gameId).collection(kSELECTEDMOVES).document(documentId)
        try await query.setData(movesDic, merge: true)
    }

    static func fetchSelectedMoves(round: Int, isGameOwner: Bool, gameId: String) async throws -> (attackPosition: AttackPosition, defensePosition: DefensePosition)? {
        return nil
    }
}
