//
//  Room.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/17/24.
//

import FirebaseFirestore

///Represent a single Room in the database. This class represents the public data for an Account
class Room: Identifiable, Equatable, Codable {
    @DocumentID var documentId: String?
    ///Player that owns the room
    var player: FetchedPlayer
    var currentGame: FetchedGame?
    var challengers: [FetchedPlayer] = []
    var status: Status = .online

    ///Returns the currently signed in account's room
    static var current: Room? {
        return RoomManager.getCurrent()
    }

    init(_ account: Account) {
        self.documentId = account.userId
        self.player = FetchedPlayer(account)
    }

    //MARK: - Codable Requirements
    private enum CodingKeys : String, CodingKey {
        case player = "player"
        case currentGame = "currentGame"
        case challengers = "challengers"
        case playerId = "playerId"
        case status = "status"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(player, forKey: .player)
        if !challengers.isEmpty {
            try container.encode(challengers, forKey: .challengers)
        }
        try container.encode(status.rawValue, forKey: .status)
        if let documentId {
            try container.encode(documentId, forKey: .playerId)
        }
        if let currentGame {
            try container.encode(currentGame, forKey: .currentGame)
        }
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.player = try values.decodeIfPresent(FetchedPlayer.self, forKey: .player)!
        let statusId = try values.decodeIfPresent(String.self, forKey: .status)!
        self.status = Status(rawValue: statusId) ?? .online
        self.challengers = try values.decodeIfPresent(Array<FetchedPlayer>.self, forKey: .challengers) ?? []
        self.documentId = try values.decodeIfPresent(String.self, forKey: .playerId)!
        self.currentGame = try values.decodeIfPresent(FetchedGame.self, forKey: .currentGame)
    }
    
    //MARK: Equatable and Identifiable requirements
    static func == (lhs: Room, rhs: Room) -> Bool {
        lhs.documentId! == rhs.documentId!
    }

    //MARK: - Public Methods
    func leaveAsChallenger(userId: String) {
        for (index, challenger) in challengers.enumerated() where challenger.userId == userId {
            challengers.remove(at: index)
        }
    }

    func updatePlayer(player: FetchedPlayer) {
        self.player = player
    }

    func addChallenger(player: FetchedPlayer) {
        challengers.append(player)
    }
}

//MARK: - Custom Room Classes
extension Room {
    ///Status for the room player
    enum Status: String {
        case online
        case offline
        ///searching for enemy
        case searching
        case gaming
        ///during game over flow
        case finishing
    }
}
