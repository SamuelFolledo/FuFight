//
//  Round.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/11/24.
//

import Foundation

///This class keeps track of Player's current round selections
struct Round {
    let round: Int
    var attack: Attack?
    var defend: Defense?
    var attackResult: AttackResult?

    var resultValue: String {
        if let result = attackResult {
            return "\(result.damageText)"
        }
        return "???"
    }

    init(round: Int) {
        self.round = round
    }
}

extension Round: Equatable, Hashable {
    static func == (lhs: Round, rhs: Round) -> Bool {
        return lhs.round == rhs.round
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(round)
    }
}

//MARK: - Codable extension
extension Round: Codable {
    private enum CodingKeys : String, CodingKey {
        case round
        case attack
        case defend
        //No need to encode/decode because we will not be uploading attackResult to the database
//        case attackResult
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(round, forKey: .round)
        try container.encode(attack, forKey: .attack)
        try container.encode(defend, forKey: .defend)
//        try container.encode(attackResult, forKey: .attackResult)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.round = try values.decodeIfPresent(Int.self, forKey: .round)!
        self.attack = try values.decodeIfPresent(Attack.self, forKey: .attack)
        self.defend = try values.decodeIfPresent(Defense.self, forKey: .defend)
//        self.attackResult = try values.decodeIfPresent(String.self, forKey: .attackResult)
    }
}
