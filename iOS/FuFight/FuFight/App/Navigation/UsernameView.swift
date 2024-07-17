//
//  UsernameView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/7/24.
//

import SwiftUI

struct UsernameView: View {
    let photoUrl: URL?
    let onImageTap: (() -> Void)?
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
            onImageTap?()
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
        AppText("\(Account.current?.displayName ?? "username")", type: .navMedium)
            .padding(.leading)
    }
}

#Preview {
    UsernameView(photoUrl: fakePhotoUrl, onImageTap: nil)
        .frame(height: 100)
        .background { Color.black }
}

