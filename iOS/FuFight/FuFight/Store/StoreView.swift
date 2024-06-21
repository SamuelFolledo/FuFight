//
//  StoreView.swift
//  FuFight
//
//  Created by Samuel Folledo on 5/25/24.
//

import SwiftUI

struct StoreView: View {
    @StateObject var vm: StoreViewModel

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                ZStack {
                    VStack {
                        navigationView

                        VStack {

                            Spacer()
                        }
                        .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
                        .padding()
                    }
                    .padding(.top, UserDefaults.topSafeAreaInset)
                    .padding(.bottom, UserDefaults.bottomSafeAreaInset)
                }
            }
            .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
            .overlay {
                LoadingView(message: vm.loadingMessage)
            }
            .background(
                backgroundImage
                    .padding(.leading, 30)
            )
            .safeAreaInset(edge: .bottom) {
                VStack {
//                    playButton
//
//                    offlinePlayButton
//
//                    practiceButton
                }
                .padding(.bottom)
            }
            .navigationBarHidden(true)
            .frame(maxWidth: .infinity)
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
        HStack {
            Spacer()

            Text("Store")
                .font(mediumTitleFont)
                .foregroundStyle(.white)

            Spacer()
        }
        .padding(.horizontal, smallerHorizontalPadding)
    }

    var accountImage: some View {
        NavigationLink(destination: AccountView(vm: AccountViewModel(account: vm.account))) {
            AccountImage(url: vm.account.photoUrl, radius: 30)
        }
    }

    //    var playButton: some View {
    //        Button {
    //            vm.transitionToLoading.send(vm)
    //        } label: {
    //            Image("playButton")
    //                .frame(width: 200)
    //        }
    //    }

    //    var offlinePlayButton: some View {
    //        Button {
    //            vm.transitionToOffline.send(vm)
    //        } label: {
    //            Text("Offline Play")
    //                .padding(6)
    //                .frame(maxWidth: .infinity)
    //                .foregroundStyle(Color(uiColor: .systemBackground))
    //                .font(.title)
    //                .background(Color(uiColor: .label))
    //                .clipShape(RoundedRectangle(cornerRadius: 16))
    //        }
    //        .padding(.horizontal)
    //        .padding(.bottom, 4)
    //    }
}

#Preview {
    StoreView(vm: StoreViewModel(account: fakeAccount))
}
