//
//  AttacksView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

struct AttacksView: View {
    var attacks: [Attack]
    var sourceType: MovesViewSourceType
    var moveSelected: ((Attack) -> Void)?

    var body: some View {
        VStack {
            HStack {
                createButtonFrom(.leftLight)

                Spacer()

                createButtonFrom(.rightLight)
            }

            HStack {
                createButtonFrom(.leftMedium)

                Spacer()

                createButtonFrom(.rightMedium)
            }

            HStack {
                createButtonFrom(.leftHard)

                Spacer()

                createButtonFrom(.rightHard)
            }
        }
    }

    @ViewBuilder func createButtonFrom(_ position: AttackPosition) -> some View {
        ForEach(attacks, id: \.move.id) { move in
            if move.move.position == position {
                Button(action: {
                    moveSelected?(move)
                }, label: {
                    Image(move.move.iconName)
                        .defaultImageModifier()
                        .aspectRatio(1.0, contentMode: .fit)
                        .padding(sourceType == .enemy ? 4 : move.move.padding)
                        .background(
                            Image(move.move.backgroundIconName)
                                .backgroundImageModifier()
                                .scaledToFit()
                        )
                })
                .frame(width: sourceType.shouldFlip ? 30 : 100)
                .blur(radius: move.state.blurRadius, opaque: false)
                .colorMultiply(move.state == .selected ? Color.systemGray2 : Color.white)
                .opacity(move.state.opacity)
                .overlay {
                    getFireView(from: move)
                }
                .overlay {
                    Group {
                        switch move.state {
                        case .cooldown:
                            Text("\(move.currentCooldown)")
                                .font(sourceType.font)
                                .foregroundStyle(.white)
                        case .selected:
                            Circle()
                                .stroke(.green, lineWidth: sourceType.shouldFlip ? 2 : 4)
                        case .initial, .unselected:
                            EmptyView()
                        }
                    }
                    .rotationEffect(sourceType.angle)
                    .allowsHitTesting(false)
                }
            }
        }
    }

    var weakRedFire: some View {
        let width: CGFloat = sourceType == .user ? 800 : 160
        let height: CGFloat = sourceType == .user ? 420 : 85
        let bottomPadding: CGFloat = sourceType == .user ? 75 : 16
        let trailingPadding: CGFloat = sourceType == .user ? 30 : 4
        return GIFView(type: URLType.name("weakRedFire"))
            .frame(width: width, height: height)
            .padding(.bottom, bottomPadding)
            .padding(.trailing, trailingPadding)
    }

    var strongRedFire: some View {
        let width: CGFloat = sourceType == .user ? 800 : 160
        let height: CGFloat = sourceType == .user ? 420 : 90
        let bottomPadding: CGFloat = sourceType == .user ? 65 : 16
        let trailingPadding: CGFloat = sourceType == .user ? 30 : 4
        return GIFView(type: URLType.name("strongRedFire"))
            .frame(width: width, height: height)
            .padding(.bottom, bottomPadding)
            .padding(.trailing, trailingPadding)
    }

    func getFireView(from move: Attack) -> some View {
        Group {
            if let fireState = move.fireState {
                switch move.state {
                case .cooldown:
                    EmptyView()
                case .initial, .unselected, .selected:
                    switch fireState {
                    case .small:
                        weakRedFire
                    case .big:
                        strongRedFire
                    }
                }
            }
        }
        .rotationEffect(sourceType.angle)
        .allowsHitTesting(false)
    }
}

#Preview {
    @State var attacks: [Attack] = defaultAllPunchAttacks

    return VStack(spacing: 200) {
        AttacksView(attacks: attacks, sourceType: .enemy)

        AttacksView(attacks: attacks, sourceType: .user)
    }
}
