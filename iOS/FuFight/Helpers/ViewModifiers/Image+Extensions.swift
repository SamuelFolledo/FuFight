//
//  Image+Extensions.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

extension Image {
    func defaultImageModifier() -> some View {
        self.resizable()
            .aspectRatio(1.0, contentMode: .fit)
    }

    func buttonImageModifier() -> some View {
        self.resizable()
            .aspectRatio(contentMode: .fill)
    }

    func backgroundImageModifier() -> some View {
        self.resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
    }
}
