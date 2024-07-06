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
    @Published var selectedFighterType: FighterType? = nil

    let playerType: PlayerType = .user

    //MARK: - Override Methods
    override func onAppear() {
        super.onAppear()
    }

    //MARK: - Public Methods

}

private extension RoomViewModel {

}
