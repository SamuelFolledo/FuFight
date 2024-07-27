//
//  PopupView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/18/24.
//

import SwiftUI

struct PopupView<BodyContent: View>: View {
    @Binding var isShowing: Bool
    let title: String?
    var showOkayButton = true
    let bodyContent: BodyContent?

    private let widthMultiplier: CGFloat = 0.9
    private let verticalPadding: CGFloat = 4
    private let horizontalPadding: CGFloat = 12

    var body: some View {
        GeometryReader { reader in
            ZStack {
                dimViewBackground
                    .onTapGesture {
                        shouldShow(false)
                    }

                VStack(spacing: 0) {
                    alertTitleBackgroundImage
                        .overlay {
                            if let title {
                                AppText(title, type: .navMedium)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .padding(.horizontal, horizontalPadding)
                                    .padding(.vertical, verticalPadding)
                            }
                        }

                    alertBodyBackgroundImage
                        .overlay {
                            if showOkayButton {
                                ScrollView(.vertical, showsIndicators: false) {
                                    bodyContent
                                        .padding(.top, verticalPadding * 2.5)
                                        .padding(.bottom, 50)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                            } else {
                                bodyContent
                                    .padding(.top, verticalPadding * 2.5)
                                    .padding(.bottom, 16)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .overlay(alignment: .bottom) {
                            if showOkayButton {
                                okayButton
                            }
                        }
                }
                .frame(width: reader.size.width * widthMultiplier)
            }
        }
    }

    @ViewBuilder private var okayButton: some View {
        AppButton(title: "Okay", color: .main, maxWidth: navBarButtonMaxWidth * 1.5) {
            shouldShow(false)
        }
        .padding(.bottom)
    }

    private func shouldShow(_ show: Bool) {
        withAnimation {
            isShowing = show
        }
    }
}

#Preview {
    let titleContent =  AppText("Player's Detail", type: .navMedium)
        .multilineTextAlignment(.center)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .padding(.horizontal, 6)
        .padding(.vertical, 10)
    let bodyContent = VStack(spacing: 4) {
        AppText("Username: \(Room.current?.player.username ?? "")", type: .textMedium)

        Spacer()
            .frame(height: 20)

        AppText("Experience: TODO/TODO", type: .textMedium)

        AppText("Ratings: TODO", type: .textMedium)

        AppText("Game Stats: TODO", type: .textMedium)

        AppText("Game History: TODO", type: .textMedium)
    }

    return VStack(spacing: 20) {
        PopupView(isShowing: .constant(true), title: "Text popup", bodyContent: bodyContent)
    }
}
