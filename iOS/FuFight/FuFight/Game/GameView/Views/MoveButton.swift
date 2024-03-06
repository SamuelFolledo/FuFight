//
//  MoveButton.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

struct MoveButton: View {
    var move: Move

    var body: some View {
        Button(action: {
            TODO("Handle move \(move.name)")
        }, label: {
            Image(move.imageName)
                .defaultImageModifier()
                .scaledToFit()
                .padding(move.padding)
                .background(
                    Image(move.moveType == .attack ? "moveBackgroundRed" : "moveBackgroundBlue")
                        .backgroundImageModifier()
                        .scaledToFit()
                )
        })
    }
}

#Preview {
    MoveButton(move: Punch.leftPunchLight)
}
