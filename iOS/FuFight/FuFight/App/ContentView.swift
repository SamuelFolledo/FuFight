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
        GeometryReader { reader in
            switch account.status {
            case .loggedIn:
                //Views for each Tab
                TabView(selection: $tab) {
                    ForEach(tabs, id: \.self) { tab in
                        tabBarView(tab)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never)) //adds swipe gesture and sliding effect when switching between tabs
                .overlay {
                    VStack {
                        Spacer()

                        if showTab {
                            //MARK: - TabBar
                            HStack(alignment: .bottom, spacing: 1) {
                                ForEach(tabs, id: \.self) { currentTab in
                                    tabBarItem(currentTab)
                                }
                            }
                            .transition(.move(edge: .bottom))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .onAppear {
                    UserDefaults.topSafeAreaInset = reader.safeAreaInsets.top
                    UserDefaults.bottomSafeAreaInset = reader.safeAreaInsets.bottom
                }
                .ignoresSafeArea()
            case .unfinished:
                //Finish creating account
                createAuthenticationView(step: .onboard)

            case .loggedOut:
                //Log in
                createAuthenticationView(step: .logIn)
            }
        }
    }

    var roomView: some View {
        let roomVm = RoomViewModel(account: account)
        return NavigationStack {
            RoomView(vm: roomVm)
        }
        .tag(Tab.edit)
        .onAppear {
            if tab == .edit {
                //Required to trigger onAppear when switching between tabs
                roomVm.onAppear()
            }
        }
    }

    var homeView: some View {
        let homeVm = homeRouter.makeHomeViewModel(account: account)
        return NavigationStack(path: $homeRouter.navigationPath) {
            HomeView(vm: homeVm)
                .navigationDestination(for: HomeRoute.self) { screen in
                    switch screen {
                    case .loading(vm: let vm):
                        GameLoadingView(vm: vm)
                    case .game(vm: let vm):
                        GameView(vm: vm)
                    case .account(vm: let vm):
                        AccountView(vm: vm)
                    case .updatePassword(vm: let vm):
                        UpdatePasswordView(vm: vm)
                    }
                }
        }
        .tag(Tab.home)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            scenePhaseChangedHandler(newPhase)
        }
        .onChange(of: homeRouter.navigationPath) { _, newValue in
            withAnimation(.easeInOut(duration: 0.2)) {
                self.showTab = newValue.isEmpty
            }
        }
        .onAppear {
            if tab == .home {
                //Required to trigger onAppear when switching between tabs
                homeVm.onAppear()
            }
        }
    }

    var storeView: some View {
        let storeVm = StoreViewModel(account: account)
        return NavigationStack {
            StoreView(vm: storeVm)
        }
        .tag(Tab.store)
        .onAppear {
            if tab == .store {
                //Required to trigger onAppear when switching between tabs
                storeVm.onAppear()
            }
        }
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
        let selectedColor = Color.yellow
        let unselectedColor = Color.white
        return VStack(spacing: 0) {
            //Selected TabBar item's extra padding
            Group {
                tab == currentTab ? selectedColor : unselectedColor
            }
            .frame(height: tab == currentTab ? 8 : 0)

            //TabBar item
            Button(action: { withAnimation(.easeInOut) {
                tab = currentTab
            }}) {
                VStack {
                    Spacer()
                        .frame(height: 10)
                    Image(systemName: currentTab.systemImage)
                        .frame(width: 25, height: 25)
                    Text(currentTab.title)
                        .font(tabFont)
                    Spacer()
                        .frame(height: UserDefaults.bottomSafeAreaInset / 2)
                }
                .frame(maxWidth: .infinity)
                .padding(4)
                .background(
                    //Selected tab background
                    Group {
                        if currentTab == tab {
                            Rectangle()
                                .foregroundColor(selectedColor)
                                .matchedGeometryEffect(id: "selectedTabRoundedRectangle", in: namespace)
                        } else {
                            EmptyView()
                        }
                    }
                )
            }
            .foregroundColor(tab == currentTab ? blackColor : unselectedTabColor)
            .background(
                Rectangle()
                    .foregroundColor(unselectedColor)
            )
        }
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
