//
//  Round.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/11/24.
//

import Foundation

///This class keeps track of Player's current round selections
struct Round {
    private(set) var round: Int
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
