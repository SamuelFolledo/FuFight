//
//  NavBar.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/9/24.
//

import SwiftUI

struct NavBar: View {

    var body: some View {
        VStack {
            statusBarView

            HStack {
                UsernameView(photoUrl: Room.current?.player.photoUrl)

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
                    .frame(width: navBarIconSize, height: navBarIconSize, alignment: .center)

                Text("812999")
                    .font(navBarFont)
                    .foregroundStyle(Color.white)

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
                    .frame(width: navBarIconSize, height: navBarIconSize, alignment: .center)

                Text("209")
                    .font(navBarFont)
                    .foregroundStyle(Color.white)
                    .frame(alignment: .center)

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

