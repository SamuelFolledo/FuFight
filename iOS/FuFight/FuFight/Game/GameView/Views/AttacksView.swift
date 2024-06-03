//
//  AttacksView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

struct AttacksView: View {
    let attacks: [Attack]
    let playerType: PlayerType
    var isEditing: Bool
    var moveSelected: ((any MoveProtocol) -> Void)?

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
        if let move = attacks.first(where: { $0.position == position }) {
            AttackButton(move: move, 
                         playerType: playerType,
                         isEditing: isEditing,
                         moveSelected: moveSelected)
        }
    }
}

#Preview {
    return VStack(spacing: 200) {
        AttacksView(attacks: defaultAllPunchAttacks, playerType: .enemy, isEditing: false)

        AttacksView(attacks: defaultAllPunchAttacks, playerType: .user, isEditing: false)
    }
}
