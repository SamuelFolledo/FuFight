//
//  CharacterListView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/5/24.
//

import SwiftUI

struct CharacterListView: View {
    @Binding var selectedFighterType: FighterType?
    let fighters: [CharacterObject]
    let buyAction: ((_ fighterType: FighterType) -> Void)?

    private let columns = Array(repeating: GridItem(.adaptive(minimum: 160), spacing: characterItemSpacing), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: characterItemSpacing) {
            ForEach(fighters, id: \.self) { character in
                CharacterObjectCell(character: character, isSelected: character.id == selectedFighterType?.id) {
                    switch character.status {
                    case .upcoming:
                        TODO("Upcoming \(character.fighterType.name)")
                    case .locked:
                        buyAction?(character.fighterType)
                    case .unlocked:
                        selectedFighterType = character.fighterType
                    case .selected:
                        break
                    }
                }
            }
        }
    }
}

struct CharacterObjectCell: View {
    var character: CharacterObject
    var isSelected: Bool
    var action: () -> Void

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

//                    Spacer() //Uncomment to add more vertical space on each cell
//                        .frame(height: 200)
                }
                .overlay {
                    VStack {
                        Spacer()

                        switch character.status {
                        case .upcoming:
                            EmptyView()

                        case .locked:
                            HStack {
                                coinButton

                                Spacer()

                                diamondButton
                            }
                        case .unlocked, .selected:
                            HStack {
                                fighterRankLabel

                                Spacer()

                                fighterRatingLabel
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background {
                        VStack {
                            Spacer()

                            Color.blackLight
                                .frame(height: 75)
                                .frame(maxWidth: .infinity)
                                .mask(LinearGradient(gradient: Gradient(colors: [.black, .clear, .clear]), startPoint: .bottom, endPoint: .top))
                        }
                    }
                }

                AppText(character.fighterType.name, type: .textSmall)
                    .padding(.bottom, 4)
            }
            .overlay {
                switch character.status {
                case .upcoming:
                    Color.black.opacity(0.6)
                        .overlay {
                            lockOverlay(isUpcoming: true)
                        }
                case .locked:
                    lockOverlay(isUpcoming: false)

                case .unlocked:
                    EmptyView()
                case .selected:
                    EmptyView()
                }
            }
            .background(Color.blackLight)
            .padding(characterItemBorderWidth)
            .border(.yellow, width: isSelected ? characterItemBorderWidth : 0)
            .minimumScaleFactor(0.3)
            .lineLimit(1)
        })
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder func lockOverlay(isUpcoming: Bool) -> some View {
        VStack {
            HStack {
                Spacer()

                lockImage
                    .frame(width: 30)
                    .padding(.top, characterItemBorderWidth)
            }

            Spacer()

            if isUpcoming {
                AppText("Coming soon", type: .buttonSmall)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var coinButton: some View {
        Button(action: {
            TODO("Buy fighter \(character.fighterType.name) with COIN \(character.fighterType.name)")
        }, label: {
            HStack(spacing: 2) {
                coinImage
                    .frame(width: 15, height: 15, alignment: .center)

                AppText("6999", type: .textSmall)
                    .padding(.vertical, 4)
            }
            .frame(maxWidth: .infinity)
        })
    }

    var diamondButton: some View {
        Button(action: {
            TODO("Buy fighter \(character.fighterType.name) with DIAMOND \(character.fighterType.name)")
        }, label: {
            HStack(spacing: 2) {
                diamondImage
                    .frame(width: 15, height: 15, alignment: .center)

                AppText("750", type: .textSmall)
                    .padding(.vertical, 4)
            }
            .frame(maxWidth: .infinity)
        })
    }

    var fighterRankLabel: some View {
        AppText("Rank: 2", type: .textSmall)
            .padding(.vertical, 4)
            .padding(.leading, 4)
    }

    var fighterRatingLabel: some View {
        AppText("SS", type: .textSmall)
            .foregroundStyle(Color.red)
            .padding(.vertical, 4)
            .padding(.trailing, 4)
    }
}

#Preview {
    CharacterListView(selectedFighterType: .constant(.clara), fighters: fakeAllFighters, buyAction: nil)
}
