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
        ForEach(defenses, id: \.move.id) { move in
            if move.move.position == position {
                MoveButton(move: move.move, action: { selectionHandler(move) })
                    .frame(width: 100)
                    .blur(radius: move.state.blurRadius)
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
                        case .initial, .unselected:
                            EmptyView()
                        }
                    }
            }
        }
    }
}

#Preview {
    DefensesView(defenses: defaultAllDashDefenses, selectionHandler: { _ in })
}
