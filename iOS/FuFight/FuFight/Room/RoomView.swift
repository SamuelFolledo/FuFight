//
//  RoomView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/5/24.
//

import SwiftUI

struct RoomView: View {
    @StateObject var vm: RoomViewModel
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader { value in
                ZStack {
                    VStack {
                        navigationView

                        Spacer()

                        VStack {
                            CharacterListView(selectedFighterType: $vm.selectedFighterType)
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

                Text("\(vm.selectedFighterType?.name ?? "")")
                    .font(mediumTitleFont)
                    .foregroundStyle(.white)

                Spacer()
            }
        }
        .padding(.horizontal, smallerHorizontalPadding)
    }
}

#Preview {
    RoomView(vm: RoomViewModel(account: fakeAccount))
}

