//
//  LoadingView.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/16/24.
//

import SwiftUI

struct LoadingView: View {
    var message: String?

    var body: some View {
        if let message {
            VStack(alignment: .center) {
                Text("\(message)")
                    .font(mediumTextFont)
                    .foregroundColor(Color.systemBackground)

                LoadingIndicator()
            }
        } else {
            EmptyView()
        }
    }
}

struct LoadingIndicator: View {
    @State private var isLoading = false
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.8)
            .stroke(Color.systemBackground, lineWidth: 5)
            .frame(width: 30, height: 30)
            .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
            .onAppear {
                DispatchQueue.main.async {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        self.isLoading.toggle()
                    }
                }
            }
    }
}

#Preview {
    return LoadingView(message: "Looking for opponent")
}
