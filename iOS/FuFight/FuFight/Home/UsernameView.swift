//
//  UsernameView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/7/24.
//

import SwiftUI

struct UsernameView: View {
    var experience: CGFloat = 20
    var experienceNeeded: CGFloat = 250
    private let expBarHeight: CGFloat = 10
    private let levelWidth: CGFloat = 25

    var body: some View {
        HStack(spacing: 5) {
            userImage
                .padding(-5)

            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: -2) {
                    Color.clear
                        .frame(width: levelWidth)

                    expBarView
                        .overlay(alignment: .leading) {
                            //Overlay the level on the left of expBar
                            levelView
                                .padding(.leading, -levelWidth + 3)
                                .frame(height: levelWidth)
                        }
                }

                usernameLabel
            }

            Spacer()
        }
        .padding(4)
        .background {
            Color.clear
        }
        .frame(maxWidth: .infinity)
        //        .allowsHitTesting(vm.loadingMessage == nil)
    }

    var userImage: some View {
        Button {
            TODO("Go to user's profile")
        } label: {
            accountBackgroundImage
                .overlay {
                    AccountImage(url: Room.current?.player.photoUrl, radius: 30)
                }
        }
    }

    var expBarView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: expBarHeight)
                    .opacity(0.7)
                    .foregroundColor(.gray)

                Rectangle()
                    .frame(width: self.calculateBarWidth(geometry: geometry), height: expBarHeight)
                    .foregroundColor(self.calculateBarColor())
            }
            .overlay {
                Text("154 / 300")
                    .font(mediumTextFont)
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.3)
            }
        }

                    .frame(height: expBarHeight)
    }

    var levelView: some View {
        yellowRingImage
            .background {
                Color.gray
                    .clipShape(Circle())
                    .padding(3)
            }
            .overlay {
                Text("24")
                    .font(characterDetailFont)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
                    .minimumScaleFactor(0.3)
            }
            .frame(width: levelWidth)
    }

    var usernameLabel: some View {
        Text("\(Account.current?.displayName ?? "username")")
            .font(usernameFont)
            .foregroundStyle(.white)
    }

    /// Calculate the width of the bar based on current hit points
    private func calculateBarWidth(geometry: GeometryProxy) -> CGFloat {
        let percent = CGFloat(experience / experienceNeeded)
        return geometry.size.width * percent
    }

    /// Calculate the color of the bar based on current hit points
    private func calculateBarColor() -> Color {
//        let percent: CGFloat = experience / experienceNeeded
//        if percent > 0.5 {
//            return .green
//        } else if percent > 0.2 {
//            return .yellow
//        } else {
//            return .red
//        }
        .green
    }
}

#Preview {
    UsernameView()
        .frame(height: 100)
        .background { Color.black }
}

