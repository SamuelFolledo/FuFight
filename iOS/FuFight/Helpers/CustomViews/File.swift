//
//  File.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/7/24.
//

import SwiftUI

struct AnimatingBackgroundView: View {

    @State var animate: Bool = false
    let animation: Animation = Animation.linear(duration: 60.0).repeatForever(autoreverses: false)

    var body: some View {
        GeometryReader { geo in
            backgroundImage
                .overlay {
                    HStack(spacing: -1) {
                        backgroundOverImage

                        backgroundOverImage
                            .frame(width: geo.size.width, alignment: .leading)
                    }
                    .frame(width: geo.size.width, height: geo.size.height,
                           alignment: animate ? .trailing : .leading)
                }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(animation) {
                animate.toggle()
            }
        }
    }
}
