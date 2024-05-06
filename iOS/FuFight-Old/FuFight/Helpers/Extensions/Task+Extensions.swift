//
//  Task+Extensions.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/3/24.
//

import SwiftUI

public extension TimeInterval {
    var nanoseconds: UInt64 {
        return UInt64((self * 1_000_000_000).rounded())
    }
}

@available(iOS 13.0, macOS 10.15, *)
public extension Task where Success == Never, Failure == Never {

    /** Easily create a delay. Just pass a 3 for a 3 seconds delay
     
    1. Source:  https://stackoverflow.com/a/75716315/7277928
    */
    static func sleep(_ duration: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: duration.nanoseconds)
    }
}

@available(iOS 15.0, macOS 12.0, *)
public extension View {
    func onAppear(delay: TimeInterval, action: @escaping () -> Void) -> some View {
        task {
            do {
                try await Task.sleep(delay)
            } catch { // Task canceled
                return
            }

            await MainActor.run {
                action()
            }
        }
    }
}
