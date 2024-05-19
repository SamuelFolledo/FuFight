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
    @StateObject var homeRouter: HomeRouter = HomeRouter()
    @StateObject var account: Account = Account.current ?? Account()
    var subscriptions = Set<AnyCancellable>()

    var body: some View {
        switch account.status {
        case .online:
            //Go to home page
            TabView {
                NavigationStack(path: $homeRouter.navigationPath) {
                    VStack {
                        HomeView(vm: homeRouter.makeHomeViewModel(account: account))
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
                    AccountView(vm: homeRouter.makeAccountViewModel(account: account))
                }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
            .accentColor(Color.white)
            .transition(.move(edge: .trailing))

        case .unfinished:
            //Finish creating account
            createAuthenticationView(step: .onboard)

        case .logOut:
            //Log in
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
        ContentView(homeRouter: HomeRouter())
    }
}
