//
//  FetchedPlayer.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/20/24.
//

import FirebaseFirestore

@Observable
class FetchedPlayer: PlayerProtocol {
    private(set) var userId: String
    private(set) var username: String
    private(set) var photoUrl: URL
    var fighterType: FighterType
    var moves: Moves

    init(_ player: Player) {
        self.userId = player.userId
        self.username = player.username
        self.photoUrl = player.photoUrl
        self.moves = player.moves
        self.fighterType = player.fighter.fighterType
    }

    ///Creates an enemy player from the room
    init?(room: Room?, isRoomOwner: Bool) {
        guard let room,
              let enemyPlayer = room.challengers.first
        else { return nil }
        let player = room.player
        self.photoUrl = !isRoomOwner ? player.photoUrl : enemyPlayer.photoUrl
        self.username = !isRoomOwner ? player.username : enemyPlayer.username
        self.userId = !isRoomOwner ? player.userId : enemyPlayer.userId
        self.moves = !isRoomOwner ? player.moves : enemyPlayer.moves
        self.fighterType = !isRoomOwner ? player.fighterType : enemyPlayer.fighterType
    }

    ///Default value/initializer for FetchedPlayer from current logged in account
    init(_ account: Account) {
        self.userId = account.userId
        self.username = account.username!
        self.photoUrl = account.photoUrl!
        let room = Room.current
        self.fighterType = room?.player.fighterType ?? .samuel
        let attacks = room?.player.moves.attacks ?? defaultAllPunchAttacks
        let defenses = room?.player.moves.defenses ?? defaultAllDashDefenses
        self.moves = Moves(attacks: attacks, defenses: defenses)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let userId = try values.decodeIfPresent(String.self, forKey: .userId)!
        self.userId = userId
        self.username = try values.decodeIfPresent(String.self, forKey: .username)!
        self.photoUrl = try values.decodeIfPresent(URL.self, forKey: .photoUrl)!
        self.moves = try values.decodeIfPresent(Moves.self, forKey: .moves)!
        let fighterId = try values.decodeIfPresent(String.self, forKey: .fighterType)!
        self.fighterType = FighterType(rawValue: fighterId)!
    }
}

//MARK: - Codable extension
extension FetchedPlayer: Codable {
    private enum CodingKeys : String, CodingKey {
        case userId = "userId"
        case username = "username"
        case photoUrl = "photoUrl"
        case moves = "moves"
        case fighterType = "fighterType"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        //This if let prevents writes to the database where the value is null
        try container.encode(userId, forKey: .userId)
        try container.encode(username, forKey: .username)
        try container.encode(photoUrl, forKey: .photoUrl)
        try container.encode(moves, forKey: .moves)
        try container.encode(fighterType.rawValue, forKey: .fighterType)
    }
}
