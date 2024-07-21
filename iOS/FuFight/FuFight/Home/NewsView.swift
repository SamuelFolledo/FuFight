//
//  NewsView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/20/24.
//

import SwiftUI

enum NewsType: String, Hashable, Identifiable {
    case newCharacter
    case announcement
    case other

    var id: String {
        rawValue
    }

    static func == (lhs: NewsType, rhs: NewsType) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}

struct News: Hashable, Identifiable {
    var title: String
    var type: NewsType

    var id: String = UUID().uuidString
}

struct NewsView: View {
    let news: [News] = fakeNews
    let timer = Timer.publish(every: 4.0, on: .main, in: .common).autoconnect()

    @State private var selectedIndex: Int = 0

    var body: some View {
        ZStack {
            //Background
            Color.black
                .opacity(0.8)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .ignoresSafeArea()
                .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black.opacity(0.2)]), startPoint: .leading, endPoint: .trailing))

            //TabView for Carousel
            TabView(selection: $selectedIndex) {
                ForEach(0..<news.count, id: \.self) { index in
                    ZStack(alignment: .topLeading) {
                        VStack {
                            AppText(news[index].title, type: .navSmall)
                            AppText("TODO", type: .textSmall)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(index)
                    .shadow(radius: 20)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .padding(.horizontal, 4)
            .padding(.top, 4)
            .padding(.bottom, 10)

            // Step 12: Navigation Dots
            HStack {
                ForEach(0..<news.count, id: \.self) { index in
                    Capsule()
                        .fill(Color.white.opacity(selectedIndex == index ? 1 : 0.33))
                        .frame(width: 8, height: 8)
                        .onTapGesture {
                            selectedIndex = index
                        }
                }
                .offset(y: 30)
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.default) {
                selectedIndex = (selectedIndex + 1) % news.count
            }
        }
    }
}

#Preview {
    return VStack(spacing: 20) {
        NewsView()
    }
}
