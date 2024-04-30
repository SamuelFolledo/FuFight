//
//  PlayerView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/4/24.
//

import SwiftUI

struct PlayerView<DamagesListView: View>: View {
    var player: Player
    var enemyDamagesList: DamagesListView
    var onImageTappedAction: (()->Void)?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if !player.isEnemy {
                AccountImage(url: player.photoUrl, radius: 30)
                    .onTapGesture {
                        onImageTappedAction?()
                    }
            }

            VStack(alignment: player.isEnemy ? .trailing : .leading, spacing: 4) {
                if !player.isEnemy {
                    nameView
                }

                hpBarView

                if player.isEnemy {
                    nameView
                }
            }

            if player.isEnemy {
                AccountImage(url: player.photoUrl, radius: 30)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, player.isEnemy ? 8 : 4)
        .padding(.bottom, player.isEnemy ? 4 : 8)
        .background(
            Color.systemGray
                .ignoresSafeArea()
                .cornerRadius(16)
                .opacity(0.5)
        )
    }

    var hpBarView: some View {
        VStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 20)
                        .opacity(0.7)
                        .foregroundColor(.gray)

                    Rectangle()
                        .frame(width: self.calculateBarWidth(geometry: geometry), height: 20)
                        .foregroundColor(self.calculateBarColor())
                }
                .overlay(
                    Text("\(player.hpText) / \(Int(player.maxHp))")
                        .font(mediumTextFont)
                        .foregroundStyle(.white)
                        .padding()
                )
            }
            .frame(height: 20)
        }
    }

    /// Calculate the width of the bar based on current hit points
    private func calculateBarWidth(geometry: GeometryProxy) -> CGFloat {
        let percent = CGFloat(player.hp / player.maxHp)
        return geometry.size.width * percent
    }

    /// Calculate the color of the bar based on current hit points
    private func calculateBarColor() -> Color {
        let percent = player.hp / player.maxHp
        if percent > 0.5 {
            return .green
        } else if percent > 0.2 {
            return .yellow
        } else {
            return .red
        }
    }

    var nameView: some View {
        HStack {
            if player.isEnemy {
                if !player.rounds.isEmpty {
                    enemyDamagesList
                }

                if player.state.hasSpeedBoost {
                    plusImage
                        .frame(width: 20, height: 20)
                }
            }

            Text(player.username)
                .font(mediumTextFont)
                .foregroundStyle(.white)

            if !player.isEnemy {
                if player.state.hasSpeedBoost {
                    plusImage
                        .frame(width: 20, height: 20)
                }

                if !player.rounds.isEmpty {
                    enemyDamagesList
                }
            }
        }
    }
}

#Preview {
    return VStack(spacing: 20) {
        PlayerView(player: fakePlayer, enemyDamagesList: DamagesListView(enemyRounds: fakeEnemyPlayer.rounds, isPlayerDead: false))
    }
}
