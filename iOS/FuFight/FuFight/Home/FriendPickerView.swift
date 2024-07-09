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

    var body: some View {
        VStack {
            Picker("", selection: $selectedTab) {
                Text("Following").tag(0)
                Text("Recent").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())

            switch selectedTab {
            case 0:
                FriendListView(friends: followingFriends)
            case 1:
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
        ScrollView() {
            ScrollViewReader { value in
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
                                    Text(friend.username)
                                        .font(characterDetailFont)
                                        .foregroundStyle(Color.white)

                                    switch friend.status {
                                    case .offline:
                                        Text(friend.description)
                                            .font(characterDetailFont)
                                            .foregroundStyle(Color.systemGray)
                                    case .online:
                                        Text(friend.description)
                                            .font(characterDetailFont)
                                            .foregroundStyle(friend.statusDetail.isEmpty ? Color.green : Color.orange)
                                    }
                                }

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
            .background {
                Color.black
                    .opacity(0.8)
            }
        }
    }
}

#Preview {
    FriendPickerView()
}
