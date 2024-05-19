//
//  HomeView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject var vm: HomeViewModel

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                ZStack {
                    DaePreview()
                        .frame(width: proxy.size.width, height: proxy.size.height)

                    VStack {
                        navigationView

                        VStack {
                            Text("Welcome \(vm.account.displayName)")
                                .font(mediumTitleFont)
                                .foregroundStyle(.white)

                            Spacer()
                        }
                        .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
                        .padding()
                    }
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
                    playButton

                    offlinePlayButton

                    practiceButton
                }
                .padding(.bottom)
            }
            .navigationBarHidden(true)
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            vm.onAppear()
            if !vm.isAccountVerified {
                vm.verifyAccount()
            }
        }
        .onDisappear {
            vm.onDisappear()
        }
        .allowsHitTesting(vm.loadingMessage == nil)
    }

    var navigationView: some View {
        HStack {
            accountImage

            Spacer()
        }
        .padding(.horizontal, smallerHorizontalPadding)
    }

    var accountImage: some View {
        NavigationLink(destination: AccountView(vm: AccountViewModel(account: vm.account))) {
            AccountImage(url: vm.account.photoUrl, radius: 30)
        }
    }

    var playButton: some View {
        Button {
            vm.transitionToLoading.send(vm)
        } label: {
            Image("playButton")
                .frame(width: 200)
        }
    }

    var offlinePlayButton: some View {
        Button {
            vm.transitionToOffline.send(vm)
        } label: {
            Text("Offline Play")
                .padding(6)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color(uiColor: .systemBackground))
                .font(.title)
                .background(Color(uiColor: .label))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }

    var practiceButton: some View {
        Button {
            vm.transitionToPractice.send(vm)
        } label: {
            Text("Practice")
                .padding(6)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color(uiColor: .label))
                .font(.title)
                .background(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }
}

#Preview {
    HomeView(vm: HomeViewModel(account: fakeAccount))
}
