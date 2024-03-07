//
//  Defend.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

enum DefendPosition: Int {
    case forward = 1
    case left = 2
    case backward = 3
    case right = 4
}

enum DefendButtonState: Int {
    case initial = 0
    case unselected = 1
    case selected = 2
    case cooldown = 3
}

protocol DefendProtocol: MoveProtocol {
    ///The percentage amount of damage boost this move adds to attack's damage. 0 means no additional damage increase from this DefendProtocol move
    var damageMultiplier: Double { get }
    ///The percentage amount of speed boost this move adds to attack's speed. 0 means no additional speed increase
    var speedMultiplier: Double { get }
    ///The percentage amount of defense boost this move reduces from incoming damage. 0 means no additional damage reduction
    var defenseMultiplier: Double { get }
    ///Position of the defense in the view
    var position: DefendPosition { get }
}

struct Defend: DefendProtocol {
    var name: String
    var id: String
    var backgroundColor: Color
    var imageName: String
    var moveType: MoveType
    var padding: Double
    var damageMultiplier: Double
    var speedMultiplier: Double
    var defenseMultiplier: Double
    var position: DefendPosition

    var state: DefendButtonState

    init(_ defend: any DefendProtocol) {
        self.name = defend.name
        self.id = defend.id
        self.backgroundColor = defend.backgroundColor
        self.imageName = defend.imageName
        self.moveType = defend.moveType
        self.padding = defend.padding
        self.damageMultiplier = defend.damageMultiplier
        self.speedMultiplier = defend.speedMultiplier
        self.defenseMultiplier = defend.defenseMultiplier
        self.position = defend.position
        self.state = .selected
    }
}
