//
//  Friend.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/9/24.
//

import SwiftUI

struct Friend {
    enum Status {
        case online
        case offline
        case queue
        case gaming

        var color: Color {
            switch self {
            case .online:
                .green
            case .offline:
                .grayLight
            case .queue:
                .yellow
            case .gaming:
                .orange
            }
        }
    }

    var username: String
    var status: Status
    var lastOnlineDescription: String
    var photoUrl: URL?

    var statusDescription: String {
        switch status {
        case .online:
            "Online"
        case .offline:
            lastOnlineDescription
        case .queue:
            "In Queue"
        case .gaming:
            "In Game"
        }
    }
}
