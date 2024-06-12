//
//  Defense.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

enum DefensePosition: String {
    case forward
    case left
    case backward
    case right
}

protocol DefenseTypeProtocol: DefenseProtocol, Move {}

protocol DefenseProtocol {
    ///The percentage amount of damage boost this move adds to attack's damage. 1 is default and 0 means no additional damage increase from this DefenseProtocol move
    var damageMultiplier: Double { get }
    ///The percentage amount of speed boost this move adds to attack's speed. 1 is default and means no additional speed increase
    var speedMultiplier: Double { get }
    ///The percentage amount of defense boost this move reduces from incoming damage. 1 is default and means no additional damage reduction. In `0 > x > 1 > y`. In x, meaning values between 0 and 1, will reduce incoming damage. In y, meaning values over 1, will increase incoming damage (e.g. dash forward move)
    var incomingDamageMultiplier: Double { get }
    ///Position of the defense in the view
    var position: DefensePosition { get }
}

struct Defense: MoveProtocol, DefenseProtocol, DefenseTypeProtocol {
    private let move: any DefenseTypeProtocol

    //MARK: Move Protocol Properties
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

    //MARK: DefenseProtocol
    var damageMultiplier: Double { move.damageMultiplier }
    var speedMultiplier: Double { move.speedMultiplier }
    var incomingDamageMultiplier: Double { move.incomingDamageMultiplier }
    var position: DefensePosition { move.position }

    //MARK: - Initializers
    init(_ defense: any DefenseTypeProtocol) {
        self.move = defense
    }

    init?(moveId: String) {
        if let move = Dash(rawValue: moveId) {
            self.move = move
        } else {
            return nil
        }
    }

    //MARK: - Hashable Required Methods
    static func == (lhs: Defense, rhs: Defense) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    //MARK: - Public Methods
}

//MARK: - Decodable extension
extension Defense: Codable {
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
        self.move = Defense(moveId: moveId)!
    }
}
