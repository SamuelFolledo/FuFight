//
//  GameLobby.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/17/24.
//

import FirebaseFirestore

struct GameLobby: Codable {
    @DocumentID var lobbyId: String?
    var userId: String
    var username: String
    var photoUrl: URL
    var moves: Moves?
    var fighterType: FighterType?
    var enemyId: String?
    var enemyUsername: String?
    var enemyPhotoUrl: URL?
    var enemyMoves: Moves?
    var enemyFighterType: FighterType?

    var isValid: Bool {
        enemyId != nil && !userId.isEmpty
    }

    //MARK: - Codable overrides
    private enum CodingKeys : String, CodingKey {
        case userId = "userId"
        case username = "username"
        case photoUrl = "photoUrl"
        case moves = "moves"
        case fighterType = "fighterType"
        case enemyId = "enemyId"
        case enemyUsername = "enemyUsername"
        case enemyPhotoUrl = "enemyPhotoUrl"
        case enemyMoves = "enemyMoves"
        case enemyFighterType = "enemyFighterType"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(username, forKey: .username)
        try container.encode(photoUrl, forKey: .photoUrl)
        if let fighterType {
            try container.encode(fighterType.rawValue, forKey: .fighterType)
        }
        try container.encode(enemyId, forKey: .enemyId)
        try container.encode(enemyUsername, forKey: .enemyUsername)
        try container.encode(enemyPhotoUrl, forKey: .enemyPhotoUrl)
        if let enemyFighterType {
            try container.encode(enemyFighterType.rawValue, forKey: .enemyFighterType)
        }

    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try values.decodeIfPresent(String.self, forKey: .userId)!
        self.username = try values.decodeIfPresent(String.self, forKey: .username)!
        self.photoUrl = try values.decodeIfPresent(URL.self, forKey: .photoUrl)!
        if let fighterId = try values.decodeIfPresent(String.self, forKey: .fighterType) {
            self.fighterType = FighterType(rawValue: fighterId)
        }
        self.enemyId = try values.decodeIfPresent(String.self, forKey: .enemyId)
        self.enemyUsername = try values.decodeIfPresent(String.self, forKey: .enemyUsername)
        self.enemyPhotoUrl = try values.decodeIfPresent(URL.self, forKey: .enemyPhotoUrl)
        if let enemyFighterId = try values.decodeIfPresent(String.self, forKey: .enemyFighterType) {
            self.enemyFighterType = FighterType(rawValue: enemyFighterId)
        }
    }
}
