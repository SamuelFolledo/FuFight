//
//  HomeButtonType.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/11/24.
//

import SwiftUI

struct PopoverButton<PopOverContent: View>: View {
    let type: HomeButtonType
    @Binding private var showPopover: Bool
    let popOverContent: PopOverContent

    init(type: HomeButtonType, showPopover: Binding<Bool> = .constant(false), @ViewBuilder popOverContent: () -> PopOverContent) {
        self.type = type
        self._showPopover = showPopover
        self.popOverContent = popOverContent()
    }

    var body: some View {
        Button(action: {
            showPopover.toggle()
        }, label: {
            type.image
        })
        .popover(isPresented: $showPopover) {
            popOverContent
                .presentationCompactAdaptation(.popover)
        }
    }
}

enum HomeButtonType: String, CaseIterable {
    case rewards, inbox, profile, settings
    case promotions, tasks, chests
    case leaderboards, friendPicker

    var imageName: String {
        switch self {
        case .rewards:
            "gift.circle"
        case .inbox:
            "message.circle"
        case .profile:
            "person.circle"
        case .settings:
            "gearshape.circle"
        case .promotions:
            //TODO: Turn into promo
            "hourglass.badge.plus"
        case .tasks:
            "list.clipboard.fill"
        case .chests:
            //TODO: Turn into chest
            "app.gift.fill"
        case .leaderboards:
            "list.bullet.rectangle.portrait.fill"
        case .friendPicker:
            "person.2.fill"
        }
    }

    var image: some View {
        Group {
            switch self {
            case .rewards, .inbox, .profile, .settings:
                Image(systemName: imageName)
                    .defaultImageModifier()
            case .promotions, .tasks, .chests:
                Image(systemName: imageName)
                    .defaultImageModifier()
            case .leaderboards:
                Image(systemName: imageName)
                    .defaultImageModifier()
            case .friendPicker:
                Image(systemName: imageName)
                    .defaultImageModifier()
            }
        }
        .foregroundStyle(position == .topTrailing ? Color.white : Color.black)
        .padding(position == .topTrailing ? 4 : 16)
    }

    var position: Position {
        switch self {
        case .rewards, .inbox, .profile, .settings:
                .topTrailing
        case .promotions, .tasks, .chests:
                .leading
        case .leaderboards, .friendPicker:
                .trailing
        }
    }
}

extension HomeButtonType: Hashable, Identifiable {
    var id: String { rawValue }

    static func == (lhs: HomeButtonType, rhs: HomeButtonType) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}

extension HomeButtonType {
    enum Position {
        case leading
        case trailing
        case topTrailing

        var edge: Edge {
            switch self {
            case .leading:
                    .leading
            case .trailing:
                    .trailing
            case .topTrailing:
                    .top
            }
        }
        var edgeSet: Edge.Set {
            switch self {
            case .leading:
                    .leading
            case .trailing:
                    .trailing
            case .topTrailing:
                    .top
            }
        }
    }
}
