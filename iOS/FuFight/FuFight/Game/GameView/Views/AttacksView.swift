//
//  AttacksView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

struct AttacksView: View {
    @Binding var attacks: [Attack]
    var sourceType: MovesViewSourceType

    var body: some View {
        VStack {
            HStack {
                createButtonFrom(.leftLight)

                Spacer()

                createButtonFrom(.rightLight)
            }

            HStack {
                createButtonFrom(.leftMedium)

                Spacer()

                createButtonFrom(.rightMedium)
            }

            HStack {
                createButtonFrom(.leftHard)

                Spacer()

                createButtonFrom(.rightHard)
            }
        }
    }

    @ViewBuilder func createButtonFrom(_ position: AttackPosition) -> some View {
        ForEach(attacks, id: \.move.id) { move in
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
                .frame(width: sourceType.shouldFlip ? 30 : 100)
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
                    case .initial, .unselected, .bigFire, .smallFire:
                        EmptyView()
                    }
                }
            }
        }
    }

    func selectMove(_ selectedMove: Attack) {
        guard selectedMove.state != .cooldown else { return }
        for (index, attack) in attacks.enumerated() {
            if attack.move.id == selectedMove.move.id {
                attacks[index].setStateTo(.selected)
            } else {
                guard attacks[index].state != .cooldown else { continue }
                attacks[index].setStateTo(.unselected)
            }
        }
    }
}

#Preview {
    AttacksView(attacks: .constant(defaultAllPunchAttacks), sourceType: .enemy)
}
