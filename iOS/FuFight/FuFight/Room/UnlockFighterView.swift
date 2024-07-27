//
//  UnlockFighterView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/26/24.
//

import SwiftUI

struct UnlockFighterView: View {
    var fighterType: FighterType

    var body: some View {
        GeometryReader { reader in
            VStack(spacing: 20) {
                HStack(alignment: .top) {
                    Image(fighterType.headShotImageName)
                        .defaultImageModifier()
                        .clipShape(RoundedRectangle(cornerRadius: rectangleCornerRadius))

                    VStack(alignment: .leading) {
                        AppText("\(fighterType.name)", type: .alertMedium)

                        AppText("Fighter is one of the best characters ever", type: .alertSmall)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, smallerHorizontalPadding)

                HStack {
                    AppButton(title: "Coins",
                              imageName: "coin",
                              color: .main,
                              maxWidth: reader.size.width * 0.3)

                    AppButton(title: "Diamonds", 
                              imageName: "diamond",
                              color: .main2,
                              maxWidth: reader.size.width * 0.3)
                }
            }
        }
    }
}
