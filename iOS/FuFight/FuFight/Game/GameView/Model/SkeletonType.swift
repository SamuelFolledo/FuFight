//
//  SkeletonType.swift
//  FuFight
//
//  Created by Samuel Folledo on 4/9/24.
//

import SceneKit

///Set this to false to make fighter named Samuel to have a transparent blue glasses instead
let isBlackGlasses = true

enum SkeletonType: String {
    //MARK: Clara's skeletons
    case claraBody = "body-003"

    //MARK: Samuel's skeletons
    case samuelFacialHair = "face-001"
    case samuelBody = "M_MED_Cat_Burglar-mo"
    case samuelGlassesLens = "glases_-003"
    case samuelGlassesFrame = "glases_-002"
    case samuelHair = "male01_Mat_male01__bodny_bmp_0-001"
    case samuelHead = "face-002"

    var name: String {
        switch self {
        case .claraBody:
            "clara body"
        case .samuelFacialHair:
            "facial hair"
        case .samuelBody:
            "samuel body"
        case .samuelGlassesLens:
            "lens"
        case .samuelGlassesFrame:
            "frame"
        case .samuelHair:
            "hair"
        case .samuelHead:
            "head"
        }
    }
}
