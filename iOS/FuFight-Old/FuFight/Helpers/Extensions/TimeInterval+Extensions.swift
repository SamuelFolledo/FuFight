//
//  TimeInterval+Extensions.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/28/24.
//

import Foundation

extension TimeInterval {

    var seconds: Int {
        return Int(self.rounded())
    }

    var milliseconds: Int {
        return Int(self * 1_000)
    }
}
