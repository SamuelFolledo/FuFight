//
//  FetchedGame.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/21/24.
//

import FirebaseFirestore

///This class represents a Game document. The authenticated user can be the game's owner or an challenger
struct FetchedGame {
    @DocumentID private var documentId: String?
    var ownerId: String { documentId! }
    private(set) var owner: FetchedPlayer
    private(set) var challenger: FetchedPlayer
    let ownerInitiallyHasSpeedBoost: Bool

    ///Initializer for the owner
    init(owner: FetchedPlayer, challenger: FetchedPlayer, ownerInitiallyHasSpeedBoost: Bool) {
        self.documentId = owner.userId
        self.owner = owner
        self.challenger = challenger
        self.ownerInitiallyHasSpeedBoost = ownerInitiallyHasSpeedBoost
    }
}

//MARK: - Codable extension
extension FetchedGame: Codable {
    private enum CodingKeys : String, CodingKey {
        case ownerId = "ownerId"
        case owner = "owner"
        case challenger = "challenger"
        case ownerInitiallyHasSpeedBoost = "ownerInitiallyHasSpeedBoost"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(owner, forKey: .owner)
        try container.encode(challenger, forKey: .challenger)
        try container.encode(ownerInitiallyHasSpeedBoost, forKey: .ownerInitiallyHasSpeedBoost)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.documentId = try values.decodeIfPresent(String.self, forKey: .ownerId)!
        self.ownerInitiallyHasSpeedBoost = try values.decodeIfPresent(Bool.self, forKey: .ownerInitiallyHasSpeedBoost)!
        self.owner = try values.decodeIfPresent(FetchedPlayer.self, forKey: .owner) ?? FetchedPlayer(fakePlayer)
        self.challenger = try values.decodeIfPresent(FetchedPlayer.self, forKey: .challenger) ?? FetchedPlayer(fakeEnemyPlayer)
    }
}
