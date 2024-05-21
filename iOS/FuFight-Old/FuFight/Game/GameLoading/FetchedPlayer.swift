//
//  FetchedPlayer.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/20/24.
//

import FirebaseFirestore

struct FetchedGame {
    private(set) var player: FetchedPlayer
    private(set) var enemyPlayer: FetchedPlayer
}

//MARK: - Codable extension
extension FetchedGame: Codable {
    private enum CodingKeys : String, CodingKey {
        case player = "userPlayer"
        case enemyPlayer = "enemyPlayer"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(player, forKey: .player)
        try container.encode(enemyPlayer, forKey: .enemyPlayer)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.player = try values.decodeIfPresent(FetchedPlayer.self, forKey: .player)!
        self.enemyPlayer = try values.decodeIfPresent(FetchedPlayer.self, forKey: .enemyPlayer)!
    }
}

struct FetchedPlayer {
    private(set) var userId: String
    private(set) var username: String
    private(set) var photoUrl: URL
    private(set) var moves: Moves
    private(set) var fighterType: FighterType

    init(_ player: Player) {
        self.userId = player.userId
        self.username = player.username
        self.photoUrl = player.photoUrl!
        self.moves = player.moves
        self.fighterType = player.fighter.fighterType
    }

//    init?(fetchedPlayerDic: [String: Any]) {
//        guard let userId = fetchedPlayerDic[kUSERID] as? String,
//              let username = fetchedPlayerDic[kUSERNAME] as? String,
//              let urlString = fetchedPlayerDic[kPHOTOURL] as? String,
//              let fighterTypeId = fetchedPlayerDic[kUSERFIGHTERTYPE] as? String,
//    }
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

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try values.decodeIfPresent(String.self, forKey: .userId)!
        self.username = try values.decodeIfPresent(String.self, forKey: .username)!
        self.photoUrl = try values.decodeIfPresent(URL.self, forKey: .photoUrl)!
        self.moves = try values.decodeIfPresent(Moves.self, forKey: .moves)!
        let fighterId = try values.decodeIfPresent(String.self, forKey: .fighterType)!
        self.fighterType = FighterType(rawValue: fighterId)!
    }
}
