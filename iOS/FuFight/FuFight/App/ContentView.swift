//
//  ContentView.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/19/24.
//

import SwiftUI
import Combine

enum Tab: String, CaseIterable, Identifiable {
    case edit
    case home
    case store

    var id: Self { self }

    var title: String {
        switch self {
        case .edit:
            "Edit"
        case .home:
            "Play"
        case .store:
            "Store"
        }
    }

    var systemImage: String {
        switch self {
        case .edit:
            "applepencil.gen1"
        case .home:
            "house"
        case .store:
            "storefront"
        }
    }
}

///Root view that handles which view to show
///Source: https://medium.com/@sarimk80/navigationstack-with-viewmodel-c0ec223cf16b
///Source: https://betterprogramming.pub/flow-navigation-with-swiftui-4-e006882c5efa
struct ContentView: View {
    @StateObject var homeRouter: HomeRouter = HomeRouter()
    @StateObject var account: Account = Account.current ?? Account()
    @State var showTab: Bool = true
    @State var tab: Tab = .home
    private let tabs: [Tab] = [.edit, .home, .store]
    var subscriptions = Set<AnyCancellable>()

    @Namespace var namespace
    @Environment(\.scenePhase) var scenePhase

    //MARK: - Views
    var body: some View {
        switch account.status {
        case .loggedIn:
            ZStack(alignment: .bottom) {
                //Go to home page
                TabView(selection: $tab) {
                    ForEach(tabs, id: \.self) { tab in
                        tabBarView(tab)
                    }
                }
                .navigationViewStyle(.stack)
                .edgesIgnoringSafeArea(.vertical)

                //MARK: - TabBar
                if showTab {
                    HStack(spacing: 1) {
                        ForEach(tabs, id: \.self) { tab in
                            tabBarItem(tab)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .frame(height: 80, alignment: .center)
                    .frame(maxWidth: 320)
                }
            }
        case .unfinished:
            //Finish creating account
            createAuthenticationView(step: .onboard)

        case .loggedOut:
            //Log in
            createAuthenticationView(step: .logIn)
        }
    }

    var roomView: some View {
        NavigationStack {
            RoomView(vm: RoomViewModel(account: account))
        }
        .tag(Tab.edit)
    }

    var homeView: some View {
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
        .tag(Tab.home)
        .navigationViewStyle(.stack)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            scenePhaseChangedHandler(newPhase)
        }
        .onChange(of: homeRouter.navigationPath) { _, newValue in
            showTab = newValue.isEmpty
        }
    }

    var storeView: some View {
        NavigationStack {
            StoreView(vm: StoreViewModel(account: account))
        }
        .tag(Tab.store)
    }

    //MARK: - Methods
}

private extension ContentView {
    func scenePhaseChangedHandler(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .background:
            LOGD("App is backgrounded and will be terminated soon")
            appTerminatedHandler()
        case .inactive:
            LOGD("App is inactive")
        case .active:
            LOGD("App is active")
            appIsForegroundedHandler()
        @unknown default:
            break
        }
    }

    func tabBarItem(_ currentTab: Tab) -> some View {
        let cornerRadius: CGFloat = 4
        return Button(action: { withAnimation(.easeInOut) {
            tab = currentTab
        }}) {
            VStack {
                Image(systemName: currentTab.systemImage)
                    .frame(width: 20, height: 20)
                Text(currentTab.title)
                    .font(tabFontSize)
            }
            .frame(maxWidth: .infinity)
            .padding(4)
            .background(
                Group {
                    if currentTab == tab {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .foregroundColor(.yellow)
                            .matchedGeometryEffect(id: "selectedTabRoundedRectangle", in: namespace)
                    } else {
                        EmptyView()
                    }
                }
            )
        }
        .foregroundColor(tab == currentTab ? primaryColor : unselectedTabColor)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundColor(.white)
        )
    }

    func tabBarView(_ currentTab: Tab) -> some View {
        Group {
            switch currentTab {
            case .edit:
                roomView
            case .home:
                homeView
            case .store:
                storeView
            }
        }
    }

    @ViewBuilder func createAuthenticationView(step: AuthStep) -> some View {
        AuthenticationView(vm: AuthenticationViewModel(step: step, account: account))
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .transition(.move(edge: .leading))
    }

    func appTerminatedHandler() {
        RoomManager.goOffline()
    }

    func appIsForegroundedHandler() {
        RoomManager.goOnlineIfNeeded()
    }
}

#Preview {
    ContentView()
}
