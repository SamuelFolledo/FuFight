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
            ScrollViewReader { value in
                ZStack {
                    VStack {
                        navigationView

                        Spacer()

                        VStack {
                            
                        }
                    }
                    .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
                    .padding(.top, UserDefaults.topSafeAreaInset + 6)
                    .padding(.bottom, UserDefaults.bottomSafeAreaInset + 50)
                }
            }
        }
        .overlay {
            LoadingView(message: vm.loadingMessage)
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity)
        .background(
            backgroundImage
                .padding(.leading, 30)
        )
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

                Text("School coming soon")
                    .font(mediumTitleFont)
                    .foregroundStyle(.white)

                Spacer()
            }
        }
        .padding(.horizontal, smallerHorizontalPadding)
    }
}

#Preview {
    SchoolView(vm: SchoolViewModel(account: fakeAccount))
}

