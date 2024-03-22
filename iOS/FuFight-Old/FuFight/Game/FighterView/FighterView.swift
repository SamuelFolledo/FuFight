//
//  FighterView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/21/24.
//

import SwiftUI

struct FighterView: View {
    var fighter: Fighter
    @State var shouldDodge = false
    var verticalPadding: CGFloat {
        fighter.isFrontFacing ? 240 : 70
    }

    var body: some View {
        VStack {
            if shouldDodge {
                GIFView(type: URLType.name(fighter.dodgeImageName))
                    .padding(.top, verticalPadding)
                    .padding(.bottom, -verticalPadding)
                    .frame(width: 358, height: 525) //1204 x 1764
            } else {
                GIFView(type: URLType.name(fighter.idleImageName))
                    .padding(.top, verticalPadding)
                    .padding(.bottom, -verticalPadding)
                    .frame(width: 200, height: 592) //672 x 1992
            }
        }
        .onAppear {
            testAnimations()
        }
        .padding(.trailing, fighter.isFrontFacing ? 50 : 0)
    }

    func getDelay() -> DispatchTime {
        .now() + 3
    }

    func getDuration() -> DispatchTime {
        .now() + 1.18
    }

    func testAnimations() {
        DispatchQueue.main.asyncAfter(deadline: getDelay(), execute: {
            self.shouldDodge = true
            DispatchQueue.main.asyncAfter(deadline: getDuration(), execute: {
                self.shouldDodge = false

                DispatchQueue.main.asyncAfter(deadline: getDelay(), execute: {
                    self.shouldDodge = true
                    DispatchQueue.main.asyncAfter(deadline: getDuration(), execute: {
                        self.shouldDodge = false

                        DispatchQueue.main.asyncAfter(deadline: getDelay(), execute: {
                            self.shouldDodge = true
                            DispatchQueue.main.asyncAfter(deadline: getDuration(), execute: {
                                self.shouldDodge = false

                                DispatchQueue.main.asyncAfter(deadline: getDelay(), execute: {
                                    self.shouldDodge = true
                                    DispatchQueue.main.asyncAfter(deadline: getDuration(), execute: {
                                        self.shouldDodge = false

                                        DispatchQueue.main.asyncAfter(deadline: getDelay(), execute: {
                                            self.shouldDodge = true
                                            DispatchQueue.main.asyncAfter(deadline: getDuration(), execute: {
                                                self.shouldDodge = false

                                                DispatchQueue.main.asyncAfter(deadline: getDelay(), execute: {
                                                    self.shouldDodge = true
                                                    DispatchQueue.main.asyncAfter(deadline: getDuration(), execute: {
                                                        self.shouldDodge = false
                                                    })
                                                })
                                            })
                                        })
                                    })
                                })
                            })
                        })
                    })
                })
            })
        })
    }
}

#Preview {
    return VStack(spacing: 20) {
        FighterView(fighter: Fighter(isEnemy: false))
    }
}
