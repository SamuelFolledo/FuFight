//
//  AccountImage.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/21/24.
//

import SwiftUI

struct AccountImage: View {
    let url: URL?
    let radius: CGFloat
    var squareSide: CGFloat {
        2.0.squareRoot() * radius
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(disabledColor)
//                .frame(width: radius * 2, height: radius * 2)
                .frame(width: squareSide, height: squareSide)

            CachedAsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: squareSide, height: squareSide)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
            }
        }
    }
}
