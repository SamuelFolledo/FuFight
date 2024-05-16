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

//MARK: - Lobby Extension
extension GameNetworkManager { 
    ///Fetch an available lobby if there's any available. Returns an avaialble lobbyId
    static func findAvailableLobbies(userId: String) async throws -> [String] {
        let nonUserLobbyFilter: Filter = .whereField(kPLAYERID, isNotEqualTo: userId)
        do {
            let availableLobbies = try await lobbiesDb.whereFilter(nonUserLobbyFilter).getDocuments()
            let lobbyIds = availableLobbies.documents.compactMap { $0.documentID }
            LOGD("Lobbies found: \(lobbyIds.count)")
            return lobbyIds
        } catch {
            throw error
        }
    }

    static func createLobby(for account: Account) async throws -> String? {
        do {
            let lobbyDocument = lobbiesDb.document()
            let dic: [String: Any] = [kPLAYERID: account.userId, kUSERNAME: account.username!]
            try await lobbyDocument.setData(dic)
            LOGD("Current lobby created with id: \(lobbyDocument.documentID)")
            return lobbyDocument.documentID
        } catch {
            throw error
        }
    }

    static func deleteCurrentLobby(lobbyId: String) async throws {
        do {
            try await lobbiesDb.document(lobbyId).delete()
            LOGD("Current lobby deleted with id: \(lobbyId)")
        } catch {
            throw error
        }
    }
}
