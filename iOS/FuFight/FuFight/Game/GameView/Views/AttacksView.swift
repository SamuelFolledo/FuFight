//
//  AttacksView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

struct AttacksView: View {
    var body: some View {
        VStack {
            HStack {
                MoveButton(move: Punch.leftPunchLight)
                    .frame(width: 100)

                Spacer()

                MoveButton(move: Punch.rightPunchLight)
                    .frame(width: 100)
            }

            HStack {
                MoveButton(move: Punch.leftPunchMedium)
                    .frame(width: 100)

                Spacer()

                MoveButton(move: Punch.rightPunchMedium)
                    .frame(width: 100)
            }

            HStack {
                MoveButton(move: Punch.leftPunchHard)
                    .frame(width: 100)

                Spacer()

                MoveButton(move: Punch.rightPunchHard)
                    .frame(width: 100)
            }
        }
    }
}

#Preview {
    AttacksView()
}
