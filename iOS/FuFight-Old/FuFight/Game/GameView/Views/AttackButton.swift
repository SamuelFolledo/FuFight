//
//  AttackButton.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/5/24.
//

import SwiftUI

struct AttackButton: View {
    var move: Attack
    let playerType: PlayerType
    var moveSelected: ((any MoveProtocol) -> Void)?

    var body: some View {
        MoveButton(move: move, playerType: playerType, moveSelected: moveSelected)
            .frame(width: playerType.shouldFlip ? 30 : 100)
            .colorMultiply(move.state == .selected ? Color.systemGray2 : Color.white)
            .overlay {
                getFireView(from: move)
            }
    }

    var weakRedFire: some View {
        let width: CGFloat = playerType.isEnemy ? 160 : 800
        let height: CGFloat = playerType.isEnemy ? 85 : 420
        let bottomPadding: CGFloat = playerType.isEnemy ? 16 : 75
        let trailingPadding: CGFloat = playerType.isEnemy ? 4 : 30
        return GIFView(type: URLType.name("weakRedFire"))
            .frame(width: width, height: height)
            .padding(.bottom, bottomPadding)
            .padding(.trailing, trailingPadding)
    }

    var strongRedFire: some View {
        let width: CGFloat = playerType.isEnemy ? 160 : 800
        let height: CGFloat = playerType.isEnemy ? 90 : 420
        let bottomPadding: CGFloat = playerType.isEnemy ? 16 : 65
        let trailingPadding: CGFloat = playerType.isEnemy ? 4 : 30
        return GIFView(type: URLType.name("strongRedFire"))
            .frame(width: width, height: height)
            .padding(.bottom, bottomPadding)
            .padding(.trailing, trailingPadding)
    }

    @ViewBuilder func getFireView(from move: Attack) -> some View {
        Group {
            switch move.state {
            case .cooldown:
                EmptyView()
            case .initial, .unselected, .selected:
                switch move.fireState {
                case .initial:
                    EmptyView()
                case .small:
                    weakRedFire
                case .big:
                    strongRedFire
                }
            }
        }
        .rotationEffect(playerType.angle)
        .allowsHitTesting(false)
    }
}

#Preview {
    var attack = Attack(Punch.leftPunchMedium)
    return AttackButton(move: attack, playerType: .user) {
        LOGD("Attack selected = \($0.name)")
    }
}
