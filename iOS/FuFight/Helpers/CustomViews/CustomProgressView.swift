//
//  CustomProgressView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/21/24.
//

import SwiftUI

struct CustomProgressView: View {
    let progress: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 10)
                    .foregroundColor(.grayLight)
                    .stroke(color: Color.blackLight, width: 0.5)

                Rectangle()
                    .frame(
                        width: min(progress * geometry.size.width,
                                   geometry.size.width),
                        height: 10
                    )
                    .foregroundColor(.yellow)
                    .stroke(color: Color.blackLight, width: 0.5)
            }
        }
    }
}

#Preview {
    CustomProgressView(progress: 0.4)
}
