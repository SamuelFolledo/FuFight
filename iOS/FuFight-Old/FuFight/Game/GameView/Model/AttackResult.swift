//
//  AttackResult.swift
//  FuFight
//
//  Created by Samuel Folledo on 4/29/24.
//

import SwiftUI

enum AttackResult {
    ///no attack is selected
    case noAttack
    case miss
    case damage(_ amount: CGFloat)
    /// - parameter amount: damage dealt as the killing blow
    case kill(_ amount: CGFloat)

    var isDefenderAlive: Bool {
        switch self {
        case .noAttack, .miss, .damage(_):
            true
        case .kill(_):
            false
        }
    }

    var didAttackLand: Bool {
        switch self {
        case .noAttack, .miss:
            false
        case .damage(_), .kill(_):
            true
        }
    }

    var damage: CGFloat? {
        switch self {
        case .noAttack, .miss:
            return nil
        case .damage(let amount), .kill(let amount):
            return amount
        }
    }

    var damageText: String {
        switch self {
        case .noAttack:
            "?"
        case .miss:
            "Dodged"
        case .damage(let amount), .kill(let amount):
            amount.intString
        }
    }

    var damageTextColor: Color {
        switch self {
        case .noAttack:
                .white
        case .miss:
                .white
        case .damage(_):
                .orange
        case .kill(_):
                .red
        }
    }
}
