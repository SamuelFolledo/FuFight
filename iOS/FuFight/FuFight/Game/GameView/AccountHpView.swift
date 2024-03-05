//
//  AccountHpView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/4/24.
//

import SwiftUI

struct AccountHpView: View {
    var player: Player
    var isEnemy = false

    var body: some View {
        HStack(spacing: 12) {
            if !isEnemy {
                AccountImage(url: player.photoUrl, radius: 30)
            }

            VStack(alignment: isEnemy ? .trailing : .leading, spacing: 0) {
                hpBarView

                Text(player.username)
            }

            if isEnemy {
                AccountImage(url: player.photoUrl, radius: 30)
            }
        }
    }

    var hpBarView: some View {
        VStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 20)
                        .opacity(0.3)
                        .foregroundColor(.gray)

                    Rectangle()
                        .frame(width: self.calculateBarWidth(geometry: geometry), height: 20)
                        .foregroundColor(self.calculateBarColor())
                }
                .overlay(
                    Text("\(Int(player.hp)) / \(Int(player.maxHp))")
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
}

#Preview {
    let photoUrl = Account.current?.photoUrl ?? URL(string: "https://firebasestorage.googleapis.com:443/v0/b/fufight-51d75.appspot.com/o/Accounts%2FPhotos%2FS4L442FyMoNRfJEV05aFCHFMC7R2.jpg?alt=media&token=0f185bff-4d16-450d-84c6-5d7645a97fb9")!
    return VStack(spacing: 20) {
        AccountHpView(player: Player(photoUrl: photoUrl, username: "Samuel", hp: 100, maxHp: 100))
        AccountHpView(player: Player(photoUrl: photoUrl, username: "Samuel", hp: 80, maxHp: 100))
        AccountHpView(player: Player(photoUrl: photoUrl, username: "Samuel", hp: 50, maxHp: 100))
        AccountHpView(player: Player(photoUrl: photoUrl, username: "Brandon", hp: 20, maxHp: 100), isEnemy: true)
        AccountHpView(player: Player(photoUrl: photoUrl, username: "Brandon", hp: 0, maxHp: 100), isEnemy: true)
    }
}
