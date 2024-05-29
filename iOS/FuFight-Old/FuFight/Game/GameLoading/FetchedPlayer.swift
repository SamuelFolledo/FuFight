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
    private(set) var isEnemy: Bool
    var fighterType: FighterType
    var moves: Moves

    init(userId: String, username: String, photoUrl: URL, isEnemy: Bool, fighterType: FighterType, moves: Moves) {
        self.userId = userId
        self.username = username
        self.photoUrl = photoUrl
        self.isEnemy = isEnemy
        self.fighterType = fighterType
        self.moves = moves
    }

    init(_ player: Player) {
        self.userId = player.userId
        self.username = player.username
        self.photoUrl = player.photoUrl
        self.moves = player.moves
        self.fighterType = player.fighter.fighterType
        self.isEnemy = player.isEnemy
    }

    ///Creates an enemy player from the room
    init?(room: Room?, isRoomOwner: Bool) {
        guard let room,
              let player = room.player,
              let enemyPlayer = room.challengers.first
        else { return nil }
        self.photoUrl = !isRoomOwner ? player.photoUrl : enemyPlayer.photoUrl
        self.username = !isRoomOwner ? player.username : enemyPlayer.username
        self.userId = !isRoomOwner ? player.userId : enemyPlayer.userId
        self.moves = !isRoomOwner ? player.moves : enemyPlayer.moves
        self.fighterType = !isRoomOwner ? player.fighterType : enemyPlayer.fighterType
        self.isEnemy = true
    }

    ///Default value/initializer for FetchedPlayer from current logged in account
    init(_ account: Account) {
        self.userId = account.userId
        self.username = account.username!
        self.photoUrl = account.photoUrl!
        self.fighterType = .samuel
        self.moves = Moves(attacks: Punch.allCases.compactMap { Attack($0) }, defenses: Dash.allCases.compactMap { Defense($0) })
        self.isEnemy = false
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let userId = try values.decodeIfPresent(String.self, forKey: .userId)!
        self.userId = userId
        self.username = try values.decodeIfPresent(String.self, forKey: .username)!
        self.photoUrl = try values.decodeIfPresent(URL.self, forKey: .photoUrl)!
        self.moves = try values.decodeIfPresent(Moves.self, forKey: .moves)!
        let fighterId = try values.decodeIfPresent(String.self, forKey: .fighterType)!
        let fighterType = FighterType(rawValue: fighterId)!
        self.fighterType = fighterType
        self.isEnemy = try values.decodeIfPresent(Bool.self, forKey: .isEnemy)!
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
        case isEnemy = "isEnemy"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        //This if let prevents writes to the database where the value is null
        try container.encode(userId, forKey: .userId)
        try container.encode(username, forKey: .username)
        try container.encode(photoUrl, forKey: .photoUrl)
        try container.encode(moves, forKey: .moves)
        try container.encode(fighterType.rawValue, forKey: .fighterType)
        try container.encode(isEnemy, forKey: .isEnemy)
    }
}
