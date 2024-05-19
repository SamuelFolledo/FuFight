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
    ///Fetch an available lobby if there's any available. Return avaialble lobbyIds
    static func findAvailableLobbies(userId: String) async throws -> [String] {
        let nonUserLobbyFilter: Filter = .whereField(kUSERID, isNotEqualTo: userId)
        do {
            let availableLobbies = try await lobbiesDb.whereFilter(nonUserLobbyFilter).getDocuments()
            let lobbyIds = availableLobbies.documents.compactMap { $0.documentID }
            LOGD("Total lobbies found: \(lobbyIds.count)")
            return lobbyIds
        } catch {
            throw error
        }
    }

    ///For lobby owner to create a new or rejoin an existing lobby
    static func createLobby(for account: Account, fighterType: FighterType) async throws -> String {
        do {
            //Check if user already has a lobby created
            let lobbyDocuments = try await lobbiesDb.whereField(kUSERID, isEqualTo: account.userId).getDocuments()
            if lobbyDocuments.isEmpty {
                let lobbyDocument = lobbiesDb.document()
                let dic: [String: Any] = [
                    kUSERID: account.userId,
                    kUSERNAME: account.username!,
                    kPHOTOURL: account.photoUrl!.absoluteString,
                    kUSERFIGHTERTYPE: fighterType.rawValue,
                ]
                try await lobbyDocument.setData(dic)
                LOGD("Current lobby created with id: \(lobbyDocument.documentID)")
                return lobbyDocument.documentID
            } else {
                //Rejoin lobby
                let lobbyDocument = lobbyDocuments.documents.first!
                LOGD("Current lobby rejoined at id: \(lobbyDocument.documentID)")
                return lobbyDocument.documentID
            }
        } catch {
            throw error
        }
    }

    ///For lobby owner to delete lobby
    static func deleteCurrentLobby(lobbyId: String) async throws {
        do {
            try await lobbiesDb.document(lobbyId).delete()
            LOGD("Player's lobby is successfully deleted with lobby id: \(lobbyId)")
        } catch {
            throw error
        }
    }

    ///For enemy joining a lobby
    static func joinLobby(lobbyId: String, account: Account, fighterType: FighterType) async throws {
        do {
            let enemyDic: [String: Any] = [
                kENEMYID: account.userId,
                kENEMYUSERNAME: account.username!,
                kENEMYPHOTOURL: account.photoUrl!.absoluteString,
                kENEMYFIGHTERTYPE: fighterType.rawValue,
            ]
            try await lobbiesDb.document(lobbyId).setData(enemyDic, merge: true)
            LOGD("User joined someone's lobby as enemy with lobby id: \(lobbyId)")
        } catch {
            throw error
        }
    }

    ///For enemy to leave a lobby
    static func leaveLobby(lobbyId: String) async throws {
        do {
            let enemyDic: [String: Any] = [
                kENEMYID: FieldValue.delete(),
                kENEMYUSERNAME: FieldValue.delete(),
                kENEMYPHOTOURL: FieldValue.delete(),
                kENEMYFIGHTERTYPE: FieldValue.delete(),
            ]
            try await lobbiesDb.document(lobbyId).setData(enemyDic, merge: true)
            LOGD("User left lobby as enemy with lobby id: \(lobbyId)")
        } catch {
            throw error
        }
    }
}
