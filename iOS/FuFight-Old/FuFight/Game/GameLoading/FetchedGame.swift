//
//  FetchedGame.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/21/24.
//

import FirebaseFirestore

struct FetchedGame {
    @DocumentID var ownerId: String?
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
