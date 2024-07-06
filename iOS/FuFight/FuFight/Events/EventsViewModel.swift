//
//  EventsViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/6/24.
//

import Combine
import SwiftUI
import SceneKit

final class EventsViewModel: BaseAccountViewModel {
    @Published var selectedFighterType: FighterType? = nil

    let playerType: PlayerType = .user

    //MARK: - Override Methods
    override func onAppear() {
        super.onAppear()
    }

    //MARK: - Public Methods

}

private extension EventsViewModel {

}
