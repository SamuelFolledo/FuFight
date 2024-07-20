//
//  PlayerDetailView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/19/24.
//

import SwiftUI

struct PlayerDetailView: View {
    @Binding var isShowing: Bool

    var body: some View {
        VStack(spacing: 4) {
            AppText("Username: \(Room.current?.player.username ?? "")", type: .textMedium)

            Spacer()
                .frame(height: 20)

            AppText("Experience: TODO/TODO", type: .textMedium)

            AppText("Ratings: TODO", type: .textMedium)

            AppText("Game Stats: TODO", type: .textMedium)

            AppText("Game History: TODO", type: .textMedium)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension PlayerDetailView {
    func shouldShow(_ show: Bool) {
        withAnimation {
            isShowing = show
        }
    }
}

#Preview {
    return VStack(spacing: 20) {
        PlayerDetailView(isShowing: .constant(true))
    }
}
