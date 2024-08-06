//
//  Router.swift
//  FuFight
//
//  Created by Samuel Folledo on 8/4/24.
//

import Combine

class Router<T>: ObservableObject {
    @Published var navigationPath: [T] = []

    var subscriptions = Set<AnyCancellable>()

    //MARK: - Methods

    func navigateBack() {
        navigationPath.removeLast()
    }

    func navigateToRoot() {
        navigationPath.removeAll()
    }
}
