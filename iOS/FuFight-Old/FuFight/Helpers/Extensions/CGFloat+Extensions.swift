//
//  CGFloat+Extensions.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/11/24.
//

import Foundation

extension CGFloat {
    var intString: String {
        return String(format: "%.0f", self)
    }

    func roundDecimalUpTo(_ fractionDigits: Int) -> CGFloat {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}
