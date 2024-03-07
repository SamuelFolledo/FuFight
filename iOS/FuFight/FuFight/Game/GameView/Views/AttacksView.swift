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
        ForEach(attacks, id: \.id) { attack in
            if attack.position == position {
                MoveButton(move: attack, action: { selectionHandler(attack) })
                    .frame(width: 100)
                    .opacity(attack.state == .unselected ? 0.4 : 1)
            }
        }
    }
}

#Preview {
    AttacksView(attacks: defaultAllPunchAttacks, selectionHandler: { _ in })
}
