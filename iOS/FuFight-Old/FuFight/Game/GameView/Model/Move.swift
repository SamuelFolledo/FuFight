//
//  MoveProtocol.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/5/24.
//

import SwiftUI

/**
 ## Terms
 - Multipier in Attack and Defend:
    If default multiplier value of 1, in `0 > x > 1 > y`. In x, meaning values between 0 and 1, will be a reduction multiplier where 0.85 speedMultiplier will reduce speed by 15%. In y, meaning values greater than 1, will increase speed where 1.5 will increase speed by 50%
 */

protocol MoveProtocol: Hashable {
    var name: String { get }
    var id: String { get }
    var iconName: String { get }
    var backgroundIconName: String { get }
    var padding: Double { get }
    ///animation to play for this attack
    var animationType: AnimationType { get }
    ///Move's cooldown
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
