//
//  ContentView.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/19/24.
//

import SwiftUI
import Combine

///Root view that handles which view to show
///Source: https://medium.com/@sarimk80/navigationstack-with-viewmodel-c0ec223cf16b
///Source: https://betterprogramming.pub/flow-navigation-with-swiftui-4-e006882c5efa
struct ContentView: View {
    @StateObject var homeCoordinator: HomeCoordinator = HomeCoordinator()
    @StateObject var account: Account = Account.current ?? Account()
    var subscriptions = Set<AnyCancellable>()

    var body: some View {
        switch account.status {
        case .online:
            TabView {
                NavigationStack(path: $homeCoordinator.navigationPath) {
                    VStack {
                        HomeView(vm: homeCoordinator.makeHomeViewModel(account: account))
                    }
                    .navigationDestination(for: HomeRoute.self) { screen in
                        switch screen {
                        case .loading(vm: let vm):
                            GameLoadingView(vm: vm)
                        case .game(vm: let vm):
                            GameView(vm: vm)
                        case .account(vm: let vm):
                            AccountView(vm: vm)
                        }
                    }
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }

                NavigationStack {
                    AccountView(vm: homeCoordinator.makeAccountViewModel(account: account))
                    //.environmentObject(AccountViewModel)
                }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
            .accentColor(Color.white)
            .transition(.move(edge: .trailing))

        case .unfinished:
            createAuthenticationView(step: .onboard)

        case .logOut:
            createAuthenticationView(step: .logIn)
        }
    }

    @ViewBuilder func createAuthenticationView(step: AuthStep) -> some View {
        AuthenticationView(vm: AuthenticationViewModel(step: step, account: account))
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .transition(.move(edge: .leading))
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(homeCoordinator: HomeCoordinator())
    }
}
