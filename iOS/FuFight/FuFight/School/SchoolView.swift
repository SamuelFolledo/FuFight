//
//  SchoolView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/6/24.
//

import SwiftUI

struct SchoolView: View {
    @StateObject var vm: SchoolViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                Spacer()

                VStack {

                }

                Spacer()
            }
            .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
            .background {
                Color.blackLight
            }
        }
        .overlay {
            LoadingView(message: vm.loadingMessage)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, homeNavBarHeight + 6)
        .padding(.bottom, homeTabBarHeight)
        .navigationBarHidden(true)
        .background {
            AnimatingBackgroundView(animate: true, leadingPadding: -1300)
        }
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
        .allowsHitTesting(vm.loadingMessage == nil)
        .overlay {
            Color.blackLight
                .opacity(0.6)
                .padding(.top, homeNavBarHeight + 6)
                .padding(.bottom, UserDefaults.bottomSafeAreaInset + 50)
                .overlay {
                    AppText("School games coming soon", type: .titleLarge)
                        .frame(alignment: .center)
                        .padding(.horizontal)
                }
        }
    }
}

#Preview {
    SchoolView(vm: SchoolViewModel(account: fakeAccount))
}

