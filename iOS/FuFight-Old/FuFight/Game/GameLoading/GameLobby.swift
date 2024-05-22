//
//  GameLobby.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/17/24.
//

import FirebaseFirestore

struct GameLobby {
    @DocumentID private var documentId: String?
    var ownerId: String { documentId! }
    private(set) var player: FetchedPlayer?
    private(set) var challengers: [FetchedPlayer] = []
    private(set) var isSearching: Bool = true

    var isValid: Bool {
        player != nil && challengers.first != nil
    }

    ///Lobby owner initializer
    init(player: Player) {
        self.documentId = player.userId
        self.player = FetchedPlayer(player)
    }

    ///Lobby joiner/enemy initializer
    init(lobbyId: String, enemyPlayer: Player) {
        self.documentId = lobbyId
        challengers.append(FetchedPlayer(enemyPlayer))
    }

    mutating func leaveAsChallenger(userId: String) {
        for (index, challenger) in challengers.enumerated() where challenger.userId == userId {
            challengers.remove(at: index)
        }
    }
}

//MARK: - Codable extension
extension GameLobby: Codable {
    private enum CodingKeys : String, CodingKey {
        case player = "player"
        case challengers = "challengers"
        case ownerId = "ownerId"
        case isSearching = "isSearching"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        //This if let prevents writes to the database where the value is null
        if let player {
            try container.encode(player, forKey: .player)
        }
        try container.encode(challengers, forKey: .challengers)
        try container.encode(isSearching, forKey: .isSearching)
        try container.encode(ownerId, forKey: .ownerId)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.player = try values.decodeIfPresent(FetchedPlayer.self, forKey: .player)
        self.isSearching = try values.decodeIfPresent(Bool.self, forKey: .isSearching) ?? false
        self.challengers = try values.decodeIfPresent(Array<FetchedPlayer>.self, forKey: .challengers) ?? []
        self.documentId = try values.decodeIfPresent(String.self, forKey: .ownerId)!
    }
}
