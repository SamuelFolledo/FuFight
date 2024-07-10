//
//  File.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/7/24.
//

import SwiftUI

struct AnimatingBackgroundView: View {

    @State var animate: Bool = false
    var leadingPadding: CGFloat = 0
    var color: Color? = nil

    let animation: Animation = Animation.linear(duration: 60.0).repeatForever(autoreverses: false)

    var body: some View {
        GeometryReader { reader in
            if let color {
                createBackgroundImage(reader)
                    .colorMultiply(color)
            } else {
                createBackgroundImage(reader)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(animation) {
                animate.toggle()
            }
        }
    }

    @ViewBuilder func createBackgroundImage(_ reader: GeometryProxy) -> some View {
        backgroundImage
            .padding(.leading, leadingPadding)
            .overlay {
                HStack(spacing: -1) {
                    backgroundOverImage

                    backgroundOverImage
                        .frame(width: reader.size.width, alignment: .leading)
                }
                .frame(width: reader.size.width, height: reader.size.height,
                       alignment: animate ? .trailing : .leading)
            }
    }
}
