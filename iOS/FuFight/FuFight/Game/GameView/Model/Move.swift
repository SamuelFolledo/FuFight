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

enum MoveButtonState: Int {
    case initial = 0
    case unselected = 1
    case selected = 2
    case cooldown = 3

    var opacity: CGFloat {
        switch self {
        case .cooldown:
            0.5
        case .selected:
            0.75
        case .initial, .unselected:
            1
        }
    }

    var blurRadius: CGFloat {
        switch self {
        case .cooldown:
            2
        case .initial, .selected, .unselected:
            0
        }
    }
}
