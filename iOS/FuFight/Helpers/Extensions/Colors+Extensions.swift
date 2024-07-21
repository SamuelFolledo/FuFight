//
//  Colors+Extensions.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/17/24.
//

import SwiftUI
import UIKit

extension UIColor {
    static let yellow: UIColor = UIColor(named: "Yellow")!
    static let blue: UIColor = UIColor(named: "Blue")!
    static let lightBlue: UIColor = UIColor(named: "BlueLight")!
    static let darkBlue: UIColor = UIColor(named: "BlueDark")!
    static let gray: UIColor = UIColor(named: "Gray")!
    static let lightGray: UIColor = UIColor(named: "GrayLight")!
    static let darkGray: UIColor = UIColor(named: "GrayDark")!
    static let green: UIColor = UIColor(named: "Green")!
    static let red: UIColor = UIColor(named: "Red")!
    static let white: UIColor = UIColor(named: "White")!

    static let main = yellow
    static let main2 = blue

    ///Creates a UIColor from a hex that must begin with #
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        return nil
    }
}


///UIKit system Color extension
///Source: https://stackoverflow.com/a/64414674
extension Color {
    static let main = Color(UIColor.main)
    static let main2 = Color(UIColor.main2)

    static let yellow = Color(UIColor.yellow)
    static let blue = Color(UIColor.blue)
    static let lightBlue = Color(UIColor.lightBlue)
    static let darkBlue = Color(UIColor.darkBlue)
    static let gray = Color(UIColor.gray)
    static let lightGray = Color(UIColor.lightGray)
    static let darkGray = Color(UIColor.darkGray)
    static let green = Color(UIColor.green)
    static let red = Color(UIColor.red)
    static let black = Color(UIColor.black)
    static let white = Color(UIColor.white)

    // MARK: - Text Colors
    static let lightText = Color(UIColor.lightText)
    static let darkText = Color(UIColor.darkText)
    static let placeholderText = Color(UIColor.placeholderText)

    // MARK: - Label Colors
    static let label = Color(UIColor.label)
    static let secondaryLabel = Color(UIColor.secondaryLabel)
    static let tertiaryLabel = Color(UIColor.tertiaryLabel)
    static let quaternaryLabel = Color(UIColor.quaternaryLabel)

    // MARK: - Background Colors
    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)

    // MARK: - Fill Colors
    static let systemFill = Color(UIColor.systemFill)
    static let secondarySystemFill = Color(UIColor.secondarySystemFill)
    static let tertiarySystemFill = Color(UIColor.tertiarySystemFill)
    static let quaternarySystemFill = Color(UIColor.quaternarySystemFill)

    // MARK: - Grouped Background Colors
    static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)
    static let secondarySystemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let tertiarySystemGroupedBackground = Color(UIColor.tertiarySystemGroupedBackground)

    // MARK: - Gray Colors
    static let systemGray = Color(UIColor.systemGray)
    static let systemGray2 = Color(UIColor.systemGray2)
    static let systemGray3 = Color(UIColor.systemGray3)
    static let systemGray4 = Color(UIColor.systemGray4)
    static let systemGray5 = Color(UIColor.systemGray5)
    static let systemGray6 = Color(UIColor.systemGray6)

    // MARK: - Other Colors
    static let separator = Color(UIColor.separator)
    static let opaqueSeparator = Color(UIColor.opaqueSeparator)
    static let link = Color(UIColor.link)

    // MARK: System Colors
    static let systemBlue = Color(UIColor.systemBlue)
    static let systemPurple = Color(UIColor.systemPurple)
    static let systemGreen = Color(UIColor.systemGreen)
    static let systemYellow = Color(UIColor.systemYellow)
    static let systemOrange = Color(UIColor.systemOrange)
    static let systemPink = Color(UIColor.systemPink)
    static let systemRed = Color(UIColor.systemRed)
    static let systemTeal = Color(UIColor.systemTeal)
    static let systemIndigo = Color(UIColor.systemIndigo)
}
