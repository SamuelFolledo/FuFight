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
    var moveSelected: ((any MoveProtocol) -> Void)?

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
        if let move = defenses.first(where: { $0.position == position }) {
            MoveButton(move: move, playerType: playerType, moveSelected: moveSelected)
                .frame(width: playerType.shouldFlip ? 18 : 100)
        }
    }
}

#Preview {
    DefensesView(defenses: defaultAllDashDefenses, playerType: .enemy)
}
