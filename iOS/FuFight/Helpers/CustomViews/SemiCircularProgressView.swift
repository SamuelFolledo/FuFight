//
//  CircleProgressView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/8/24.
//

import SwiftUI

struct SemiCircularProgressView: View {
    let progress: Double

    private let lineWidth: Double = 5
    private let totalAngle: Double = 320
    private let isColorfulProgressBar = false
    private let colorfulGradient = Gradient(stops: [
        .init(color: Color.red, location: 0),
        .init(color: Color.orange, location: 65.0 / 360),
        .init(color: Color.yellow, location: 110.0 / 360),
        .init(color: Color.green, location: 175.0 / 360),
        .init(color: Color.blue, location: 220.0 / 360),
        .init(color: Color.purple, location: 1)
    ])
    private let defaultGradient = Gradient(stops: [.init(color: Color.yellow, location: 1)])

    var body: some View {
        ZStack {
            //Gray stroke
            Circle()
                .trim(from: 0, to: totalAngle / 360)
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .opacity(0.3)
                .foregroundColor(Color.gray)

            //Progress bar's color
            Circle()
                .trim(from: 0, to: (progress * totalAngle) / 360)
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .fill(AngularGradient(gradient: isColorfulProgressBar ? colorfulGradient : defaultGradient,
                                      center: .center))
        }
    }
}
