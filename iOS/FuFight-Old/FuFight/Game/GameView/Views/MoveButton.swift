//
//  MoveButton.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/6/24.
//

import SwiftUI

///View that represents both Attach and Defense moves
struct MoveButton: View {
    var move: any MoveProtocol
    let playerType: PlayerType
    var moveSelected: ((any MoveProtocol) -> Void)?

    var body: some View {
        Button(action: {
            moveSelected?(move)
        }, label: {
            Image(move.iconName)
                .defaultImageModifier()
                .aspectRatio(1.0, contentMode: .fit)
                .padding(playerType.isEnemy ? 4 : move.padding)
                .background(
                    Image(move.backgroundIconName)
                        .backgroundImageModifier()
                        .scaledToFit()
                )
        })
        .blur(radius: move.state.blurRadius, opaque: false)
        .opacity(move.state.opacity)
        .overlay {
            Group {
                switch move.state {
                case .cooldown:
                    Text("\(move.currentCooldown)")
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
}

#Preview {
    var attack = Attack(Punch.leftPunchMedium)
    return MoveButton(move: attack, playerType: .user) {
        LOGD("Attack selected = \($0.name)")
    }
}
