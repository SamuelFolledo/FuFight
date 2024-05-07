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
        .colorMultiply(move.state == .selected ? Color.systemGray2 : Color.white)
        .overlay {
            MoveStateView(state: move.state, cooldown: move.currentCooldown, playerType: playerType)
        }
    }
}

#Preview {
    let attack = Attack(Punch.leftPunchMedium)
    return MoveButton(move: attack, playerType: .user) {
        LOGD("Attack selected = \($0.name)")
    }
}
