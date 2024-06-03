//
//  FetchedGame.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/21/24.
//

import FirebaseFirestore

struct FetchedGame {
    @DocumentID private var documentId: String?
    var ownerId: String { documentId! }
    private(set) var player: FetchedPlayer
    private(set) var enemyPlayer: FetchedPlayer
    let ownerInitiallyHasSpeedBoost: Bool

    ///Initializer for the owner
    init(player: FetchedPlayer, enemyPlayer: FetchedPlayer, ownerInitiallyHasSpeedBoost: Bool) {
        self.documentId = player.userId
        self.player = player
        self.enemyPlayer = enemyPlayer
        self.ownerInitiallyHasSpeedBoost = ownerInitiallyHasSpeedBoost
    }
}

//MARK: - Codable extension
extension FetchedGame: Codable {
    private enum CodingKeys : String, CodingKey {
        case ownerId = "ownerId"
        case player = "userPlayer"
        case enemyPlayer = "enemyPlayer"
        case ownerInitiallyHasSpeedBoost = "ownerInitiallyHasSpeedBoost"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(player, forKey: .player)
        try container.encode(enemyPlayer, forKey: .enemyPlayer)
        try container.encode(ownerInitiallyHasSpeedBoost, forKey: .ownerInitiallyHasSpeedBoost)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.documentId = try values.decodeIfPresent(String.self, forKey: .ownerId)!
        self.player = try values.decodeIfPresent(FetchedPlayer.self, forKey: .player)!
        self.enemyPlayer = try values.decodeIfPresent(FetchedPlayer.self, forKey: .enemyPlayer)!
        self.ownerInitiallyHasSpeedBoost = try values.decodeIfPresent(Bool.self, forKey: .ownerInitiallyHasSpeedBoost)!
    }
}
