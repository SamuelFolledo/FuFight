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

    static func deleteCurrent() {
        defaults.removeObject(forKey: kCURRENTROOM)
    }
}
