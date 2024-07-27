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

    func buyFighter(_ fighterType: FighterType) {
        TODO("Buying \(fighterType.name)")
        fighterToBuy = fighterType
        showBuyFighterAlert.toggle()
    }
}

private extension RoomViewModel {

}
