//
//  DefensesView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

struct DefensesView: View {
    var defenses: [Defense]
    var playerType: PlayerType
    var moveSelected: ((Defense) -> Void)?

    init(defenses: [Defense], playerType: PlayerType, moveSelected: ((Defense) -> Void)? = nil) {
        self.defenses = defenses
        self.playerType = playerType
        self.moveSelected = moveSelected
    }

    var body: some View {
        HStack(alignment: .bottom) {
            createButtonFrom(.left)

            VStack {
                createButtonFrom(.forward)

                createButtonFrom(.backward)
            }

            createButtonFrom(.right)
        }
    }

    @ViewBuilder func createButtonFrom(_ position: DefensePosition) -> some View {
        ForEach(defenses, id: \.id) { move in
            if move.position == position {
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
                .frame(width: playerType.shouldFlip ? 18 : 100)
                .blur(radius: move.state.blurRadius, opaque: false)
                .opacity(move.state.opacity)
                .overlay {
                    switch move.state {
                    case .cooldown:
                        Text("\(move.currentCooldown)")
                            .font(playerType.font)
                            .foregroundStyle(.white)
                            .rotationEffect(playerType.angle)
                    case .selected:
                        Circle()
                            .stroke(.green, lineWidth: playerType.shouldFlip ? 2 : 4)
                    case .initial, .unselected:
                        EmptyView()
                    }
                }
            }
        }
    }
}

#Preview {
    DefensesView(defenses: defaultAllDashDefenses, playerType: .enemy)
}
