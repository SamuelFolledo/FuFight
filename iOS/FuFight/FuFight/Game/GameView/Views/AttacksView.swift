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
                MoveButton(move: move.move, action: { selectionHandler(move) })
                    .frame(width: 100)
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
    AttacksView(attacks: defaultAllPunchAttacks, selectionHandler: { _ in })
}
