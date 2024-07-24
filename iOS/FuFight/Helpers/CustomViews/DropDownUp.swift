//
//  DropDownUp.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/23/24.
//

import SwiftUI

struct DropDownUp: View {

    let options: [String]

    private let menuWdith: CGFloat  =  150
    private let buttonHeight: CGFloat  =  50
    private let maxItemDisplayed: Int  =  3

    @Binding var selectedOptionIndex: Int
    @Binding var showDropdown: Bool

    @State private var scrollPosition: Int?

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                if showDropdown {
                    let scrollViewHeight: CGFloat  = options.count > maxItemDisplayed ? (buttonHeight*CGFloat(maxItemDisplayed)) : (buttonHeight*CGFloat(options.count))
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(0..<options.count, id: \.self) { index in
                                Button(action: {
                                    withAnimation {
                                        selectedOptionIndex = index
                                        showDropdown.toggle()
                                    }
                                }, label: {
                                    HStack {
                                        AppText(options[index], type: .tabSmall)

                                        Spacer()

                                        if index == selectedOptionIndex {
                                            checkedImage
                                                .frame(width: 20, height: 20)
                                        }
                                    }
                                })
                                .padding(.horizontal, 20)
                                .frame(width: menuWdith, height: buttonHeight, alignment: .leading)
                                .background {
                                    if index == selectedOptionIndex {
                                        Color.yellow
                                    }
                                }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollPosition(id: $scrollPosition)
                    .scrollDisabled(options.count <=  3)
                    .background {
                        Color.whiteDark
                    }
                    .frame(height: scrollViewHeight)
                    .onAppear {
                        scrollPosition = selectedOptionIndex
                    }
                }
                // selected item
                Button(action: {
                    withAnimation {
                        showDropdown.toggle()
                    }
                }, label: {
                    HStack(spacing: nil) {
                        AppText(options[selectedOptionIndex], type: .tabSmall)
                        Spacer()
                        Image(systemName: "triangleshape.fill")
                            .padding(.vertical, 8)
                            .rotationEffect(.degrees((showDropdown ?  -180 : 0)))
                    }
                })
                .padding(.horizontal, 20)
                .frame(width: menuWdith, height: buttonHeight, alignment: .leading)
            }
            .foregroundStyle(Color.white)
//            .background(RoundedRectangle(cornerRadius: 16).fill(Color.black)) //old bg
        }
        .frame(width: menuWdith, height: buttonHeight, alignment: .bottom)
        .background {
            yellowButtonImage
        }
        .zIndex(100)
    }
}
