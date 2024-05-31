//
//  Room.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/17/24.
//

import FirebaseFirestore

///Represent a single Room in the database. This class represents the public data for an Account
class Room: Codable {
    @DocumentID private var documentId: String?
    var ownerId: String { documentId! }
    ///Player that owns the room
    private(set) var player: FetchedPlayer?
    private(set) var challengers: [FetchedPlayer] = []
    private(set) var status: Status = .online

    var isValid: Bool {
        player != nil && challengers.first != nil
    }

    ///Returns the currently signed in account's room
    static var current: Room? {
        return RoomManager.getCurrent()
    }

    ///Room owner initializer
    init(ownerPlayer: FetchedPlayer) {
        self.documentId = ownerPlayer.userId
        self.player = ownerPlayer
    }

    init(_ account: Account) {
        self.documentId = account.userId
        self.player = FetchedPlayer(account)
    }

    //MARK: - Codable Requirements
    private enum CodingKeys : String, CodingKey {
        case player = "player"
        case challengers = "challengers"
        case ownerId = "ownerId"
        case status = "status"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        //This if let prevents writes to the database where the value is null
        if let player {
            try container.encode(player, forKey: .player)
        }
        if !challengers.isEmpty {
            try container.encode(challengers, forKey: .challengers)
        }
        try container.encode(status.rawValue, forKey: .status)
        try container.encode(ownerId, forKey: .ownerId)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.player = try values.decodeIfPresent(FetchedPlayer.self, forKey: .player)
        let statusId = try values.decodeIfPresent(String.self, forKey: .status)!
        self.status = Status(rawValue: statusId) ?? .online
        self.challengers = try values.decodeIfPresent(Array<FetchedPlayer>.self, forKey: .challengers) ?? []
        self.documentId = try values.decodeIfPresent(String.self, forKey: .ownerId)!
    }

    //MARK: - Public Methods
    func leaveAsChallenger(userId: String) {
        for (index, challenger) in challengers.enumerated() where challenger.userId == userId {
            challengers.remove(at: index)
        }
    }

    func updatePlayer(player: FetchedPlayer?) {
        self.player = player
    }
}

//MARK: - Private extension
private extension Room  {

}

//MARK: - Custom Room Classes
extension Room {
    ///Status for the room owner
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
