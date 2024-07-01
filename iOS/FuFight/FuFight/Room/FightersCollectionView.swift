//
//  FightersCollectionView.swift
//  FuFight
//
//  Created by Samuel Folledo on 6/23/24.
//

import SwiftUI

struct FightersCollectionView: View {
    @Binding var selectedFighterType: FighterType?

    private let borderWidth: CGFloat = 5

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { value in
                if let selectedFighterType {
                    LazyHStack {
                        ForEach(allFighters, id: \.fighterType) { fighter in
                            let fighterType = fighter.fighterType
                            let fighterTypeIndex = allFighters.compactMap { $0.fighterType }.firstIndex(of: fighterType)
                            Button {
                                self.selectedFighterType = fighterType
                            } label: {
                                Image(fighterType.headShotImageName)
                                    .defaultImageModifier()
                            }
                            .padding(borderWidth)
                            .border(.yellow, width: selectedFighterType == fighterType ? borderWidth : 0)
                            .id(fighterType)
                            .frame(width: fighterCellSize, height: fighterCellSize)
                            .padding(.leading, fighterTypeIndex == allFighters.startIndex ? smallerHorizontalPadding : 0)
                            .padding(.trailing, fighterTypeIndex == allFighters.endIndex - 1 ? smallerHorizontalPadding : 0)
                        }
                        .onAppear {
                            value.scrollTo(selectedFighterType)
                        }
                    }
                } else {
                    LoadingView()
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
