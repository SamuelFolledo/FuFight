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
    case updatePassword(vm: UpdatePasswordViewModel)

    var id: String {
        switch self {
        case .loading(_):
            "loading"
        case .game(_):
            "game"
        case .account(_):
            "account"
        case .updatePassword(_):
            "updatePassword"
        }
    }

    static func == (lhs: HomeRoute, rhs: HomeRoute) -> Bool {
        return lhs.id == rhs.id
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
        // Sets the background color of the Picker
        UISegmentedControl.appearance().backgroundColor = .black.withAlphaComponent(0.8)
        // Disappears the divider
        UISegmentedControl.appearance().setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        // Changes the color for the selected item
        UISegmentedControl.appearance().selectedSegmentTintColor = .systemYellow
        // Changes the text color for the selected item
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont(name: CustomFontWeight.bold.rawValue, size: defaultFontSize)!], for: .selected)
        // Changes the text color for the unselected item
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.lightGray, .font: UIFont(name: CustomFontWeight.bold.rawValue, size: defaultFontSize)!], for: .normal)

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
            navigationPath.append(.loading(vm: makeLoadingViewModel(account: vm.account)))
        case .offlineGame, .practice:
            navigationPath.append(.game(vm: makeGameViewModel(enemy: fakeEnemyPlayer,
                                                              gameMode: route)))
        }
    }

    func transitionToAccount(vm: HomeViewModel) {
        navigationPath.append(.account(vm: makeAccountViewModel(account: vm.account)))
    }

    //MARK: - AccountView Methods
    func makeAccountViewModel(account: Account) -> AccountViewModel {
        let vm = AccountViewModel(account: account)
        vm.didBack
            .sink(receiveValue: { _ in
                self.navigateBack()
            })
            .store(in: &subscriptions)
        vm.didChangePassword
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                navigationPath.append(.updatePassword(vm: makeUpdatePasswordViewModel(account: account)))
            })
            .store(in: &subscriptions)
        return vm
    }


    func transitionToUpdatePassword(vm: AccountViewModel) {
        navigationPath.append(.account(vm: makeAccountViewModel(account: vm.account)))
    }

    //MARK: - UpdatePassword Methods
    func makeUpdatePasswordViewModel(account: Account) -> UpdatePasswordViewModel {
        let vm = UpdatePasswordViewModel()
        vm.didBack
            .sink(receiveValue: { _ in
                self.navigateBack()
            })
            .store(in: &subscriptions)
        return vm
    }

    //MARK: - GameLoadingView Methods
    func makeLoadingViewModel(account: Account) -> GameLoadingViewModel {
        let vm = GameLoadingViewModel(account: account)
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
        guard let game = vm.game else {
            LOGE("Failed to load GameView with missing game")
            return
        }
        let player = Player(fetchedPlayer: game.player, isEnemy: false, isGameOwner: !vm.isChallenger, initiallyHasSpeedBoost: game.playerInitiallyHasSpeedBoost)
        let enemyPlayer = Player(fetchedPlayer: game.enemy, isEnemy: true, isGameOwner: vm.isChallenger, initiallyHasSpeedBoost: !game.playerInitiallyHasSpeedBoost)
        navigationPath.append(.game(vm: makeGameViewModel(enemy: enemyPlayer, gameMode: .onlineGame)))
    }

    //MARK: - GameView Methods
    func makeGameViewModel(enemy: Player, gameMode: GameRoute) -> GameViewModel {
        let vm = GameViewModel(enemy: enemy, gameMode: gameMode)
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
