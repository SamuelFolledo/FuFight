//
//  CharacterListView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/5/24.
//

import SwiftUI

struct CharacterListView: View {
    @Binding var selectedFighterType: FighterType?
    let itemSpacing: CGFloat = 2
    let columns = Array(repeating: GridItem(.adaptive(minimum: 160), spacing: 2), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: itemSpacing) {
            ForEach(characters, id: \.self) { character in
                CharacterObjectCell(character: character, isSelected: character.id == selectedFighterType?.id) {
                    LOGD("CHARACTER SELECTED \(character.fighterType.name)")
                    selectedFighterType = character.fighterType
                }
            }
        }
        .padding()
    }
}

struct CharacterObjectCell: View {
    var character: CharacterObject
    var isSelected: Bool
    var action: () -> Void

    private let borderWidth: CGFloat = 5

    init(character: CharacterObject, isSelected: Bool, action: @escaping () -> Void) {
        UITableViewCell.appearance().backgroundColor = .clear
        self.character = character
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action, label: {
            VStack(spacing: 1) {
                VStack {
                    Image(character.fighterType.headShotImageName)
                        .defaultImageModifier()
                }
                .overlay {
                    VStack {
                        Spacer()

                        if isSelected {
                            HStack {
                                fighterRankLabel

                                Spacer()

                                fighterRatingLabel
                            }
                        } else {
                            HStack {
                                coinButton

                                Spacer()

                                diamondButton
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background {
                        VStack {
                            Spacer()

                            Color.black
                                .frame(height: 75)
                                .frame(maxWidth: .infinity)
                                .mask(LinearGradient(gradient: Gradient(colors: [.black, .clear, .clear]), startPoint: .bottom, endPoint: .top))
                        }
                    }
                }

                Text(character.fighterType.name)
                    .font(characterFont)
                    .foregroundStyle(.white)
                    .padding(.bottom, 4)
            }
            .background(Color.black)
            .padding(borderWidth)
            .border(.yellow, width: isSelected ? borderWidth : 0)
            .minimumScaleFactor(0.3)
            .lineLimit(1)
        })
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
    }

    var coinButton: some View {
        Button(action: {
            TODO("Buy with coin \(character.fighterType.name)")
        }, label: {
            HStack(spacing: 2) {
                Image("coin")
                    .defaultImageModifier()
                    .frame(width: 15, height: 15, alignment: .center)

                Text("6999")
                    .font(characterDetailFont)
                    .padding(.vertical, 4)
                    .foregroundStyle(Color.white)
            }
            .frame(maxWidth: .infinity)
        })
    }

    var diamondButton: some View {
        Button(action: {
            TODO("Buy with cash \(character.fighterType.name)")
        }, label: {
            HStack(spacing: 2) {
                Image("diamond")
                    .defaultImageModifier()
                    .frame(width: 15, height: 15, alignment: .center)

                Text("750")
                    .font(characterDetailFont)
                    .padding(.vertical, 4)
            }
            .frame(maxWidth: .infinity)
        })
    }

    var fighterRankLabel: some View {
        Text("Rank: 2")
            .font(characterFont)
            .foregroundStyle(Color.gray)
            .padding(.vertical, 4)
            .padding(.leading, 4)
    }

    var fighterRatingLabel: some View {
        Text("SS")
            .font(characterFont)
            .foregroundStyle(Color.red)
            .padding(.vertical, 4)
            .padding(.trailing, 4)
    }
}

#Preview {
    CharacterListView(selectedFighterType: .constant(.clara))
}
