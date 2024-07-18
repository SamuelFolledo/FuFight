//
//  AppButton.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/16/24.
//

import SwiftUI

enum AppButtonType {
    case cancel
    case secondaryCancel
    case ok
    case secondaryOk
    case custom
    case secondaryCustom
    case tertiaryCustom
    case greenCustom
    case delete
    case dismiss

    var title: String {
        switch self {
        case .cancel, .secondaryCancel:
            "Cancel"
        case .delete:
            "Delete"
        case .ok, .secondaryOk:
            "Ok"
        case .custom, .secondaryCustom, .tertiaryCustom, .greenCustom:
            ""
        case .dismiss:
            "Dismiss"
        }
    }

    @ViewBuilder var background: some View {
        switch self {
        case .cancel:
            redButtonImage
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
        case .tertiaryCustom:
            redButtonImage
                .saturation(0.0) //make the image black and white
        case .greenCustom:
            greenButtonImage
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
        case .custom, .secondaryCustom, .tertiaryCustom, .greenCustom:
            backgroundUiColor
        case .dismiss:
            backgroundUiColor
        }
    }

    var textColor: UIColor {
        .white
    }

    var isCustom: Bool {
        switch self {
        case .cancel, .secondaryCancel, .ok, .secondaryOk, .delete, .dismiss:
            false
        case .custom, .secondaryCustom, .tertiaryCustom, .greenCustom:
            true
        }
    }
}

struct AppButton: View {
    // MARK: Public
    var type: AppButtonType
    let title: String
    let textType: TextType
    let textColor: UIColor
    let bgColor: UIColor
    let minWidth: CGFloat?
    let maxWidth: CGFloat
    var action: (() -> Void)? = nil
    private let cornerRadius: CGFloat = 25

    init(title: String, textColor: UIColor = .white, type: AppButtonType = .custom, textType: TextType = .buttonMedium, minWidth: CGFloat? = nil, maxWidth: CGFloat = .infinity, action: (() -> Void)? = nil) {
        self.title = title
        self.textColor = textColor
        self.bgColor = .systemBackground
        self.action = action
        self.type = type
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.textType = textType
    }

    init(type: AppButtonType, textType: TextType = .buttonMedium, minWidth: CGFloat? = nil, maxWidth: CGFloat = .infinity, action: (() -> Void)? = nil) {
        self.type = type
        self.title = type.title
        self.textColor = type.textColor
        self.bgColor = type.bgColor
        self.action = action
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.textType = textType
    }

    // MARK: - View
    // MARK: Public
    var body: some View {
        Button {
            action?()
        } label: {
            AppText(title, type: textType)
                .frame(minWidth: minWidth, maxWidth: maxWidth)
                .padding(.horizontal, 25)
        }
        .background(
            type.background
        )
    }
}

struct AppButton_Previews: PreviewProvider {

    static var previews: some View {
        let dismissButton   = AppButton(title: "Ok")
        let primaryButton   = AppButton(title: "Ok")
        let secondaryButton = AppButton(title: "Cancel")

        let dismissButton2   = AppButton(type: .cancel)
        let primaryButton2   = AppButton(type: .delete)
        let secondaryButton2 = AppButton(type: .ok)

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
