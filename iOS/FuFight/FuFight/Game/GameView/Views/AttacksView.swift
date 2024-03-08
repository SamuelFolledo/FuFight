//
//  AttacksView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

struct AttacksView: View {
    var attacks: [Attack]
    var selectionHandler: ((Attack) -> Void)
    var isMini: Bool = false

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
                    selectionHandler(move)
                }, label: {
                    Image(move.move.imageName)
                        .defaultImageModifier()
                        .aspectRatio(1.0, contentMode: .fit)
                        .padding(isMini ? 4 : move.move.padding)
                        .background(
                            Image(move.move.moveType == .attack ? "moveBackgroundRed" : "moveBackgroundBlue")
                                .backgroundImageModifier()
                                .scaledToFit()
                        )
                })
                    .frame(width: isMini ? 30 : 100)
                    .blur(radius: move.state.blurRadius, opaque: false)
                    .opacity(move.state.opacity)
                    .overlay {
                        switch move.state {
                        case .cooldown:
                            Text("\(move.cooldown)")
                                .font(largeTitleFont)
                                .foregroundStyle(.white)
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
}

#Preview {
    AttacksView(attacks: defaultAllPunchAttacks, selectionHandler: { _ in }, isMini: true)
}
