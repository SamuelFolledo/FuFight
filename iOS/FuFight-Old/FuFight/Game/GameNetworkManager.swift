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

//MARK: - Room methods
extension GameNetworkManager {
    ///Fetch an available room if there's any available. Return avaialble roomIds
    static func findAvailableLobbies(userId: String) async throws -> [String] {
        let nonUserRoomFilter: Filter = .whereField("player.\(kUSERID)", isNotEqualTo: userId)
        do {
            let availableLobbies = try await lobbiesDb.whereFilter(nonUserRoomFilter).limit(to: 3).getDocuments()
            let roomIds = availableLobbies.documents.compactMap { $0.documentID }
            LOGD("Total lobbies found: \(roomIds.count)")
            return roomIds
        } catch {
            throw error
        }
    }

    ///For room owner to create a new or rejoin an existing room
    static func createOrRejoinRoom(room: GameRoom) async throws {
        do {
            let userId = room.player!.userId
            let roomDocuments = try await lobbiesDb.whereField(kUSERID, isEqualTo: userId).getDocuments()
            if roomDocuments.isEmpty {
                //Check if user already has a room created
                let roomDocument = lobbiesDb.document(userId)
                try roomDocument.setData(from: room)
                LOGD("Current room created with id: \(roomDocument.documentID)")
            } else {
                //Rejoin room
                let roomDocument = roomDocuments.documents.first!
                LOGD("Current room rejoined at id: \(roomDocument.documentID)")
            }
        } catch {
            throw error
        }
    }

    ///For room owner to delete room
    static func deleteCurrentRoom(roomId: String) async throws {
        do {
            try await lobbiesDb.document(roomId).delete()
            LOGD("Player's room is successfully deleted with room id: \(roomId)")
        } catch {
            throw error
        }
    }

    ///For enemy joining a room as one of the challengers
    static func joinRoom(room: GameRoom) async throws {
        do {
            let enemyPlayer = room.challengers.first!
            let enemyDic: [String: Any] = [
                kCHALLENGERS: FieldValue.arrayUnion([try enemyPlayer.asDictionary()]),
            ]
            try lobbiesDb.document(room.ownerId).setData(from: room, merge: true)
            LOGD("User joined someone's room as enemy with room id: \(room.ownerId)")
        } catch {
            throw error
        }
    }

    ///For enemy to leave a room
    static func leaveRoom(_ room: GameRoom?) async throws {
        guard let room else { return }
        do {
            try lobbiesDb.document(room.ownerId).setData(from: room, merge: true)
            LOGD("User left room as enemy with room id: \(room.ownerId)")
        } catch {
            throw error
        }
    }
}

//MARK: - Game methods
extension GameNetworkManager {
    static func createGameFromRoom(_ room: GameRoom?) async throws {
        guard let room, let player = room.player, let enemyPlayer = room.challengers.first else { return }
        do {
            let gameDic: [String: Any] = [
                kOWNERID: room.ownerId,
                kUSERPLAYER: try player.asDictionary(),
                kENEMYPLAYER: try enemyPlayer.asDictionary(),
            ]
            try await gamesDb.document(player.userId).setData(gameDic)
            LOGD("Room owner \(player.username) created a Game document against \(enemyPlayer.username) room id: \(room.ownerId)")
        } catch {
            throw error
        }
    }

    static func deleteGame(_ userId: String) async throws {
        do {
            try await gamesDb.document(userId).delete()
            LOGD("Room creator's game is deleted at: \(userId)")
        } catch {
            throw error
        }
    }
}
