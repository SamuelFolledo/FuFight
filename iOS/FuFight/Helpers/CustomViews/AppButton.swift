//
//  AppButton.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/16/24.
//

import SwiftUI

enum ColorType {
    case main
    case main2
    case main3
    case system
    case system2
    case destructive

    @ViewBuilder var background: some View {
        switch self {
        case .main:
            yellowButtonImage
        case .main2:
            blueButtonImage
        case .main3:
            blueButtonImage
                .saturation(0) //make the image black and white
        case .system:
            blueButtonImage
        case .system2:
            greenButtonImage
        case .destructive:
            redButtonImage
        }
    }
}

enum AppButtonType {
    case cancel
    case secondaryCancel
    case ok
    case secondaryOk
    case custom
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
        case .custom:
            ""
        case .dismiss:
            "Dismiss"
        }
    }

    var color: ColorType {
        switch self {
        case .cancel:
            .destructive
        case .secondaryCancel:
            .system
        case .ok:
            .main
        case .secondaryOk:
            .system
        case .custom:
            .main
        case .delete:
            .destructive
        case .dismiss:
            .main2
        }
    }

    var textColor: UIColor {
        .white
    }

    var isCustom: Bool {
        switch self {
        case .cancel, .secondaryCancel, .ok, .secondaryOk, .delete, .dismiss:
            false
        case .custom:
            true
        }
    }
}

struct AppButton: View {
    // MARK: Public
    let title: String
    var type: AppButtonType
    let textType: TextType
    var color: ColorType
    let textColor: UIColor
    let minWidth: CGFloat?
    let maxWidth: CGFloat
    var action: (() -> Void)? = nil
    
    private let cornerRadius: CGFloat = 25

    init(title: String, color: ColorType = .main, textColor: UIColor = .white, textType: TextType = .buttonMedium, minWidth: CGFloat? = nil, maxWidth: CGFloat = .infinity, action: (() -> Void)? = nil) {
        self.title = title
        self.textColor = textColor
        self.action = action
        self.type = .custom
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.textType = textType
        self.color = color
    }

    init(type: AppButtonType, textType: TextType = .buttonMedium, minWidth: CGFloat? = nil, maxWidth: CGFloat = .infinity, action: (() -> Void)? = nil) {
        self.type = type
        self.color = type.color
        self.title = type.title
        self.textColor = type.textColor
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
            color.background
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
