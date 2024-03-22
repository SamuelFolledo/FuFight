//
//  FighterView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/21/24.
//

import SwiftUI

struct FighterView: View {
    var fighter: Fighter = Fighter()

    var body: some View {
        VStack {
            GIFView(type: URLType.name(fighter.idleImageName))
        }
    }
}

#Preview {
    return VStack(spacing: 20) {
        FighterView()
    }
}
