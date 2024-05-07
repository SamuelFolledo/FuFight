//
//  AttackButton.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/5/24.
//

import SwiftUI

struct AttackButton: View {
    let move: Attack
    let playerType: PlayerType
    let moveSelected: ((any MoveProtocol) -> Void)?

    private var width: CGFloat { playerType.isEnemy ? 160 : 800 }
    private var trailingPadding: CGFloat { playerType.isEnemy ? 4 : 30 }
    private let fireSizeType = "" //Choose between "", "-light", or "-fast"

    var body: some View {
        MoveButton(move: move, playerType: playerType, moveSelected: moveSelected)
            .frame(width: playerType.shouldFlip ? 30 : 100)
            .overlay {
                switch move.state {
                case .cooldown:
                    EmptyView()
                case .initial, .unselected, .selected:
                    switch move.fireState {
                    case .initial:
                        EmptyView()
                    case .small:
                        let height: CGFloat = playerType.isEnemy ? 85 : 420
                        let bottomPadding: CGFloat = playerType.isEnemy ? 16 : 75
                        GIFView(type: URLType.name("weakRedFire\(fireSizeType)"))
                            .frame(width: width, height: height)
                            .padding(.bottom, bottomPadding)
                            .padding(.trailing, trailingPadding)
                            .rotationEffect(playerType.angle)
                            .allowsHitTesting(false)
                    case .big:
                        let height: CGFloat = playerType.isEnemy ? 90 : 420
                        let bottomPadding: CGFloat = playerType.isEnemy ? 16 : 65
                        GIFView(type: URLType.name("strongRedFire\(fireSizeType)"))
                            .frame(width: width, height: height)
                            .padding(.bottom, bottomPadding)
                            .padding(.trailing, trailingPadding)
                            .rotationEffect(playerType.angle)
                            .allowsHitTesting(false)
                    }
                }
            }
            .overlay {
                MoveStateView(state: move.state, cooldown: move.currentCooldown, playerType: playerType)
            }
    }
}

#Preview {
    let attack = Attack(Punch.leftPunchMedium)
    return AttackButton(move: attack, playerType: .user) {
        LOGD("Attack selected = \($0.name)")
    }
}
