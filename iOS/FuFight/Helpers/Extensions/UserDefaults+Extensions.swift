//
//  UserDefaults+Extensions.swift
//  FuFight
//
//  Created by Samuel Folledo on 6/20/24.
//

import Foundation
import SwiftUI

extension UserDefaults {
    public enum Keys {
        static let topSafeAreaInset = "topSafeAreaInset"
        static let bottomSafeAreaInset = "bottomSafeAreaInset"
    }

    @UserDefault(key: Keys.topSafeAreaInset, defaultValue: 0)
    static var topSafeAreaInset: Double

    @UserDefault(key: Keys.bottomSafeAreaInset, defaultValue: 0)
    static var bottomSafeAreaInset: Double
}

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key)
        }
    }
}
