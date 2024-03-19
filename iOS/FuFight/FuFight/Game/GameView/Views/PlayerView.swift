//
//  PlayerView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/4/24.
//

import SwiftUI

struct PlayerView: View {
    var player: Player
    var rounds: [Round]

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if !player.isEnemy {
                AccountImage(url: player.photoUrl, radius: 30)
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
                    Text("\(Int(player.hp)) / \(Int(player.maxHp))")
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
                if !player.turns.isEmpty {
                    damagesList
                }

                if !rounds.isEmpty, !rounds.last!.hasSpeedBoost {
                    plusImage
                        .frame(width: 20, height: 20)
                }
            }

            Text(player.username)
                .font(mediumTextFont)
                .foregroundStyle(.white)

            if !player.isEnemy {
                if !rounds.isEmpty, rounds.last!.hasSpeedBoost {
                    plusImage
                        .frame(width: 20, height: 20)
                }

                if !player.turns.isEmpty {
                    damagesList
                }
            }
        }
    }

    var damagesList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                let rounds = player.hp > 0 ? rounds.dropLast().reversed() : rounds.reversed()
                ForEach(Array(zip(rounds.indices, rounds)), id: \.1) { index, round in
                    Group {
                        let totalDamage = player.isEnemy ? rounds[index].damage : rounds[index].enemyDamage
                        if let totalDamage {
                            if totalDamage <= 0 {
                                Text("Round \(round.id): N/A")
                                    .foregroundStyle(.white)
                            } else {
                                Text("Round \(round.id): \(totalDamage.intString)")
                                    .foregroundStyle(.red)
                            }
                        } else {
                            Text("Round \(round.id): Dodged")
                                .foregroundStyle(.white)
                        }
                    }
                    .font(mediumTextFont)
                }
            }
        }
    }
}

#Preview {
    let photoUrl = Account.current?.photoUrl ?? URL(string: "https://firebasestorage.googleapis.com:443/v0/b/fufight-51d75.appspot.com/o/Accounts%2FPhotos%2FS4L442FyMoNRfJEV05aFCHFMC7R2.jpg?alt=media&token=0f185bff-4d16-450d-84c6-5d7645a97fb9")!
    return VStack(spacing: 20) {
        PlayerView(player: Player(photoUrl: photoUrl, username: "Samuel", hp: 100, maxHp: 100, attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses), rounds: [])
        PlayerView(player: Player(photoUrl: photoUrl, username: "Samuel", hp: 80, maxHp: 100, attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses), rounds: [])
        PlayerView(player: Player(photoUrl: photoUrl, username: "Samuel", hp: 50, maxHp: 100, attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses), rounds: [])
        PlayerView(player: Player(photoUrl: photoUrl, username: "Brandon", hp: 20, maxHp: 100, attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses), rounds: [])
        PlayerView(player: Player(photoUrl: photoUrl, username: "Brandon", hp: 0, maxHp: 100, attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses), rounds: [])
    }
}
