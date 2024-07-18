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
    case leading1
    case leading2
    case leading3
    case accountDetail
    case trailing2
    case friendPicker

    var imageName: String {
        switch self {
        case .leading1, .leading2, .leading3:
            "coin"
        case .accountDetail:
            "person.fill"
        case .trailing2:
            "diamond"
        case .friendPicker:
            "person.2.fill"
        }
    }

    var image: some View {
        Group {
            switch self {
            case .leading1, .leading2, .leading3, .trailing2:
                Image(imageName)
                    .defaultImageModifier()
                    .frame(width: 40, height: 50)
            case .accountDetail:
                Image(systemName: imageName)
                    .defaultImageModifier()
                    .frame(width: 30, height: 40)
                    .padding(.horizontal, 5)
            case .friendPicker:
                Image(systemName: imageName)
                    .defaultImageModifier()
                    .frame(width: 40, height: 40)
            }
        }
        .foregroundStyle(Color.white)
        .padding(4)
    }

    var position: Position {
        switch self {
        case .leading1, .leading2, .leading3:
                .leading
        case .accountDetail, .trailing2, .friendPicker:
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

        var edge: Edge {
            switch self {
            case .leading:
                    .leading
            case .trailing:
                    .trailing
            }
        }
        var edgeSet: Edge.Set {
            switch self {
            case .leading:
                    .leading
            case .trailing:
                    .trailing
            }
        }
    }
}
