//
//  NavBar.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/9/24.
//

import SwiftUI

struct NavBar: View {

    var usernameViewTap: (() -> Void)?

    var body: some View {
        VStack {
            statusBarView

            HStack {
                UsernameView(photoUrl: Room.current?.player.photoUrl) {
                    usernameViewTap?()
                }

                Spacer()

                HStack(spacing: 12) {
                    coinsView

                    diamondsView
                }
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }
            .padding(.bottom, 4)
            .padding(.horizontal, 8)
        }
        .frame(height: homeNavBarHeight)
        .frame(maxWidth: .infinity)
        .transition(.move(edge: .top))
        .background {
            navBarBackgroundImage
        }
    }

    var statusBarView: some View {
        Color.black
            .frame(height: UserDefaults.topSafeAreaInset)
            .frame(maxWidth: .infinity)
            .mask(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .bottom, endPoint: .top))
    }

    var coinsView: some View {
        Button(action: {
            TODO("Buying more coins")
        }, label: {
            HStack(spacing: 2) {
                coinImage
                    .padding(.leading, -8)
                    .frame(width: navBarIconSize, height: navBarIconSize, alignment: .center)

                AppText("812999", type: .navSmall)
                    .padding(.leading, -4)

                Spacer()
            }
        })
        .background {
            navBarContainerImage
        }
    }

    var diamondsView: some View {
        Button(action: {
            TODO("Buy diamonds")
        }, label: {
            HStack(spacing: 2) {
                diamondImage
                    .padding(.leading, -16)
                    .frame(width: navBarIconSize, height: navBarIconSize)

                AppText("209", type: .navSmall)
                    .padding(.leading, -4)

                Spacer()
            }
        })
        .background {
            navBarContainerImage
        }
    }
}

#Preview {
    NavBar()
        .frame(height: 100)
        .background { Color.black }
}

