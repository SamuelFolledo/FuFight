//
//  UsernameView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/7/24.
//

import SwiftUI

struct UsernameView: View {
    let photoUrl: URL?
    private let imageHeight: CGFloat = 38

    var body: some View {
        HStack(spacing: 0) {
            userImage
                .padding(.vertical, -5)

            usernameLabel

            Spacer()
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity)
    }

    var userImage: some View {
        Button {
            TODO("Go to user's profile")
        } label: {
            accountBackgroundImage
                .overlay {
                    if let photoUrl {
                        AccountImage(url: photoUrl, radius: imageHeight)
                    } else {
                        Image(uiImage: defaultProfilePhoto)
                            .defaultImageModifier()
                            .frame(height: imageHeight)
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    RoundedExperienceBarView()
                }
        }
    }

    var usernameLabel: some View {
        Text("\(Account.current?.displayName ?? "username")")
            .font(usernameFont)
            .foregroundStyle(.white)
            .padding(.leading)
    }
}

#Preview {
    UsernameView(photoUrl: fakePhotoUrl)
        .frame(height: 100)
        .background { Color.black }
}

