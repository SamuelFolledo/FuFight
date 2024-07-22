//
//  AppText.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/16/24.
//

import SwiftUI

struct AppText: View {
    let text: String
    let strokeWidth: CGFloat
    let font: Font
    let color: Color

    init(_ text: String, type: TextType) {
        self.init(text, fontSize: type.fontSize, fontWeight: type.fontWeight)
    }

    init(_ coloredText: String, fontSize: CGFloat = defaultFontSize, color: Color) {
        self.init(coloredText, fontSize: fontSize, strokeWidth: fontSize / 80, color: color)
    }

    private init(_ text: String, fontSize: CGFloat = defaultFontSize, fontWeight: CustomFontWeight = .medium, strokeWidth: CGFloat = 0.25, color: Color = .white) {
        self.text = text
        self.strokeWidth = strokeWidth
        self.font = Font.customFont(fontWeight, fontSize)
        self.color = color
    }


    var body: some View {
        Text(text)
            .stroke(color: .blackLight, width: strokeWidth)
            .font(font)
            .foregroundStyle(color)
            .minimumScaleFactor(0.4)
    }
}
