//
//  DefensesView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

struct DefensesView: View {
    var body: some View {
        HStack(alignment: .bottom) {
            MoveButton(move: Dash.left)
                .frame(width: 100)

            VStack {
                MoveButton(move: Dash.forward)
                    .frame(width: 100)

                MoveButton(move: Dash.backward)
                    .frame(width: 100)
            }

            MoveButton(move: Dash.right)
                .frame(width: 100)
        }
    }
}

#Preview {
    DefensesView()
}
