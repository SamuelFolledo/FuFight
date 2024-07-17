//
//  MainAlertModifier.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/21/24.
//

import SwiftUI

struct MainAlertModifier {

    // MARK: - Value
    // MARK: Private
    @Binding private var isPresented: Bool

    // MARK: Private
    private let title: String
    private let message: String
    private let dismissButton: AppButton?
    private let primaryButton: AppButton?
    private let secondaryButton: AppButton?
    ///Show a TextField if this is not nil
    var fieldType: FieldType? = nil
    @Binding var text: String
}


extension MainAlertModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                Group {
                    if let fieldType {
                        GameAlert(withText: $text, fieldType: fieldType, title: title, primaryButton: primaryButton, secondaryButton: secondaryButton)
                    } else {
                        GameAlert(title: title, message: message, dismissButton: dismissButton, primaryButton: primaryButton, secondaryButton: secondaryButton)
                    }
                }
                    .presentationBackground(.clear)
            }
    }
}

extension MainAlertModifier {

    init(title: String = "", message: String = "", dismissButton: AppButton, isPresented: Binding<Bool>) {
        self.title         = title
        self.message       = message
        self.dismissButton = dismissButton
        self.primaryButton   = nil
        self.secondaryButton = nil
        _isPresented = isPresented
        _text = .constant("")
    }

    init(title: String = "", message: String = "", primaryButton: AppButton, secondaryButton: AppButton, isPresented: Binding<Bool>) {
        self.title           = title
        self.message         = message
        self.primaryButton   = primaryButton
        self.secondaryButton = secondaryButton
        self.dismissButton = nil
        _isPresented = isPresented
        _text = .constant("")
    }

    ///Initializer for primary button only alert
    init(title: String = "", message: String = "", primaryButton: AppButton, isPresented: Binding<Bool>) {
        self.title         = title
        self.message       = message
        self.dismissButton = nil
        self.primaryButton   = primaryButton
        self.secondaryButton = nil
        _isPresented = isPresented
        _text = .constant("")
    }

    ///Initializer for alerts with a TextField
    init(withText text: Binding<String>, fieldType: FieldType, title: String, primaryButton: AppButton?, secondaryButton: AppButton?, isPresented: Binding<Bool>) {
        self.fieldType = fieldType
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        self.dismissButton = nil
        self.title = title
        self.message = ""
        _text = text
        _isPresented = isPresented
    }
}
