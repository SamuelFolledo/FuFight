//
//  GameButton.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/16/24.
//

import SwiftUI

enum GameButtonType {
    case cancel, secondaryCancel, ok, secondaryOk, custom, secondaryCustom, delete, dismiss

    var title: String {
        switch self {
        case .cancel, .secondaryCancel:
            "Cancel"
        case .delete:
            "Delete"
        case .ok, .secondaryOk:
            "Ok"
        case .custom, .secondaryCustom:
            ""
        case .dismiss:
            "Dismiss"
        }
    }

    @ViewBuilder var background: some View {
        switch self {
        case .cancel:
            yellowButtonImage
        case .secondaryCancel:
            blueButtonImage
        case .ok:
            yellowButtonImage
        case .secondaryOk:
            blueButtonImage
        case .custom:
            yellowButtonImage
        case .secondaryCustom:
            blueButtonImage
        case .delete:
            redButtonImage
        case .dismiss:
            blueButtonImage
        }
    }

    var bgColor: UIColor {
        switch self {
        case .cancel, .secondaryCancel:
            backgroundUiColor
        case .delete:
            destructiveUiColor
        case .ok, .secondaryOk:
            backgroundUiColor
        case .custom, .secondaryCustom:
            backgroundUiColor
        case .dismiss:
            backgroundUiColor
        }
    }

    var textColor: UIColor {
        .white
    }
}

struct GameButton: View {
    // MARK: Public
    var type: GameButtonType
    let title: String
    let textColor: UIColor
    let bgColor: UIColor
    var action: (() -> Void)? = nil
    private let cornerRadius: CGFloat = 25

    init(title: String, textColor: UIColor = .white, type: GameButtonType = .custom, action: (() -> Void)? = nil) {
        self.title = title
        self.textColor = textColor
        self.bgColor = .systemBackground
        self.action = action
        self.type = type
    }

    init(type: GameButtonType, action: (() -> Void)? = nil) {
        self.type = type
        self.title = type.title
        self.textColor = type.textColor
        self.bgColor = type.bgColor
        self.action = action
    }

    // MARK: - View
    // MARK: Public
    var body: some View {
        Button {
            action?()
        } label: {
            Text(title)
                .font(mediumTextFont)
                .foregroundColor(Color(uiColor: textColor))
                .frame(maxWidth: .infinity, maxHeight: 45)
                .padding(.horizontal, 20)
        }
        .background(
            type.background
        )
    }
}

struct GameButton_Previews: PreviewProvider {

    static var previews: some View {
        let dismissButton   = GameButton(title: "Ok")
        let primaryButton   = GameButton(title: "Ok")
        let secondaryButton = GameButton(title: "Cancel")

        let dismissButton2   = GameButton(type: .cancel)
        let primaryButton2   = GameButton(type: .delete)
        let secondaryButton2 = GameButton(type: .ok)

        return VStack(spacing: 100) {
            dismissButton
            primaryButton
            secondaryButton

            dismissButton2
            primaryButton2
            secondaryButton2
        }
        .padding(.horizontal, 50)
        .preferredColorScheme(.dark)
    }
}
