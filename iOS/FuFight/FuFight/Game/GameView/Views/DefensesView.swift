//
//  DefensesView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

struct DefensesView: View {
    @Binding var defenses: [Defend]
    var sourceType: MovesViewSourceType

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

    @ViewBuilder func createButtonFrom(_ position: DefendPosition) -> some View {
        ForEach(defenses, id: \.move.id) { move in
            if move.move.position == position {
                Button(action: {
                    selectMove(move)
                }, label: {
                    Image(move.move.imageName)
                        .defaultImageModifier()
                        .aspectRatio(1.0, contentMode: .fit)
                        .padding(sourceType == .enemy ? 4 : move.move.padding)
                        .background(
                            Image(move.move.moveType == .attack ? "moveBackgroundRed" : "moveBackgroundBlue")
                                .backgroundImageModifier()
                                .scaledToFit()
                        )
                })
                .frame(width: sourceType.shouldFlip ? 18 : 100)
                .blur(radius: move.state.blurRadius, opaque: false)
                .opacity(move.state.opacity)
                .overlay {
                    switch move.state {
                    case .cooldown:
                        Text("\(move.cooldown)")
                            .font(sourceType.font)
                            .foregroundStyle(.white)
                            .rotationEffect(sourceType.angle)
                    case .selected:
                        Circle()
                            .stroke(.yellow, lineWidth: 2)
                    case .initial, .unselected:
                        EmptyView()
                    }
                }
            }
        }
    }

    func selectMove(_ selectedMove: Defend) {
        guard selectedMove.state != .cooldown else { return }
        for (index, defense) in defenses.enumerated() {
            if defense.move.id == selectedMove.move.id {
                defenses[index].setStateTo(.selected)
            } else {
                guard defenses[index].state != .cooldown else { continue }
                defenses[index].setStateTo(.unselected)
            }
        }
    }
}

#Preview {
    DefensesView(defenses: .constant(defaultAllDashDefenses), sourceType: .enemy)
}
