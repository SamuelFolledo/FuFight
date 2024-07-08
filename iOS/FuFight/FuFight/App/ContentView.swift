//
//  ContentView.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/19/24.
//

import SwiftUI
import Combine

enum Tab: String, CaseIterable, Identifiable {
    case store
    case collections
    case home
    case school
    case events

    var id: Self { self }

    var title: String {
        switch self {
        case .store:
            "Store"
        case .collections:
            "Collections"
        case .home:
            "Play"
        case .school:
            "School"
        case .events:
            "Events"
        }
    }

    var systemImage: String {
        switch self {
        case .store:
            "storefront"
        case .collections:
            "applepencil.gen1"
        case .home:
            "house"
        case .school:
            "graduationcap"
        case .events:
            "party.popper"
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
    @State var showNav: Bool = true
    @State var tab: Tab = .home
    private let tabs: [Tab] = Tab.allCases
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
                        if showNav {
                            navBarView()
                        }

                        Spacer()

                        if showTab {
                            VStack(spacing: 4) {
                                Spacer()

                                //TODO: Add FighterType and buttons overlay
                                homeBottomView()

                                //MARK: - TabBar
                                HStack(alignment: .bottom, spacing: 1) {
                                    ForEach(tabs, id: \.self) { currentTab in
                                        tabBarItem(currentTab, reader: reader)
                                    }
                                }
                                .transition(.move(edge: .bottom))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
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

    @ViewBuilder func navBarView() -> some View {
        VStack {
            Color.black
                .frame(height: UserDefaults.topSafeAreaInset)
                .frame(maxWidth: .infinity)
                .mask(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .bottom, endPoint: .top))

            HStack {
                Color.white

                HStack(spacing: 12) {
                    Button(action: {
                        TODO("Buying more coins")
                    }, label: {
                        HStack(spacing: 2) {
                            coinImage
                                .frame(width: navBarIconSize, height: navBarIconSize, alignment: .center)

                            Text("812999")
                                .font(navBarFont)
                                .foregroundStyle(Color.white)

                            Spacer()
                        }
                    })
                    .background {
                        navBarContainerImage
                    }

                    Button(action: {
                        TODO("Buy diamonds")
                    }, label: {
                        HStack(spacing: 2) {
                            diamondImage
                                .frame(width: navBarIconSize, height: navBarIconSize, alignment: .center)

                            Text("209")
                                .font(navBarFont)
                                .foregroundStyle(Color.white)
                                .frame(alignment: .center)

                            Spacer()
                        }
                    })
                    .background {
                        navBarContainerImage
                    }
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.bottom, 4)
            .padding(.horizontal, 8)
        }
        .frame(height: homeNavBarHeight)
        .frame(maxWidth: .infinity)
        .transition(.move(edge: .top))
        .background {
            VStack(spacing: 0) {
                Image("navBarBackground")
                    .navBarBackgroundImageModifier()

            }
        }
    }

    @ViewBuilder func homeBottomView() -> some View {
        switch tab {
        case .store, .collections:
            EmptyView()
        case .home, .school, .events:
            HStack {
                Image(Room.current?.player.fighterType.headShotImageName ?? "")
                    .defaultImageModifier()

                Spacer()
            }
            .background {
                Color.clear
            }
            .frame(height: homeBottomViewHeight)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, smallerHorizontalPadding)
            .allowsHitTesting(false)
            .transition(.move(edge: .bottom))
        }
    }

//    var characterDetailView: some View {
//        let roomVm = CharacterDetailViewModel(account: account)
//        return NavigationStack {
//            CharacterDetailView(vm: roomVm)
//                .onAppear {
//                    if tab == .edit {
//                        LOG("Roomview is showing")
//                    }
//                }
//        }
//        .tag(Tab.edit)
//        .onAppear {
//            if tab == .edit {
//                //Required to trigger onAppear when switching between tabs
//                LOG("Roomview is showing")
//                roomVm.onAppear()
//            }
//        }
//    }

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

    var roomView: some View {
        let vm = RoomViewModel(account: account)
        return NavigationStack {
            RoomView(vm: vm)
        }
        .tag(Tab.collections)
        .onAppear {
            if tab == .collections {
                //Required to trigger onAppear when switching between tabs
                vm.onAppear()
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
                let isShowingGame = newValue.compactMap { $0.id }.contains("game")
                self.showNav = !isShowingGame
            }
        }
        .onAppear {
            if tab == .home {
                //Required to trigger onAppear when switching between tabs
                homeVm.onAppear()
            }
        }
    }

    var schoolView: some View {
        let vm = SchoolViewModel(account: account)
        return NavigationStack {
            SchoolView(vm: vm)
        }
        .tag(Tab.school)
        .onAppear {
            if tab == .school {
                //Required to trigger onAppear when switching between tabs
                vm.onAppear()
            }
        }
    }

    var eventsView: some View {
        let vm = EventsViewModel(account: account)
        return NavigationStack {
            EventsView(vm: vm)
        }
        .tag(Tab.events)
        .onAppear {
            if tab == .events {
                //Required to trigger onAppear when switching between tabs
                vm.onAppear()
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

    func tabBarItem(_ currentTab: Tab, reader: GeometryProxy) -> some View {
        let selectedColor = Color.yellow
        let unselectedColor = Color.white
        let offset: CGFloat = 8
        let unselectedTabItemWidth = reader.size.width / CGFloat(Tab.allCases.count) - offset
        let selectedTabItemWidth = unselectedTabItemWidth + CGFloat(Tab.allCases.count) * offset
        return VStack(spacing: 0) {
            //Selected TabBar item's extra padding
            Group {
                tab == currentTab ? selectedColor : unselectedColor
            }
            .frame(height: tab == currentTab ? 2 : 0)

            //TabBar item
            Button(action: { withAnimation(.easeInOut) {
                tab = currentTab
            }}) {
                VStack {
                    Spacer()
                        .frame(height: 12)

                    Image(systemName: currentTab.systemImage)
                        .frame(width: 35, height: 35)

                    if tab == currentTab {
                        Text(currentTab.title)
                            .font(tabFont)
                    }

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
        .frame(width: tab == currentTab ? selectedTabItemWidth : unselectedTabItemWidth)
    }

    func tabBarView(_ currentTab: Tab) -> some View {
        Group {
            switch currentTab {
            case .store:
                storeView
            case .collections:
                roomView
            case .home:
                homeView
            case .school:
                schoolView
            case .events:
                eventsView
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
