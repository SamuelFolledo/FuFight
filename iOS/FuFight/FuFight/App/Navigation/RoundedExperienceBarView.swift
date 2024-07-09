//
//  RoundedExperienceBarView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/9/24.
//

import SwiftUI

struct RoundedExperienceBarView: View {
    @State private var progressValue: Double = 0.6
    private let levelBorderWidth: CGFloat = 1

    var body: some View {
        GeometryReader { reader in
            SemiCircularProgressView(progress: progressValue)
                .rotationEffect(.degrees(50))
                .overlay(alignment: .trailing) {
                    VStack {
                        Spacer()
                            .frame(maxHeight: .infinity)

                        //Level label
                        Circle()
                            .strokeBorder(Color.white.opacity(0.6), lineWidth: levelBorderWidth)
                            .background {
                                Circle().fill(.black)
                            }
                            .overlay {
                                Text("24")
                                    .font(usernameFont)
                                    .foregroundStyle(Color.white)
                                    .padding(3.5)
                                    .minimumScaleFactor(0.2)
                                    .lineLimit(1)
                            }
                            .frame(width: reader.size.width / 2.5)
                            .padding(.trailing, -reader.size.width / 10)
                    }
                }
        }
    }
}

#Preview {
    RoundedExperienceBarView()
}
