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
}

enum AttackButtonState: Int {
    case initial = 0
    case unselected = 1
    case selected = 2
    case cooldown = 3
    case smallFire = 4
    case bigFire = 5
}

protocol AttackProtocol: MoveProtocol {
    ///The base damage of this attack
    var damage: Double { get }
    ///How fast this attack is and will determine who goes first
    var speed: Double { get }
    ///The percentage amount of damage reduction this attack will apply to the enemy. 0 will not reduce any attack, 1 will fully remove the damage of the next attack
    var damageReduction: Double { get }
    ///Position of the attack in the view
    var position: AttackPosition { get }
}


struct Attack: AttackProtocol {
    var name: String
    var id: String
    var backgroundColor: Color
    var imageName: String
    var moveType: MoveType
    var padding: Double
    var damage: Double
    var speed: Double
    var damageReduction: Double
    var position: AttackPosition

    var state: AttackButtonState

    init(_ attack: any AttackProtocol) {
        self.name = attack.name
        self.id = attack.id
        self.backgroundColor = attack.backgroundColor
        self.imageName = attack.imageName
        self.moveType = attack.moveType
        self.padding = attack.padding
        self.damage = attack.damage
        self.speed = attack.speed
        self.damageReduction = attack.damageReduction
        self.position = attack.position
        self.state = .selected
    }
}
