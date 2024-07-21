//
//  AppRectangleShape.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/21/24.
//

import SwiftUI

struct AppRectangleShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func appRectangleShapeWithBorder(lineWidth: CGFloat, borderColor: Color, radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(AppRectangleShape(radius: radius, corners: corners) )
            .overlay(AppRectangleShape(radius: radius, corners: corners)
                .stroke(borderColor, lineWidth: lineWidth))
    }
}

#Preview {
    AppRectangleShape()
}
