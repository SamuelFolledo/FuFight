//
//  RoomRouter.swift
//  FuFight
//
//  Created by Samuel Folledo on 8/4/24.
//

import SwiftUI
import Combine

enum RoomRoute: Hashable, Identifiable {
    case characterDetail(vm: CharacterDetailViewModel)

    var id: String {
        switch self {
        case .characterDetail(_):
            "characterDetail"
        }
    }

    static func == (lhs: RoomRoute, rhs: RoomRoute) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}

///In charge of view model creations and view transitions
class RoomRouter: Router<RoomRoute> {

    //MARK: - Home Methods
    func makeRoomViewModel(account: Account) -> RoomViewModel {
        let vm = RoomViewModel(account: account)
        vm.transitionToFighterDetail
            .sink(receiveValue: transitionToFighterDetail)
            .store(in: &subscriptions)
        return vm
    }

    func transitionToFighterDetail(vm: RoomViewModel) {
        navigationPath.append(.characterDetail(vm: makeCharacterDetailViewModel(account: vm.account)))
    }

    //MARK: - AccountView Methods
    func makeCharacterDetailViewModel(account: Account) -> CharacterDetailViewModel {
        let vm = CharacterDetailViewModel(account: account)
//        vm.didBack
//            .sink(receiveValue: { _ in
//                self.navigateBack()
//            })
//            .store(in: &subscriptions)
        return vm
    }
}
