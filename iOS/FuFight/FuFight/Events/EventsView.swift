//
//  EventsView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/6/24.
//

import SwiftUI

struct EventsView: View {
    @StateObject var vm: EventsViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader { value in
                ZStack {
                    VStack {
                        navigationView

                        Spacer()

                        VStack {
                            
                        }
                    }
                    .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
                    .padding(.top, homeNavBarHeight + 6)
                    .padding(.bottom, UserDefaults.bottomSafeAreaInset + 50)
                }
            }
        }
        .overlay {
            LoadingView(message: vm.loadingMessage)
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity)
        .background {
            AnimatingBackgroundView(animate: true, leadingPadding: -1700)
        }
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
        .allowsHitTesting(vm.loadingMessage == nil)
    }

    var navigationView: some View {
        ZStack {
            HStack {
                Spacer()
            }

            HStack {
                Spacer()

                Text("Events coming soon")
                    .font(mediumTitleFont)
                    .foregroundStyle(.white)

                Spacer()
            }
        }
        .padding(.horizontal, smallerHorizontalPadding)
    }
}

#Preview {
    EventsView(vm: EventsViewModel(account: fakeAccount))
}

