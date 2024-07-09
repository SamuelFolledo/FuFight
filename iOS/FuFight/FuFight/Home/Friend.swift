//
//  Friend.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/9/24.
//

import Foundation

let fakeFriends: [Friend] = [.init(username: "fakeUsername0", status: .online, statusDetail: "", photoUrl: fakePhotoUrl),
                             .init(username: "fakeUsername1", status: .online, statusDetail: "In-Game", photoUrl: fakePhotoUrl),
                             .init(username: "fakeUsername2", status: .offline, statusDetail: "7 minute(s)", photoUrl: fakePhotoUrl),
                             .init(username: "fakeUsername3", status: .offline, statusDetail: "11 hour(s)", photoUrl: fakePhotoUrl),
                             .init(username: "fakeUsername4", status: .offline, statusDetail: "2 day(s)", photoUrl: fakePhotoUrl),
                             .init(username: "fakeUsername5", status: .offline, statusDetail: "7+ days", photoUrl: fakePhotoUrl),
]

struct Friend {
    enum Status {
        case online
        case offline
    }

    var username: String
    var status: Status
    var statusDetail: String
    var photoUrl: URL?

    var description: String {
        switch status {
        case .online:
            statusDetail.isEmpty ? "Online" : statusDetail
        case .offline:
            statusDetail
        }
    }
}
