//
//  RoomNetworkManager.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/22/24.
//

import FirebaseFirestore
import SwiftUI

class RoomNetworkManager {
    private init() {}
}

//MARK: - Extension
extension RoomNetworkManager {
    static func createRoom(_ room: Room) async throws {
        do {
            let userId = room.player!.userId
            let roomDocument = roomsDb.document(userId)
            try roomDocument.setData(from: room)
            LOGD("Room created for roomId: \(room.player!.username)")
        } catch {
            throw error
        }
    }

    ///Fetches current room for the authenticated account
    static func fetchRoom(_ account: Account) async throws -> Room {
        do {
            let room = try await roomsDb.document(account.userId).getDocument(as: Room.self)
            LOGD("Room fetched for: \(account.displayName)")
            return room
        } catch {
            throw error
        }
    }

//    static func updateRoom(_ room: Room) async throws {
//        do {
//            let userId = room.player!.userId
//            let roomDocument = roomsDb.document(userId)
//            try await roomDocument.updateData(roomDocument.asDictionary())
//            LOGD("Room updated for roomId: \(userId)")
//        } catch {
//            throw error
//        }
//    }

    ///Fetch an available room if there's any available. Return avaialble roomIds
    static func findAvailableRooms(userId: String) async throws -> [String] {
        let nonUserRoomFilter: Filter = .whereField("player.\(kUSERID)", isNotEqualTo: userId)
        do {
            let availableRooms = try await roomsDb.whereFilter(nonUserRoomFilter).limit(to: 3).getDocuments()
            let roomIds = availableRooms.documents.compactMap { $0.documentID }
            LOGD("Total rooms found: \(roomIds.count)")
            return roomIds
        } catch {
            throw error
        }
    }

    ///For room owner to create a new or rejoin an existing room
    static func createOrRejoinRoom(room: Room) async throws {
        do {
            let ownerId = room.ownerId
            let roomDocuments = try await roomsDb.whereField(kOWNERID, isEqualTo: ownerId).getDocuments()
            if roomDocuments.isEmpty {
                //Check if user already has a room created
                let roomDocument = roomsDb.document(ownerId)
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
            try await roomsDb.document(roomId).delete()
            LOGD("Player's room is successfully deleted with room id: \(roomId)")
        } catch {
            throw error
        }
    }

    ///For enemy joining a room as one of the challengers
    static func joinRoom(room: Room) async throws {
        do {
            let enemyPlayer = room.challengers.first!
            let enemyDic: [String: Any] = [
                kCHALLENGERS: FieldValue.arrayUnion([try enemyPlayer.asDictionary()]),
            ]
            try roomsDb.document(room.ownerId).setData(from: room, merge: true)
            LOGD("User joined someone's room as enemy with room id: \(room.ownerId)")
        } catch {
            throw error
        }
    }

    ///For enemy to leave a room
    static func leaveRoom(_ room: Room?) async throws {
        guard let room else { return }
        do {
            try roomsDb.document(room.ownerId).setData(from: room, merge: true)
            LOGD("User left room as enemy with room id: \(room.ownerId)")
        } catch {
            throw error
        }
    }
}
