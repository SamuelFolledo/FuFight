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
    @Published var showBuyFighterAlert: Bool = false
    @Published var fighterToBuy: FighterType? = nil
    @Published var isPurchasingWithDiamond: Bool = false

    let playerType: PlayerType = .user
    let roomBottomButtons: [RoomButtonType] = RoomButtonType.allCases

    //MARK: - Override Methods
    override func onAppear() {
        super.onAppear()
    }

    //MARK: - Public Methods
    func loadFighters() {
        fighters = FighterType.allCases.compactMap { CharacterObject(fighterType: $0) }
            .sorted(by: { $0 < $1 })
    }

    func buyFighter(_ fighterType: FighterType, isDiamond: Bool) {
        if isDiamond && (account.diamonds - fighterType.diamondCost) < 0 {
            //Not enough diamonds
            return
        } else if !isDiamond && (account.coins - fighterType.coinCost) < 0 {
            //Not enough coins
            return
        }
        isPurchasingWithDiamond = isDiamond
        fighterToBuy = fighterType
        showBuyFighterAlert.toggle()
    }

    func unlockFighter() {
        guard let fighterToBuy else { return }
        TODO("Unlock \(fighterToBuy.name)")
    }
}

private extension RoomViewModel {

}
