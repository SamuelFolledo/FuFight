//
//  RoomManager.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/22/24.
//

import SwiftUI

///Class in charge of Room stored locally
class RoomManager {
    private init() {}
    private static let defaults = UserDefaults.standard

    static func saveCurrent(_ room: Room) {
        Task {
            do {
                try await saveCurrent(room)
            } catch {
                LOGE("ROOM: Failed to save current locally", from: RoomManager.self)
            }
        }
    }

    static func saveCurrent(_ room: Room) async throws {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(room)
            defaults.set(data, forKey: kCURRENTROOM)
        } catch {
            throw error
        }
    }

    static func getCurrent() -> Room? {
        guard let data = defaults.data(forKey: kCURRENTROOM) else { return nil }
        do {
            let room = try JSONDecoder().decode(Room.self, from: data)
            return room
        } catch {
            LOGE("Error decoding current room \(error.localizedDescription)", from: RoomManager.self)
            return nil
        }
    }

    static func getPlayer() -> FetchedPlayer? {
        if let room = Room.current {
            return room.player
        } else if let account = Account.current {
            saveCurrent(Room(account))
            return getPlayer()
        }
        return nil
    }

    static func savePlayer(player: FetchedPlayer) {
        guard let room = Room.current else { return }
        room.player = player
        saveCurrent(room)
    }

    static func deleteCurrent() {
        defaults.removeObject(forKey: kCURRENTROOM)
    }

    static func goOffline() {
        guard let room = Room.current else { return }
        LOGD("Going offline from \(room.status)")
        room.status = .offline
        RoomManager.saveCurrent(room)
        RoomNetworkManager.updateStatus(to: .offline, roomId: room.player.userId)
    }

    static func goOnlineIfNeeded() {
        guard let currentRoom = Room.current else { return }
        switch currentRoom.status {
        case .online:
            break
        case .searching:
            currentRoom.challengers = []
            setCurrentRoomToOnline(currentRoom)
        case .offline:
            offlineToOnlineHandler(currentRoom)
        case .finishing, .gaming:
            currentRoom.currentGame = nil
            setCurrentRoomToOnline(currentRoom)
        }
    }

    private static func offlineToOnlineHandler(_ room: Room) {
        if let game = room.currentGame {
            //TODO: Check if game is created recently, then rejoin instead of deleting the game. In order to do that, we need to create a game and go to a current round from a list of selected moves
            LOGD("Going online has current game vs \(game.enemy.username)")
            room.currentGame = nil
            setCurrentRoomToOnline(room)
            Task {
                do {
                    LOGD("Deleting game vs \(game.enemy.username)")
                    try await GameNetworkManager.deleteGame(game.player.userId)
                }
            }
        } else {
            LOGD("Going online with no current game")
            setCurrentRoomToOnline(room)
        }
    }

    private static func setCurrentRoomToOnline(_ room: Room) {
        RoomNetworkManager.updateStatus(to: .online, roomId: room.player.userId)
        room.status = .online
        saveCurrent(room)
    }
}

//MARK: Purchases extension
extension RoomManager {
    static func isPurchased(_ fighterType: FighterType) -> Bool {
        return Room.current?.unlockedFighterIds.contains(fighterType.id) ?? false
    }
}
