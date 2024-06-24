//
//  FightersCollectionView.swift
//  FuFight
//
//  Created by Samuel Folledo on 6/23/24.
//

import SwiftUI

struct FightersCollectionView: View {
    @State var selectedFighter: FighterType
    var fighterSelected: ((_ fighterType: FighterType) -> Void)?

    private let fighters = FighterType.allCases
    private let borderWidth: CGFloat = 5

    var body: some View {
        ScrollView(.horizontal) {
            ScrollViewReader { value in
                LazyHStack {
                    ForEach(0..<fighters.count, id: \.self) { index in
                        let fighterType = fighters[index]
                        Button {
                            fighterSelected?(fighterType)
                            selectedFighter = fighterType
                        } label: {
                            Image(fighterType.headShotImageName)
                                .defaultImageModifier()
                        }
                        .padding(borderWidth)
                        .border(.yellow, width: selectedFighter == fighterType ? borderWidth : 0)
                        .id(index)
                        .frame(width: fighterCellSize, height: fighterCellSize)
                        .padding(.leading, index == 0 ? smallerHorizontalPadding : 0)
                        .padding(.trailing, index == fighters.count - 1 ? smallerHorizontalPadding : 0)
                    }
                }
            }
        }
    }

    func getLangDirection() -> Locale.LanguageDirection? {
        guard let language = Locale.current.language.languageCode?.identifier else { return nil }
        let direction = Locale.Language(identifier: language).characterDirection
        return direction
    }
}
