//
//  PopupView.swift
//  FuFight
//
//  Created by Samuel Folledo on 7/18/24.
//

import SwiftUI

struct PopupView<Content: View>: View {
    @Binding var isShowing: Bool
    let content: Content

    var body: some View {
            ZStack {
                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                dimViewBackground
                    .onTapGesture {
                        shouldShow(false)
                    }
            }
    }

    private func shouldShow(_ show: Bool) {
        withAnimation {
            isShowing = show
        }
    }
}

#Preview {
    return VStack(spacing: 20) {
        PopupView(isShowing: .constant(true), content: Color.black)
    }
}
