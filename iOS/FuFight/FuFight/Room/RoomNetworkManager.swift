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
        let userId = room.player.userId
        let roomDocument = roomsDb.document(userId)
        try roomDocument.setData(from: room)
        LOGD("Room created for roomId: \(room.player.username)")
    }

    ///Fetches current room for the authenticated account
    static func fetchRoom(_ account: Account) async throws -> Room {
        let room = try await roomsDb.document(account.userId).getDocument(as: Room.self)
        LOGD("Room fetched for: \(account.displayName)")
        return room
    }

    ///Fetch an available room if there's any available. Return avaialble roomIds
    static func fetchAvailableRooms(userId: String) async throws -> [Room] {
        let searchingRooms = try await getRoomsWithStatus(.searching)
        let availableRooms = searchingRooms.filter { $0.documentId != userId }
        LOGD("Fetched searching and non-user rooms found: \(availableRooms.count)")
        return availableRooms
    }

    ///Fetches all Rooms with the status. Note this can return the user's Room
    static func getRoomsWithStatus(_ status: Room.Status) async throws -> [Room] {
        let isRoomSearchingFilter: Filter = .whereField(kSTATUS, isEqualTo: status.rawValue)
        let availableRooms = try await roomsDb
            .whereFilter(Filter.andFilter([
                isRoomSearchingFilter,
            ]))
            .limit(to: 3)
            .getDocuments()
//            .order(by: "dateAdded", descending: true)
        var rooms = [Room]()
        for document in availableRooms.documents {
            let room = try document.data(as: Room.self)
            room.documentId = document.documentID
            rooms.append(room)
        }
        LOGD("Total rooms found with status: \(status.rawValue) is : \(rooms.count)")
        return rooms
    }

    static func updateRoom(_ room: Room) async throws {
        let roomDocument = roomsDb.document(room.player.userId)
        try await roomDocument.setData(room.asDictionary(), merge: true)
        LOGD("Room is updated successfully: \(room.player.username)")
    }

    static func updateStatus(to status: Room.Status, roomId: String) {
        var roomDic: [String: Any] = [kSTATUS: status.rawValue]
        switch status {
        case .finishing, .searching:
            break
        case .online, .offline, .gaming:
            roomDic[kCHALLENGERS] = FieldValue.delete()
        }
        roomsDb.document(roomId).updateData(roomDic)
        LOGD("Player's room status is updated to: \(status.rawValue)")
    }

    ///For room player to delete room
    static func deleteCurrentRoom(roomId: String) async throws {
        try await roomsDb.document(roomId).delete()
        LOGD("Player's room is successfully deleted with room id: \(roomId)")
    }

    ///For current player to join a room as one of the challengers
    static func joinRoom(_ player: FetchedPlayer, roomId: String) async throws {
        let enemyDic: [String: Any] = [
            kCHALLENGERS: FieldValue.arrayUnion([try player.asDictionary()]),
        ]
        try await roomsDb.document(roomId).updateData(enemyDic)
        LOGD("User joined someone's room as enemy with room id: \(roomId)")
    }

    ///Updates room's player in the database
    static func updateOwner(_ player: FetchedPlayer) async throws {
        let roomDocument = roomsDb.document(player.userId)
        try await roomDocument.updateData([kPLAYER: player.asDictionary()])
        LOGD("Room's owner is updated successfully: \(player.username)")
    }
}
