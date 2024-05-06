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
            AttackButton(move: move, playerType: playerType, moveSelected: moveSelected)
        }
    }
}

#Preview {
    @State var attacks: [Attack] = defaultAllPunchAttacks

    return VStack(spacing: 200) {
        AttacksView(attacks: attacks, playerType: .enemy)

        AttacksView(attacks: attacks, playerType: .user)
    }
}
