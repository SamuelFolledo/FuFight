//
//  HomeRouter.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/19/24.
//

import SwiftUI
import Combine

enum HomeRoute: Hashable, Identifiable {
    case loading(vm: GameLoadingViewModel)
    case game(vm: GameViewModel)
    case account(vm: AccountViewModel)

    var id: String {
        switch self {
        case .loading(_):
            "loading"
        case .game(_):
            "game"
        case .account(_):
            "account"
        }
    }

    static func == (lhs: HomeRoute, rhs: HomeRoute) -> Bool {
        return lhs.id == lhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}

///In charge of view model creations and view transitions
class HomeRouter: ObservableObject {
    @Published var navigationPath: [HomeRoute] = []
    var subscriptions = Set<AnyCancellable>()

    init() {
        //Change TabView background color
        UITabBar.appearance().backgroundColor = UIColor.clear
        UITabBar.appearance().backgroundImage = UIImage()
        //Change TabItem (text + icon) color
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }

    //MARK: - Home Methods
    func makeHomeViewModel(account: Account) -> HomeViewModel {
        let vm = HomeViewModel(account: account)
        vm.transitionToLoading
            .sink(receiveValue: { vm in
                self.transitionTo(route: .onlineGame, vm: vm)
            })
            .store(in: &subscriptions)
        vm.transitionToOffline
            .sink(receiveValue: { vm in
                self.transitionTo(route: .offlineGame, vm: vm)
            })
            .store(in: &subscriptions)
        vm.transitionToPractice
            .sink(receiveValue: { vm in
                self.transitionTo(route: .practice, vm: vm)
            })
            .store(in: &subscriptions)
        vm.transitionToAccount
            .sink(receiveValue: transitionToAccount)
            .store(in: &subscriptions)
        return vm
    }

    func transitionTo(route: GameRoute, vm: HomeViewModel) {
        switch route {
        case .onlineGame:
            //show loading and let loading handle transition to online game
            if let player = vm.player {
                if let enemyPlayer = vm.enemyPlayer {
                    TODO("Handle returning to current online game for \(player.username) vs \(enemyPlayer.username)")
                } else {
                    let nextVm: HomeRoute = .loading(vm: makeLoadingViewModel(player: player, enemyPlayer: vm.enemyPlayer, account: vm.account))
                    navigationPath.append(nextVm)
                }
            }
        case .offlineGame:
            navigationPath.append(.game(vm: makeGameViewModel(isPracticeMode: false, player: vm.player ?? fakePlayer, enemyPlayer: fakeEnemyPlayer)))
        case .practice:
            navigationPath.append(.game(vm: makeGameViewModel(isPracticeMode: true, player: vm.player ?? fakePlayer, enemyPlayer: fakeEnemyPlayer)))
        }
    }

    func transitionToAccount(vm: HomeViewModel) {
        navigationPath.append(.account(vm: makeAccountViewModel(account: vm.account)))
    }

    //MARK: - AccountView Methods
    func makeAccountViewModel(account: Account) -> AccountViewModel {
        return AccountViewModel(account: account)
    }

    //MARK: - GameLoadingView Methods
    func makeLoadingViewModel(player: Player, enemyPlayer: Player? = nil, account: Account) -> GameLoadingViewModel {
        let vm = GameLoadingViewModel(player: player, enemyPlayer: enemyPlayer, account: account)
        vm.didCancel
            .sink(receiveValue: { _ in
                self.navigateToRoot()
            })
            .store(in: &subscriptions)
        vm.didFindEnemy
            .sink(receiveValue: didCompleteLoading)
            .store(in: &subscriptions)
        return vm
    }

    func didCompleteLoading(vm: GameLoadingViewModel) {
        if let enemyPlayer = vm.enemyPlayer {
            navigationPath.append(.game(vm: makeGameViewModel(isPracticeMode: false, player: vm.player, enemyPlayer: enemyPlayer)))
        }
    }

    //MARK: - GameView Methods
    func makeGameViewModel(isPracticeMode: Bool, player: Player, enemyPlayer: Player) -> GameViewModel {
        let vm = GameViewModel(isPracticeMode: isPracticeMode, player: player, enemyPlayer: enemyPlayer)
        vm.didExitGame
            .sink(receiveValue: didExitGame)
            .store(in: &subscriptions)
        return vm
    }

    func didExitGame(vm: GameViewModel) {
        navigateToRoot()
    }

    //MARK: - Private methods
    private func navigateBack() {
        navigationPath.removeLast()
    }

    private func navigateToRoot() {
        navigationPath.removeAll()
    }
}
