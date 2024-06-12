//
//  FetchedGame.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/21/24.
//

import FirebaseFirestore

///This class represents a Game document. The authenticated user can be the game's player or an enemy
struct FetchedGame {
    @DocumentID private var documentId: String?
    private(set) var player: FetchedPlayer
    private(set) var enemy: FetchedPlayer
    let playerInitiallyHasSpeedBoost: Bool

    private(set) var selectedMoves: [SelectedMove] = []

    ///Initializer for the player
    init(player: FetchedPlayer, enemy: FetchedPlayer, playerInitiallyHasSpeedBoost: Bool) {
        self.documentId = player.userId
        self.player = player
        self.enemy = enemy
        self.playerInitiallyHasSpeedBoost = playerInitiallyHasSpeedBoost
    }
}

//MARK: - Codable extension
extension FetchedGame: Codable {
    private enum CodingKeys : String, CodingKey {
        case playerId = "playerId"
        case player = "player"
        case enemy = "enemy"
        case playerInitiallyHasSpeedBoost = "playerInitiallyHasSpeedBoost"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let documentId {
            try container.encode(documentId, forKey: .playerId)
        }
        try container.encode(player, forKey: .player)
        try container.encode(enemy, forKey: .enemy)
        try container.encode(playerInitiallyHasSpeedBoost, forKey: .playerInitiallyHasSpeedBoost)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.documentId = try values.decodeIfPresent(String.self, forKey: .playerId)
        self.playerInitiallyHasSpeedBoost = try values.decodeIfPresent(Bool.self, forKey: .playerInitiallyHasSpeedBoost)!
        self.player = try values.decodeIfPresent(FetchedPlayer.self, forKey: .player)!
        self.enemy = try values.decodeIfPresent(FetchedPlayer.self, forKey: .enemy)!
    }
}
