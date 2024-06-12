//
//  SelectedMoves.swift
//  FuFight
//
//  Created by Samuel Folledo on 6/5/24.
//

import Foundation

struct SelectedMove: Codable {
    var attackPosition: AttackPosition?
    var defensePosition: DefensePosition?

    init(round: Round) {
        self.attackPosition = round.attack?.position
        self.defensePosition = round.defend?.position
    }

    private enum CodingKeys : String, CodingKey {
        case attackPosition
        case defensePosition
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(attackPosition?.rawValue, forKey: .attackPosition)
        try container.encode(defensePosition?.rawValue, forKey: .defensePosition)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let attackPositionId = try values.decodeIfPresent(String.self, forKey: .attackPosition),
           let attackPosition = AttackPosition(rawValue: attackPositionId) {
            self.attackPosition = attackPosition
        }
        if let defensePositionId = try values.decodeIfPresent(String.self, forKey: .defensePosition),
           let defensePosition = DefensePosition(rawValue: defensePositionId) {
            self.defensePosition = defensePosition
        }
    }
}
