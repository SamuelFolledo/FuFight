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

//MARK: - Lobby methods
extension GameNetworkManager {
    ///Fetch an available lobby if there's any available. Return avaialble lobbyIds
    static func findAvailableLobbies(userId: String) async throws -> [String] {
        let nonUserLobbyFilter: Filter = .whereField("player.\(kUSERID)", isNotEqualTo: userId)
        do {
            let availableLobbies = try await lobbiesDb.whereFilter(nonUserLobbyFilter).limit(to: 3).getDocuments()
            let lobbyIds = availableLobbies.documents.compactMap { $0.documentID }
            LOGD("Total lobbies found: \(lobbyIds.count)")
            return lobbyIds
        } catch {
            throw error
        }
    }

    ///For lobby owner to create a new or rejoin an existing lobby
    static func createOrRejoinLobby(lobby: GameLobby) async throws -> GameLobby {
        var updatedLobby = lobby
        do {
            let userId = lobby.player!.userId
            //Check if user already has a lobby created
            let lobbyDocuments = try await lobbiesDb.whereField(kUSERID, isEqualTo: userId).getDocuments()
            if lobbyDocuments.isEmpty {
                let lobbyDocument = lobbiesDb.document(userId)
                try lobbyDocument.setData(from: lobby)
                LOGD("Current lobby created with id: \(lobbyDocument.documentID)")
                updatedLobby.lobbyId = lobbyDocument.documentID
                return updatedLobby
            } else {
                //Rejoin lobby
                let lobbyDocument = lobbyDocuments.documents.first!
                LOGD("Current lobby rejoined at id: \(lobbyDocument.documentID)")
                updatedLobby.lobbyId = lobbyDocument.documentID
                return updatedLobby
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

    ///For enemy joining a lobby as one of the challengers
    static func joinLobby(lobby: GameLobby) async throws {
        do {
            let enemyPlayer = lobby.challengers.first!
            let enemyDic: [String: Any] = [
                kCHALLENGERS: FieldValue.arrayUnion([try enemyPlayer.asDictionary()]),
            ]
            try lobbiesDb.document(lobby.lobbyId!).setData(from: lobby, merge: true)
            LOGD("User joined someone's lobby as enemy with lobby id: \(lobby.lobbyId!)")
        } catch {
            throw error
        }
    }

    ///For enemy to leave a lobby
    static func leaveLobby(_ lobby: GameLobby?) async throws {
        guard let lobby, let lobbyId = lobby.lobbyId else { return }
        do {
            try lobbiesDb.document(lobbyId).setData(from: lobby, merge: true)
            LOGD("User left lobby as enemy with lobby id: \(lobbyId)")
        } catch {
            throw error
        }
    }
}

//MARK: - Game methods
extension GameNetworkManager {
    static func createGameFromLobby(_ lobby: GameLobby?) async throws {
        guard let lobby, let player = lobby.player, let enemyPlayer = lobby.challengers.first else { return }
        do {
            let gameDic: [String: Any] = [
                kUSERPLAYER: try player.asDictionary(),
                kENEMYPLAYER: try enemyPlayer.asDictionary(),
            ]
            try await gamesDb.document(player.userId).setData(gameDic)
            LOGD("Lobby owner \(player.username) created a Game document against \(enemyPlayer.username) lobby id: \(lobby.lobbyId ?? "")")
        } catch {
            throw error
        }
    }

    static func deleteGame(_ userId: String) async throws {
        do {
            try await gamesDb.document(userId).delete()
            LOGD("Lobby creator's game is deleted at: \(userId)")
        } catch {
            throw error
        }
    }
}
