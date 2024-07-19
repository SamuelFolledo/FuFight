//
//  PlayerDetailView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/19/24.
//

import SwiftUI

struct PlayerDetailView: View {
    @Binding var isShowing: Bool

    private let alertWidth: CGFloat = 360
    private let verticalPadding: CGFloat = 4
    private let horizontalPadding: CGFloat = 12

    var body: some View {
        GeometryReader { reader in
            alertView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    Color.clear
                }
        }
    }

    @ViewBuilder func alertView() -> some View {
        VStack(spacing: 0) {
            alertTitleBackgroundImage
                .overlay {
                    titleView
                }

            alertBodyBackgroundImage
                .frame(maxWidth: .infinity)
                .overlay {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 4) {
                            AppText("Username: \(Room.current?.player.username ?? "")", type: .textMedium)

                            Spacer()
                                .frame(height: 20)

                            AppText("Experience: TODO/TODO", type: .textMedium)

                            AppText("Ratings: TODO", type: .textMedium)

                            AppText("Game Stats: TODO", type: .textMedium)

                            AppText("Game History: TODO", type: .textMedium)
                        }
                        .padding(.top, verticalPadding * 2.5)
                        .padding(.bottom, 50)
                    }
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .bottom) {
                        okayButton
                    }
                }
        }
    }

    @ViewBuilder private var titleView: some View {
        AppText("Player's Detail", type: .navMedium)
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
    }

    @ViewBuilder private var okayButton: some View {
        AppButton(title: "Okay", color: .main, maxWidth: navBarButtonMaxWidth * 1.5) {
            shouldShow(false)
        }
        .padding(.bottom)
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
