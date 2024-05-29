//
//  AttackCanBoostView.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/15/24.
//

import SwiftUI

struct AttackCanBoostView: View {
    let playerType: PlayerType
    var isEditing: Bool
    
    @State private var isShowingCanBoostIndicator: Bool = false
    @State private var moveClockwise: Bool = false
    private var strokeWidth: CGFloat {
        playerType.shouldFlip ? 1 : 2
    }
    private var spinDuration: CGFloat {
        playerType.shouldFlip ? 1.0 : 1.75
    }
    private var size: CGFloat {
        strokeWidth * 2
    }
    private var xOffset: CGFloat {
        playerType.isEnemy ? -9 : -45
    }

    var body: some View {
        ZStack {
            //Circle border
            Circle()
                .stroke(.yellow, lineWidth: strokeWidth)
                .opacity(isShowingCanBoostIndicator ?  1 : 0)
                .zIndex(1)
                .onAppear(delay: 0.5) {
                    let boostIndicatorAnimation = Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)
                    withAnimation(boostIndicatorAnimation) {
                        isShowingCanBoostIndicator.toggle()
                    }
                }

            if !isEditing {
                //Spinning circle
                Circle()
                    .fill(.yellow)
                    .frame(width: size, height: size, alignment: .center)
                    .offset(x: xOffset)
                    .rotationEffect(.degrees(moveClockwise ? 360 : 0))
                    .animation(.linear(duration: spinDuration).repeatForever(autoreverses: false),
                               value: moveClockwise
                    )
                    .opacity(isShowingCanBoostIndicator ?  1 : 0.3)
            }
        }
        .onAppear {
            self.moveClockwise.toggle()
        }
    }
}

#Preview {
    AttackCanBoostView(playerType: .user, isEditing: false)
}
