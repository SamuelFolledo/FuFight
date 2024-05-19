//
//  GameLobby.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/17/24.
//

import FirebaseFirestore

struct GameLobby {
    @DocumentID var lobbyId: String?
    private(set) var userId: String?
    private(set) var username: String?
    private(set) var photoUrl: URL?
    private(set) var moves: Moves?
    private(set) var fighterType: FighterType?
    private(set) var enemyId: String?
    private(set) var enemyUsername: String?
    private(set) var enemyPhotoUrl: URL?
    private(set) var enemyMoves: Moves?
    private(set) var enemyFighterType: FighterType?

    var isValid: Bool {
        enemyId != nil && userId != nil
    }

    ///Lobby owner initializer
    init(player: Player) {
        self.userId = player.userId
        self.username = player.username
        self.photoUrl = player.photoUrl
        self.moves = player.moves
        self.fighterType = player.fighter.fighterType
    }

    ///Lobby joiner/enemy initializer
    init(lobbyId: String, enemyPlayer: Player) {
        self.lobbyId = lobbyId
        self.enemyId = enemyPlayer.userId
        self.enemyUsername = enemyPlayer.username
        self.enemyPhotoUrl = enemyPlayer.photoUrl
        self.enemyMoves = enemyPlayer.moves
        self.enemyFighterType = enemyPlayer.fighter.fighterType
    }
}

//MARK: - Decodable extension
extension GameLobby: Codable {
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
        //This if let prevents writes to the database where the value is null
        if let userId {
            try container.encode(userId, forKey: .userId)
        }
        if let username {
            try container.encode(username, forKey: .username)
        }
        if let photoUrl {
            try container.encode(photoUrl, forKey: .photoUrl)
        }
        if let moves {
            try container.encode(moves, forKey: .moves)
        }
        if let fighterType {
            try container.encode(fighterType.rawValue, forKey: .fighterType)
        }
        if let enemyId {
            try container.encode(enemyId, forKey: .enemyId)
        }
        if let enemyUsername {
            try container.encode(enemyUsername, forKey: .enemyUsername)
        }
        if let enemyPhotoUrl {
            try container.encode(enemyPhotoUrl, forKey: .enemyPhotoUrl)
        }
        if let enemyMoves {
            try container.encode(enemyMoves, forKey: .enemyMoves)
        }
        if let enemyFighterType {
            try container.encode(enemyFighterType.rawValue, forKey: .enemyFighterType)
        }
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try values.decodeIfPresent(String.self, forKey: .userId)!
        self.username = try values.decodeIfPresent(String.self, forKey: .username)!
        self.photoUrl = try values.decodeIfPresent(URL.self, forKey: .photoUrl)!
        self.moves = try values.decodeIfPresent(Moves.self, forKey: .moves)
        if let fighterId = try values.decodeIfPresent(String.self, forKey: .fighterType) {
            self.fighterType = FighterType(rawValue: fighterId)
        }
        self.enemyId = try values.decodeIfPresent(String.self, forKey: .enemyId)
        self.enemyUsername = try values.decodeIfPresent(String.self, forKey: .enemyUsername)
        self.enemyPhotoUrl = try values.decodeIfPresent(URL.self, forKey: .enemyPhotoUrl)
        self.enemyMoves = try values.decodeIfPresent(Moves.self, forKey: .enemyMoves)
        if let enemyFighterId = try values.decodeIfPresent(String.self, forKey: .enemyFighterType) {
            self.enemyFighterType = FighterType(rawValue: enemyFighterId)
        }
    }
}
