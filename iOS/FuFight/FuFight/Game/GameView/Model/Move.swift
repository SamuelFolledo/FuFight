//
//  MoveProtocol.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/5/24.
//

import SwiftUI

enum MoveType {
    case attack
    case defend
}

protocol MoveProtocol: Hashable {
    var name: String { get }
    var id: String { get }
    var backgroundColor: Color { get }
    var imageName: String { get }
    var moveType: MoveType { get }
    var padding: Double { get }
    var cooldown: Int { get }
}
