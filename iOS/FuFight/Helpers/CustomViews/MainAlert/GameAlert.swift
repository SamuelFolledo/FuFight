//
//  GameAlert.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/16/24.
//

import Foundation

import SwiftUI

struct GameAlert: View {

    // MARK: - Value
    // MARK: Public
    let title: String
    let message: String
    let dismissButton: GameButton?
    let primaryButton: GameButton?
    let secondaryButton: GameButton?
    ///Show a TextField if this is not nil
//    let fieldType: FieldType?
//    @Binding var text: String
//    @State var isFieldSecure: Bool = false

    // MARK: Private
    @State private var opacity: CGFloat           = 0
    @State private var backgroundOpacity: CGFloat = 0
    @State private var scale: CGFloat             = 0.001
    private let alertWidth: CGFloat = 360
    private let verticalPadding: CGFloat = 4
    private let horizontalPadding: CGFloat = 12
    private let buttonMultiplier: CGFloat = 0.3
    private var isManyText: Bool {
        message.count > 120
    }

    @Environment(\.dismiss) private var dismiss

    ///Default initializer
    init(title: String, message: String, dismissButton: GameButton?, primaryButton: GameButton?, secondaryButton: GameButton?) {
        self.title = title
        self.message = message
        self.dismissButton = dismissButton
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
//        fieldType = nil
//        _text = .constant("")
    }

    ///Initializer for alerts with a TextField
    init(withText text: Binding<String>, fieldType: FieldType, title: String, primaryButton: GameButton?, secondaryButton: GameButton?) {
//        self.fieldType = fieldType
        self.title = title
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
//        _text = text
        self.message = ""
        self.dismissButton = nil
    }

    // MARK: - View
    // MARK: Public
    var body: some View {
        GeometryReader { reader in
            ZStack {
                dimView

                alertView(reader)
            }
            .ignoresSafeArea()
            .transition(.opacity)
            .task {
                animate(isShown: true)
            }
        }
//        .onAppear {
//            if let fieldType {
//                isFieldSecure = fieldType.isSensitive
//            }
//        }
    }

    // MARK: Private
    @ViewBuilder func alertView(_ reader: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            alertTitleBackgroundImage
                .overlay {
                    titleView
                        .padding(.horizontal, horizontalPadding)
                        .padding(.vertical, verticalPadding)
                }

            alertBodyBackgroundImage
                .overlay {
                    VStack(spacing: 0) {
                        messageView
                            .padding(.horizontal, horizontalPadding)

                        if !isManyText {
                            Spacer()
                        }

                        buttonsView(reader)
                    }
                    .padding(.top, verticalPadding * 2.5)
                }
        }
        .padding([.horizontal], 24)
        .padding(.bottom, verticalPadding)
        .frame(width: alertWidth)
        .frame(maxHeight: .infinity)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.4), radius: 16, x: 0, y: 12)
        .scaleEffect(scale)
        .opacity(opacity)
    }

    @ViewBuilder
    private var titleView: some View {
        if !title.isEmpty {
            Text(title)
                .font(smallTitleFont)
                .foregroundColor(Color.white)
//                .lineSpacing(24 - UIFont.systemFont(ofSize: 18, weight: .bold).lineHeight)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    @ViewBuilder private var messageView: some View {
//        if let fieldType {
//            UnderlinedTextField(type: .constant(fieldType), text: $text, isSecure: $isFieldSecure, showTitle: false)
//                .onSubmit {
//                    primaryButtonAction()
//                }
//        } else
        if !message.isEmpty {
            if isManyText {
                ScrollView(.vertical, showsIndicators: false) {
                    messageLabel
                }
            } else {
                messageLabel
            }
        }
    }

    @ViewBuilder private var messageLabel: some View {
        Text(message)
            .font(textFont)
            .foregroundColor(Color.white)
        //            .lineSpacing(24 - UIFont.systemFont(ofSize: title.isEmpty ? 18 : 16).lineHeight)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.3)
    }

    func buttonsView(_ reader: GeometryProxy) -> some View {
        HStack(spacing: 16) {
            if dismissButton != nil {
                dismissButtonView(reader)
            } else if primaryButton != nil, secondaryButton != nil {
                secondaryButtonView(reader)

                primaryButtonView(reader)
            } else if primaryButton != nil {
                primaryButtonView(reader)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom)
    }

    func primaryButtonAction() {
        if let primaryButton {
            animate(isShown: false) {
                dismiss()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                primaryButton.action?()
            }
        }
    }

    @ViewBuilder private func primaryButtonView(_ reader: GeometryProxy) -> some View {
        if let primaryButton {
            if primaryButton.type == .custom {
                GameButton(title: primaryButton.title, maxWidth: reader.size.width * buttonMultiplier, action: primaryButtonAction)
            } else {
                GameButton(type: primaryButton.type, maxWidth: reader.size.width * buttonMultiplier, action: primaryButtonAction)
            }
        }
    }

    @ViewBuilder private func secondaryButtonView(_ reader: GeometryProxy) -> some View {
        if let button = secondaryButton {
            let buttonAction = {
                animate(isShown: false) {
                    dismiss()
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    button.action?()
                }
            }
            if button.type == .custom {
                GameButton(title: button.title, maxWidth: reader.size.width * buttonMultiplier, action: buttonAction)
            } else {
                GameButton(type: button.type, maxWidth: reader.size.width * buttonMultiplier, action: buttonAction)
            }
        }
    }

    @ViewBuilder private func dismissButtonView(_ reader: GeometryProxy) -> some View {
        if let button = dismissButton {
            let buttonAction = {
                animate(isShown: false) {
                    dismiss()
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    button.action?()
                }
            }
            if button.type == .custom {
                GameButton(title: button.title, maxWidth: reader.size.width * buttonMultiplier, action: buttonAction)
            } else {
                GameButton(type: button.type, maxWidth: reader.size.width * buttonMultiplier, action: buttonAction)
            }
        }
    }

    private var dimView: some View {
        Color.systemGray
            .opacity(0.55)
            .opacity(backgroundOpacity)
            .onTapGesture {
                animate(isShown: false) {
                    dismiss()
                }
            }
    }


    // MARK: - Function
    // MARK: Private
    private func animate(isShown: Bool, completion: (() -> Void)? = nil) {
        switch isShown {
        case true:
            opacity = 1

            withAnimation(.spring(response: 0.3, dampingFraction: 0.9, blendDuration: 0).delay(0.5)) {
                backgroundOpacity = 1
                scale             = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion?()
            }

        case false:
            withAnimation(.easeOut(duration: 0.2)) {
                backgroundOpacity = 0
                opacity           = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                completion?()
            }
        }
    }
}

#if DEBUG
struct GameAlert_Previews: PreviewProvider {

    static var previews: some View {
        let showType: Bool = true

        let dismissButton   = GameButton(title: "Ok")
        let primaryButton   = GameButton(title: "Ok")
        let secondaryButton = GameButton(title: "Cancel")

        let dismissButton2   = GameButton(type: .dismiss)
        let primaryButton2   = GameButton(type: .delete)
        let secondaryButton2 = GameButton(type: .secondaryOk)

        let title = "Error connecting game to the server"
        let message = """
                    If you don't like something, change it again and again.
                    If you don't like your job, quit.
                    If you don't have enough time, stop watching TV.
                    If you don't have enough time, stop watching TV.
                    """
        let message2 = """
                    If you don't like something, change it again and again. If you don't like your job, quit.
                    """

        return VStack {
            if showType {
                GameAlert(title: title, message: message, dismissButton: dismissButton2, primaryButton: nil,            secondaryButton: nil)
                GameAlert(title: title, message: message2, dismissButton: nil,           primaryButton: secondaryButton2, secondaryButton: primaryButton2)
            } else {
                GameAlert(title: title, message: message, dismissButton: nil,           primaryButton: nil,           secondaryButton: nil)
                GameAlert(title: title, message: message2, dismissButton: dismissButton, primaryButton: nil,          secondaryButton: nil)
                GameAlert(title: title, message: message, dismissButton: nil,           primaryButton: primaryButton, secondaryButton: secondaryButton)
            }
        }
        .previewDevice("iPhone 13 Pro Max")
        .preferredColorScheme(.light)
    }
}
#endif
