//
//  SeasonView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/21/24.
//

import SwiftUI

struct SeasonView: View {
    var body: some View {
        VStack(spacing: 0) {
            AppText("Season: 3", type: .textMedium)

            HStack(alignment: .center, spacing: -4) {
                Color.yellow
                    .frame(width: 30, height: 30)
                    .clipShape(AppHexagonShape())
                    .overlay {
                        AppText("8", type: .navMedium)
                            .padding(4)
                    }
                    .stroke(color: Color.blackLight, width: 0.75)
                    .zIndex(1)

                CustomProgressView(progress: 0.3)
                    .frame(maxWidth: .infinity)
                    .frame(height: 10)
                    .zIndex(0)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background {
            Color.whiteDark
        }
        .appRectangleShapeWithBorder(lineWidth: 2, borderColor: Color.yellow, radius: rectangleCornerRadius, corners: .allCorners)
    }
}

#Preview {
    return AnimatingBackgroundView()
        .overlay {
            VStack(spacing: 20) {
                SeasonView()
            }
        }
}
