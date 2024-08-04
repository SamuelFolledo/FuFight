//
//  RoomViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/5/24.
//

import Combine
import SwiftUI
import SceneKit

final class RoomViewModel: BaseAccountViewModel {
    @Published var selectedFighterType: FighterType? = Room.current?.player.fighterType {
        didSet {
            let room = Room.current
            room?.player.fighterType = selectedFighterType!
            RoomManager.saveCurrent(room!)
        }
    }
    @Published var selectedBottomButtonIndex: Int = 0
    @Published var showBottomButtonDropDown: Bool = false
    @Published var fighters: [CharacterObject] = []
    @Published var showUnlockFighterView: Bool = false
    @Published var fighterToBuy: FighterType? = nil
    @Published var isPurchasingWithDiamond: Bool = false
    @Published var showInsufficientDiamondsAlert: Bool = false
    @Published var showInsufficientCoinsAlert: Bool = false

    let playerType: PlayerType = .user
    let roomBottomButtons: [RoomButtonType] = RoomButtonType.allCases

    //MARK: - Override Methods
    override func onAppear() {
        super.onAppear()
    }

    //MARK: - Public Methods
    func loadFighters() {
        let unlockedFighters = Room.current?.unlockedFighterIds ?? []
        fighters = FighterType.allCases.compactMap { CharacterObject(fighterType: $0, status: unlockedFighters.contains($0.id) ? .unlocked : .locked) }
            .sorted(by: { $0 < $1 })
    }

    func showUnlockFighterAlert(_ fighterType: FighterType, isDiamond: Bool) {
        if isDiamond && (account.diamonds - fighterType.diamondCost) < 0 {
            //Using diamonds but not enough
            showInsufficientDiamondsAlert.toggle()
            return
        } else if !isDiamond && (account.coins - fighterType.coinCost) < 0 {
            //Using coins but not enough
            showInsufficientCoinsAlert.toggle()
            return
        }
        isPurchasingWithDiamond = isDiamond
        fighterToBuy = fighterType
        showUnlockFighterView = true
    }

    func unlockFighter() {
        guard let fighterToBuy,
            let room = Room.current else { return }
        Task {
            updateLoadingMessage(to: "Unlocking fighter")
            //Update account's currency
            if isPurchasingWithDiamond {
                account.diamonds -= fighterToBuy.diamondCost
            } else {
                account.coins -= fighterToBuy.coinCost
            }
            try await AccountNetworkManager.setData(account: account)
            try await AccountManager.saveCurrent(account)
            //Update room's unlocked fighters
            room.unlockedFighterIds.append(fighterToBuy.id)
            try await RoomNetworkManager.updateRoom(room)
            try await RoomManager.saveCurrent(room)
            loadFighters()
            updateLoadingMessage(to: nil)
            showUnlockFighterView = false
        }
    }
}

private extension RoomViewModel {

}
