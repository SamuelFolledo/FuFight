//
//  FriendPickerView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/9/24.
//

import SwiftUI

struct FriendPickerView: View {
    @State private var selectedTab: Int = 0
    private let followingFriends: [Friend] = fakeFriends
    private let recentFriends: [Friend] = fakeFriends
    private let clubFriends: [Friend] = fakeFriends

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                AppText("Following", type: .titleSmall)
                    .tag(0)
                AppText("Recent", type: .titleSmall)
                    .tag(1)
                AppText("Club", type: .titleSmall)
                    .tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())

            switch selectedTab {
            case 0:
                FriendListView(friends: followingFriends)
            case 1:
                FriendListView(friends: recentFriends)
            case 2:
                FriendListView(friends: recentFriends)
            default:
                EmptyView()
            }
        }
    }
}

struct FriendListView: View {

    let friends: [Friend]
    private let imageHeight: CGFloat = 30

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ForEach(friends, id: \.username) { friend in
                    Button {
                        TODO("Implement following list for \(friend.username)")
                    } label: {
                        HStack {
                            accountBackgroundImage
                                .overlay {
                                    if let photoUrl = friend.photoUrl {
                                        AccountImage(url: photoUrl, radius: imageHeight)
                                    } else {
                                        Image(uiImage: defaultProfilePhoto)
                                            .defaultImageModifier()
                                    }
                                }
                                .overlay(alignment: .bottomTrailing) {
                                    RoundedExperienceBarView()
                                }

                            VStack(alignment: .leading) {
                                AppText(friend.username, type: .textSmall)
                                
                                AppText(friend.statusDescription, color: friend.status.color)
                            }
                            .minimumScaleFactor(0.4)

                            Spacer()

                            Button {
                                TODO("Implement challenging \(friend.username)")
                            } label: {
                                Image(systemName: "hand.wave")
                                    .padding(4)
                            }
                        }

                    }
                    .frame(height: 2.0.squareRoot() * imageHeight)
                    .padding(.leading, 8)
                }
            }
        }
    }
}

#Preview {
    FriendPickerView()
}
