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
    var moveSelected: ((Attack) -> Void)?

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
        .frame(width: playerType.shouldFlip ? 30 : 100) //
        .blur(radius: move.state.blurRadius, opaque: false)
        .colorMultiply(move.state == .selected ? Color.systemGray2 : Color.white) //
        .opacity(move.state.opacity)
        .overlay {
            getFireView(from: move)//
        }
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
