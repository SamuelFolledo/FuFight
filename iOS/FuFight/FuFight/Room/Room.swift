//
//  Room.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/17/24.
//

import FirebaseFirestore

///Represent a single Room in the database. This class represents the public data for an Account
class Room: Identifiable, Equatable, Codable {
    @DocumentID private var documentId: String?
    var ownerId: String { documentId! }
    ///Player that owns the room
    private(set) var owner: FetchedPlayer?
    private(set) var challengers: [FetchedPlayer] = []
    private(set) var status: Status = .online

    var isValid: Bool {
        owner != nil && challengers.first != nil
    }

    ///Returns the currently signed in account's room
    static var current: Room? {
        return RoomManager.getCurrent()
    }

    ///Room owner initializer
    init(ownerPlayer: FetchedPlayer) {
        self.documentId = ownerPlayer.userId
        self.owner = ownerPlayer
    }

    init(_ account: Account) {
        self.documentId = account.userId
        self.owner = FetchedPlayer(account)
    }

    //MARK: - Codable Requirements
    private enum CodingKeys : String, CodingKey {
        case owner = "owner"
        case challengers = "challengers"
        case ownerId = "ownerId"
        case status = "status"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        //This if let prevents writes to the database where the value is null
        if let owner {
            try container.encode(owner, forKey: .owner)
        }
        if !challengers.isEmpty {
            try container.encode(challengers, forKey: .challengers)
        }
        try container.encode(status.rawValue, forKey: .status)
        try container.encode(ownerId, forKey: .ownerId)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.owner = try values.decodeIfPresent(FetchedPlayer.self, forKey: .owner)
        let statusId = try values.decodeIfPresent(String.self, forKey: .status)!
        self.status = Status(rawValue: statusId) ?? .online
        self.challengers = try values.decodeIfPresent(Array<FetchedPlayer>.self, forKey: .challengers) ?? []
        self.documentId = try values.decodeIfPresent(String.self, forKey: .ownerId)!
    }
    
    //MARK: Equatable and Identifiable requirements
    static func == (lhs: Room, rhs: Room) -> Bool {
        lhs.ownerId == rhs.ownerId
    }

    //MARK: - Public Methods
    func leaveAsChallenger(userId: String) {
        for (index, challenger) in challengers.enumerated() where challenger.userId == userId {
            challengers.remove(at: index)
        }
    }

    func updateOwner(owner: FetchedPlayer?) {
        self.owner = owner
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
