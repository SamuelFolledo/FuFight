//
//  VerticalTabView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/10/24.
//

import SwiftUI

struct VerticalTabView<Content: View>: View {
    let proxy: GeometryProxy
    let content: Content

    init(proxy: GeometryProxy, @ViewBuilder content: () -> Content) {
        self.proxy = proxy
        self.content = content()
    }

    var body: some View {
        if #available(iOS 15.0, *) {
            // Geometry Reader code: https://blog.prototypr.io/how-to-vertical-paging-in-swiftui-f0e4afa739ba
            TabView {
                content
                    .rotationEffect(.degrees(-90)) // Rotate content
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
            .frame(width: proxy.size.height, height: proxy.size.width)
            .rotationEffect(.degrees(90), anchor: .topLeading) // Rotate TabView
            .offset(x: proxy.size.width) // Offset back into screens bounds
            .tabViewStyle(
                PageTabViewStyle(indexDisplayMode: .never)
            )
        } else {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    content
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}


#Preview {
    ZStack {
        GeometryReader { proxy in
            VerticalTabView(proxy: proxy) {
                ForEach(0..<3, id: \.self) { item in
                    Rectangle().fill(Color.pink)
                        .frame(
                            width: proxy.size.width,
                            height: proxy.size.height
                        )
                }
            }
        }
    }
}
