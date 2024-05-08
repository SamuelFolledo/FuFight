//
//  MoveStateView.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/6/24.
//

import SwiftUI

struct MoveStateView: View {
    var state: MoveButtonState
    var cooldown: Int
    let playerType: PlayerType

    var body: some View {
        Group {
            switch state {
            case .cooldown:
                Text("\(cooldown)")
                    .font(playerType.font)
                    .foregroundStyle(.white)
            case .selected:
                Circle()
                    .stroke(.green, lineWidth: playerType.shouldFlip ? 2 : 4)
            case .initial, .unselected:
                EmptyView()
            }
        }
        .rotationEffect(playerType.angle)
        .allowsHitTesting(false)
    }
}

#Preview {
    let attack = Attack(Punch.leftPunchMedium)
    return MoveStateView(state: attack.state, cooldown: attack.currentCooldown, playerType: .user)
}
