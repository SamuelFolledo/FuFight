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
    var moveSelected: ((_ moveId: String) -> Void)?

    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = playerType.isEnemy ? 2 : 8
            let size = abs(geometry.size.height * (1/2) - (spacing * 2 / 3))

            HStack(alignment: .bottom, spacing: spacing) {
                createButtonFrom(.left, size: size)

                VStack {
                    createButtonFrom(.forward, size: size)

                    createButtonFrom(.backward, size: size)
                }

                createButtonFrom(.right, size: size)
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder func createButtonFrom(_ position: DefensePosition, size: CGFloat) -> some View {
        if let move = defenses.first(where: { $0.position == position }) {
            MoveButton(move: move, playerType: playerType, moveSelected: moveSelected)
                .frame(height: playerType.shouldFlip ? 18 : size)
        }
    }
}

#Preview {
    DefensesView(defenses: defaultAllDashDefenses, playerType: .enemy)
}
