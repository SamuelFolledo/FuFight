//
//  UnlockFighterView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/26/24.
//

import SwiftUI

struct UnlockFighterView: View {
    var fighterType: FighterType
    @Binding var isShowing: Bool
    var currentCurrency: Int
    var isDiamond: Bool
    var cost: Int
    var buyAction: (() -> Void)?

    var body: some View {
        GeometryReader { reader in
            VStack(spacing: 20) {
                HStack(alignment: .top) {
                    Image(fighterType.headShotImageName)
                        .defaultImageModifier()
                        .clipShape(RoundedRectangle(cornerRadius: rectangleCornerRadius))

                    VStack(alignment: .leading) {
                        AppText("\(fighterType.summary)", type: .alertSmall)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, smallerHorizontalPadding)

                costView

                HStack {
                    AppButton(type: .cancel, maxWidth: reader.size.width * 0.3) {
                        isShowing = false
                    }

                    AppButton(type: .ok, maxWidth: reader.size.width * 0.3) {
                        buyAction?()
                    }
                }
            }
        }
    }

    var costView: some View {
        HStack(spacing: 0) {
            Group {
                if isDiamond {
                    diamondImage
                } else {
                    coinImage
                }
            }
            .frame(height: 25)

            if let account = Account.current {
                AppText("\(isDiamond ? account.diamonds : account.coins) - ", type: .alertSmall)

                AppText("\(cost)", fontSize: TextType.alertSmall.fontSize, color: .red)

                AppText(" = ", type: .alertSmall)

                AppText("\((isDiamond ? account.diamonds : account.coins) - cost)", fontSize: TextType.alertSmall.fontSize, color: .green)
            }
        }
    }
}
