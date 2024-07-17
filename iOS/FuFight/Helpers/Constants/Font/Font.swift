//
//  FontManager.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/16/24.
//

import UIKit.UIFont
import SwiftUI

//MARK: Enum
enum CustomFontWeight: String {
    case black = "BurbankBigCondensed-Black"
    case bold = "BurbankBigCondensed-Bold"
    case medium = "BurbankBigCondensed-Medium"
//    case light = "BurbankBigCondensed-Light" //too skinny
}

extension Font {

    /// Choose your font to set up
    /// - Parameters:
    ///   - font: Choose one of your font
    ///   - style: Make sure the style is available
    ///   - size: Use prepared sizes for your app
    /// - Returns: Font ready to show
    static func customFont(_ weight: CustomFontWeight, _ size: CGFloat) -> Font {
            return Font.custom(weight.rawValue, size: size)
        }
}

enum TextType {
    case textSmall
    case textMedium
    case textLarge
    case titleSmall
    case titleMedium
    case titleLarge
    
    case buttonSmall
    case buttonMedium
    case buttonLarge

    case tabSmall
    case tabMedium
    case tabLarge

    case navSmall
    case navMedium
    case navLarge

    case alertSmall
    case alertMedium
    case alertLarge

    var fontSize: CGFloat {
        switch self {
        case .textSmall, .buttonSmall:
            defaultFontSize
        case .textMedium, .buttonMedium:
            defaultFontSize + 4
        case .textLarge, .buttonLarge:
            defaultFontSize * 1.875 //16 * 1.875 = 30
        case .titleSmall:
            defaultFontSize * 1.875
        case .titleMedium:
            defaultFontSize * 2.5
        case .titleLarge:
            defaultFontSize * 3.75
        case .tabSmall, .navSmall, .alertSmall:
            defaultFontSize
        case .tabMedium, .navMedium, .alertMedium:
            defaultFontSize * 1.3
        case .tabLarge, .navLarge, .alertLarge:
            defaultFontSize * 2
        }
    }

    var fontWeight: CustomFontWeight {
        switch self {
        case .textSmall, .buttonSmall:
            .bold
        case .textMedium, .buttonMedium:
            .bold
        case .textLarge, .buttonLarge:
            .black
        case .titleSmall:
            .bold
        case .titleMedium:
            .bold
        case .titleLarge:
            .black
        case .tabSmall, .navSmall, .alertSmall:
            .bold
        case .tabMedium, .navMedium, .alertMedium:
            .bold
        case .tabLarge, .navLarge, .alertLarge:
            .black
        }
    }
}

extension View {
    func stroke(color: Color = .black, width: CGFloat = 0.25) -> some View {
        modifier(StrokeModifier(strokeSize: width, strokeColor: color))
    }
}

struct StrokeModifier: ViewModifier {
    private let id = UUID()
    var strokeSize: CGFloat = 1
    var strokeColor: Color = .black

    func body(content: Content) -> some View {
        if strokeSize > 0 {
            appliedStrokeBackground(content: content)
        } else {
            content
        }
    }

    private func appliedStrokeBackground(content: Content) -> some View {
        content
            .padding(strokeSize*2)
            .background(
                Rectangle()
                    .foregroundColor(strokeColor)
                    .mask(alignment: .center) {
                        mask(content: content)
                    }
            )
    }

    func mask(content: Content) -> some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.01))
            if let resolvedView = context.resolveSymbol(id: id) {
                context.draw(resolvedView, at: .init(x: size.width/2, y: size.height/2))
            }
        } symbols: {
            content
                .tag(id)
                .blur(radius: strokeSize)
        }
    }
}
