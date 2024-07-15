//
//  AppButtonModifier.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/23/24.
//

import SwiftUI

enum ViewType {
    case primary
    case secondary
    case tertiary
    case system
    ///Button that will not have borders
    case destructive

    var color: UIColor {
        switch self {
        case .primary:
            return primaryUiColor
        case .secondary:
            return secondaryUiColor
        case .tertiary:
            return .clear
        case .system:
            return systemUiColor
        case .destructive:
            return destructiveUiColor
        }
    }
}

extension View {
    ///Create an app's button
    func appButton(_ type: ViewType, isBordered: Bool = false, hasPadding: Bool = true) -> some View {
        self.modifier(AppButtonModifier(viewType: type, isBordered: isBordered, hasPadding: hasPadding))
    }
}

struct AppButtonModifier: ViewModifier {
    var viewType: ViewType
    var isBordered: Bool
    var hasPadding: Bool

    let disabledColor: UIColor = .systemGray
    @Environment(\.isEnabled) private var isEnabled: Bool

    func body(content: Content) -> some View {
        content
            .font(buttonFont)
            .padding(.vertical, hasPadding ? 8 : 0)
            .padding(.horizontal, hasPadding ? 8 : 0)
            .background(background)
            .foregroundColor(Color(uiColor: foregroundColor))
        //TODO: Figure out if needed. Previous implementation before images
//            .cornerRadius(24)
//            .overlay(
//                RoundedRectangle(cornerRadius: 24)
//                    .stroke(
//                        Color(uiColor: isEnabled ? viewType.color : disabledColor),
//                        lineWidth: 2)
//            )
            .opacity(isEnabled ? 1 : 0.8)
    }

    var background: some View {
        Group {
            switch viewType {
            case .primary:
                yellowButtonImage
            case .secondary:
                blueButtonImage
            case .tertiary:
                yellowButtonImage
            case .system:
                greenButtonImage
            case .destructive:
                redButtonImage
            }

            //TODO: Figure out if needed. Previous implementation before images
//            if isEnabled {
//                Color(uiColor: isBordered ? .white : viewType.color)
//            } else {
//                Color(uiColor: isBordered ? .clear : disabledColor)
//            }
        }
    }
    var foregroundColor: UIColor {
        switch viewType {
        case .primary, .secondary, .system:
            isEnabled ? (isBordered ? viewType.color : backgroundUiColor) : (isBordered ? .clear : backgroundUiColor)
        case .tertiary:
            primaryUiColor
        case .destructive:
            isBordered ? .black : UIColor.white
        }
    }
}

#Preview {
    VStack {
        Button("Primary", action: {})
            .appButton(.primary)

        Button("Primary Bordered", action: {})
            .appButton(.primary, isBordered: true)

        Button("Secondary", action: {})
            .appButton(.secondary)

        Button("Secondary", action: {})
            .appButton(.secondary, isBordered: true)

        Button("Tertiary", action: {})
            .appButton(.tertiary)

        Button("Tertiary Bordered", action: {})
            .appButton(.tertiary, isBordered: true)

        Button("System", action: {})
            .appButton(.system)

        Button("System", action: {})
            .appButton(.system, isBordered: true)

        Button("Destructive", action: {})
            .appButton(.destructive)

        Button("Destructive Bordered", action: {})
            .appButton(.destructive, isBordered: true)

        Button("Primary Disabled", action: {})
            .appButton(.primary)
            .disabled(true)
        Button("Destructive Disabled", action: {})
            .appButton(.destructive)
            .disabled(true)
    }
    .preferredColorScheme(.light)
}
