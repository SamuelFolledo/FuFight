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
}

//MARK: - Codable extension
extension FetchedGame: Codable {
    private enum CodingKeys : String, CodingKey {
        case ownerId = "ownerId"
        case player = "userPlayer"
        case enemyPlayer = "enemyPlayer"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(player, forKey: .player)
        try container.encode(enemyPlayer, forKey: .enemyPlayer)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.documentId = try values.decodeIfPresent(String.self, forKey: .ownerId)!
        self.player = try values.decodeIfPresent(FetchedPlayer.self, forKey: .player)!
        self.enemyPlayer = try values.decodeIfPresent(FetchedPlayer.self, forKey: .enemyPlayer)!
    }
}
