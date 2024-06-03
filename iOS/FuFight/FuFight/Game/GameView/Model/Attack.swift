//
//  Attack.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

enum AttackPosition: Int {
    case leftLight = 1
    case rightLight = 2
    case leftMedium = 3
    case rightMedium = 4
    case leftHard = 5
    case rightHard = 6

    var isLeft: Bool {
        return rawValue % 2 == 1
    }
}

protocol AttackTypeProtocol: AttackProtocol, Move {}

///Protocol to represent Attack's mutable properties and methods
protocol AttackObjectProtocol: AttackProtocol {
    var fireState: FireState { get set }

    func setFireState(to newFireState: FireState)
}

protocol AttackProtocol {
    ///The base damage of this attack
    var damage: Double { get }
    ///How fast this attack is and will determine who goes first
    var speed: Double { get }
    ///The percentage amount of damage reduction this attack will apply to the enemy. 1 will not reduce any attack, 0 will fully remove the damage of the next attack
    var damageReduction: Double { get }
    ///Position of the attack in the view
    var position: AttackPosition { get }
    ///Returns true if attack can increase next attack's damage. If true, these attacks can be slightly boosted indicated with small fire
    var canBoost: Bool { get }
}

struct Attack: MoveProtocol, AttackProtocol, AttackTypeProtocol {
    private var move: any AttackTypeProtocol

    //MARK: Move Protocol
    var name: String { move.name }
    var id: String { move.id }
    var iconName: String { move.iconName }
    var backgroundIconName: String { move.backgroundIconName }
    var padding: Double { move.padding }
    var isAttack: Bool { move.isAttack }
    var animationType: AnimationType { move.animationType }
    var cooldown: Int { move.cooldown }
    var currentCooldown: Int = 0
    var state: MoveButtonState = .initial

    //MARK: AttackProtocol
    var damage: Double { move.damage }
    var speed: Double { move.speed }
    var damageReduction: Double { move.damageReduction }
    var position: AttackPosition { move.position }
    var canBoost: Bool { move.canBoost }
    var fireState: FireState = .initial

    //MARK: Other Properties
    var isAvailableNextRound: Bool { currentCooldown <= 1 }

    //MARK: - Initializers
    init(_ attack: any AttackTypeProtocol) {
        self.move = attack
    }

    init?(moveId: String) {
        if let move = Punch(rawValue: moveId) {
            self.move = move
        } else if let move = Kick(rawValue: moveId) {
            self.move = move
        } else {
            return nil
        }
    }

    //MARK: - Hashable Required Methods
    static func == (lhs: Attack, rhs: Attack) -> Bool {
        return lhs.id == lhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    //MARK: - Other Public Methods
    ///Toggle between punch and kick for the given AttackPosition
    mutating func toggleAttackType(at position: AttackPosition) {
        if position == move.position {
            switch move.position {
            case .leftLight:
                move = move.id == Punch.leftPunchLight.id ? Kick.leftKickLight : Punch.leftPunchLight
            case .rightLight:
                move = move.id == Punch.rightPunchLight.id ? Kick.rightKickLight : Punch.rightPunchLight
            case .leftMedium:
                move = move.id == Punch.leftPunchMedium.id ? Kick.leftKickMedium : Punch.leftPunchMedium
            case .rightMedium:
                move = move.id == Punch.rightPunchMedium.id ? Kick.rightKickMedium : Punch.rightPunchMedium
            case .leftHard:
                move = move.id == Punch.leftPunchHard.id ? Kick.leftKickHard : Punch.leftPunchHard
            case .rightHard:
                move = move.id == Punch.rightPunchHard.id ? Kick.rightKickHard : Punch.rightPunchHard
            }
        }
    }

    mutating func setFireState(to newFireState: FireState) {
        self.fireState = newFireState
    }
}

//MARK: - Decodable extension
extension Attack: Codable {
    private enum CodingKeys : String, CodingKey {
        case move = "move"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(move.id, forKey: .move)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let moveId = try values.decodeIfPresent(String.self, forKey: .move)!
        self.move = Attack(moveId: moveId)!
    }
}
