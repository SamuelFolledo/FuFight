//
//  AttacksView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/6/24.
//

import SwiftUI

struct AttacksView: View {
    @Binding var attacks: [Attack]
    var sourceType: MovesViewSourceType

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
                    selectMove(move)
                }, label: {
                    Image(move.move.imageName)
                        .defaultImageModifier()
                        .aspectRatio(1.0, contentMode: .fit)
                        .padding(sourceType == .enemy ? 4 : move.move.padding)
                        .background(
                            Image(move.move.moveType == .attack ? "moveBackgroundRed" : "moveBackgroundBlue")
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
                            Text("\(move.cooldown)")
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

    func getFireView(from move: Attack) -> some View {
        Group {
            if let fireState = move.fireState {
                switch move.state {
                case .cooldown:
                    EmptyView()
                case .initial, .unselected, .selected:
                    switch fireState {
                    case .small:
                        switch sourceType {
                        case .user:
                            GIFView(type: URLType.name("weakRedFire"))
                                .frame(width: 800, height: 420)
                                .padding(.bottom, 75)
                                .padding(.trailing, 30)
                        case .enemy:
                            GIFView(type: URLType.name("weakRedFire"))
                                .frame(width: 160, height: 85)
                                .padding(.bottom, 16)
                                .padding(.trailing, 4)
                        }
                    case .big:
                        switch sourceType {
                        case .user:
                            GIFView(type: URLType.name("strongRedFire"))
                                .frame(width: 800, height: 420)
                                .padding(.bottom, 65)
                                .padding(.trailing, 30)
                        case .enemy:
                            GIFView(type: URLType.name("strongRedFire"))
                                .frame(width: 160, height: 90)
                                .padding(.bottom, 16)
                                .padding(.trailing, 4)
                        }
                    }
                }
            } else {
                EmptyView()
            }
        }
        .rotationEffect(sourceType.angle)
        .allowsHitTesting(false)
    }

    func selectMove(_ selectedMove: Attack) {
        guard selectedMove.state != .cooldown else { return }
        for (index, attack) in attacks.enumerated() {
            if attack.move.id == selectedMove.move.id {
                attacks[index].setStateTo(.selected)
            } else {
                guard attacks[index].state != .cooldown else { continue }
                attacks[index].setStateTo(.unselected)
            }
        }
    }
}

#Preview {
    @State var attacks: [Attack] = defaultAllPunchAttacks

    return VStack(spacing: 200) {
        AttacksView(attacks: $attacks, sourceType: .enemy)

        AttacksView(attacks: $attacks, sourceType: .user)
    }
}
