//
//  DefensesView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

struct DefensesView: View {
    var defenses: [Defend]
    var selectionHandler: ((Defend) -> Void)

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
        ForEach(defenses, id: \.id) { defense in
            if defense.position == position {
                MoveButton(move: defense, action: { selectionHandler(defense) })
                .frame(width: 100)
            }
        }
    }
}

#Preview {
    DefensesView(defenses: defaultAllDashDefenses, selectionHandler: { _ in })
}
