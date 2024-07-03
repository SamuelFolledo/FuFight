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
    case samuelFacialHair = "face-001"
    case samuelBody = "M_MED_Cat_Burglar-mo"
    case samuelGlassesLens = "glases_-003"
    case samuelGlassesFrame = "glases_-002"
    case samuelHair = "male01_Mat_male01__bodny_bmp_0-001"
    case samuelHead = "face-002"

    case clara = "body-003"

    case kimCloth = "Ch02_Cloth"
    case kimEyelashes = "Ch02_Eyelashes"
    case kimBody = "Ch02_Body"
    case kimSneakers = "Ch02_Sneakers"
    case kimSocks = "Ch02_Socks"
    case kimHair = "Ch02_Hair"

    case deeJay = "Ch03"

    case jadBody = "Ch08_Body"
    case jadSneakers = "Ch08_Sneakers"
    case jadEyelashes = "Ch08_Eyelashes"
    case jadPants = "Ch08_Pants"
    case jadHoodie = "Ch08_Hoodie"
    case jadHair = "Ch08_Hair"
    case jadBeard = "Ch08_Beard"

    case rubyShoe = "Ch13_Shoe"
    case rubyBody = "Ch13_Body"
    case rubyPants = "Ch13_Pants"
    case rubyShirt = "Ch13_Shirt"
    case rubyEyelashes = "Ch13_Eyeleashes"
    case rubyHair = "Ch13_Hair"

    case cainMask = "Ch16_Mask"
    case cainBody = "Ch16_Body1"
    case cainCap = "Ch16_Cap"
    case cainPants = "Ch16_Pants"
    case cainShirt = "Ch16_Shirt"
    case cainShoes = "Ch16_Shoes"
    case cainEyelashes = "Ch16_Eyelashes"

    case andrewBody = "Ch17_Body"
    case andrewBoots = "Ch17_Boots"
    case andrewHelmet = "Ch17_Helmet"
    case andrewVest = "Ch17_Vest"
    case andrewShirt = "Ch17_Shirt"
    case andrewPants = "Ch17_Pants"
    case andrewEyelashes = "Ch17_Eyelashes"
    case andrewHair = "Ch17_Hair"

    case coreyBody = "Ch28_Body"
    case coreySneakers = "Ch28_Sneakers"
    case coreyPants = "Ch28_Pants"
    case coreyHoody = "Ch28_Hoody"
    case coreyEyelashes = "Ch28_Eyelashes"
    case coreyHair = "Ch28_Hair"

    case alexisPants = "Ch37_Pants"
    case alexisSneakers = "Ch37_Sneakers"
    case alexisShirt = "Ch37_Shirt"
    case alexisEyelashes = "Ch37_Eyeleashes"
    case alexisBody = "Ch37_Body"
    case alexisZipper = "Ch37_Zipper"
    case alexisHair = "Ch37_Hair"

//    case marcoSneakers = "Ch42_Sneakers"
//    case marcoBody = "Ch42_Body1"
//    case marcoShirt = "Ch42_Shirt"
//    case marcoShorts = "Ch42_Shorts"
//    case marcoEyelashes = "Ch42__Eyelashes"
//    case marcoHair = "Ch42_Hair1"
    
    case neverRight = "Prisoner"

    var name: String {
        switch self {
        case .clara:
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
        case .kimCloth:
            rawValue
        case .kimEyelashes:
            rawValue
        case .kimBody:
            rawValue
        case .kimSneakers:
            rawValue
        case .kimSocks:
            rawValue
        case .kimHair:
            rawValue
        case .deeJay:
            rawValue
        case .jadBody:
            rawValue
        case .jadSneakers:
            rawValue
        case .jadEyelashes:
            rawValue
        case .jadPants:
            rawValue
        case .jadHoodie:
            rawValue
        case .jadHair:
            rawValue
        case .jadBeard:
            rawValue
        case .rubyShoe:
            rawValue
        case .rubyBody:
            rawValue
        case .rubyPants:
            rawValue
        case .rubyShirt:
            rawValue
        case .rubyEyelashes:
            rawValue
        case .rubyHair:
            rawValue
        case .cainMask:
            rawValue
        case .cainBody:
            rawValue
        case .cainCap:
            rawValue
        case .cainPants:
            rawValue
        case .cainShirt:
            rawValue
        case .cainShoes:
            rawValue
        case .cainEyelashes:
            rawValue
        case .andrewBody:
            rawValue
        case .andrewBoots:
            rawValue
        case .andrewHelmet:
            rawValue
        case .andrewVest:
            rawValue
        case .andrewShirt:
            rawValue
        case .andrewPants:
            rawValue
        case .andrewEyelashes:
            rawValue
        case .andrewHair:
            rawValue
        case .coreyBody:
            "Ch28_Body"
        case .coreySneakers:
            "Ch28_Sneakers"
        case .coreyPants:
            "Ch28_Pants"
        case .coreyHoody:
            "Ch28_Hoody"
        case .coreyEyelashes:
            "Ch28_Eyelashes"
        case .coreyHair:
            "Ch28_Hair"
        case .alexisPants:
            rawValue
        case .alexisSneakers:
            rawValue
        case .alexisShirt:
            rawValue
        case .alexisEyelashes:
            rawValue
        case .alexisBody:
            rawValue
        case .alexisZipper:
            rawValue
        case .alexisHair:
            rawValue
//        case .marcoSneakers:
//            rawValue
//        case .marcoBody:
//            rawValue
//        case .marcoShirt:
//            rawValue
//        case .marcoShorts:
//            rawValue
//        case .marcoEyelashes:
//            rawValue
//        case .marcoHair:
//            rawValue
        case .neverRight:
            rawValue
        }
    }

    var diffuseImageName: String {
        switch self {
        case .samuelFacialHair:
            "samuelFacialHair"
        case .samuelBody:
            "samuelBody"
        case .samuelGlassesLens:
            "samuelGlasses"
        case .samuelGlassesFrame:
            "samuelGlasses"
        case .samuelHair:
            "samuelHair"
        case .samuelHead:
            "samuelFace"
        case .clara:
            "claraTexture"
        case .kimCloth, .kimBody, .kimSneakers, .kimSocks:
            "kimTexture1_Diffuse"
        case .kimEyelashes, .kimHair:
            "kimTexture2_Diffuse"
        case .deeJay:
            "deejayTexture_Diffuse"
        case .jadBody:
            "jadTexture1_Diffuse"
        case .jadSneakers, .jadPants, .jadHoodie:
            "jadTexture2_Diffuse"
        case .jadEyelashes, .jadHair, .jadBeard:
            "jadTexture3_Diffuse"
        case .rubyShoe, .rubyBody, .rubyPants, .rubyShirt:
            "rubyTexture1_Diffuse"
        case .rubyEyelashes, .rubyHair:
            "rubyTexture2_Diffuse"
        case .cainBody, .cainPants, .cainShirt, .cainEyelashes:
            "cainTexture1_Diffuse"
        case .cainMask, .cainCap, .cainShoes:
            "cainTexture2_Diffuse"
        case .andrewBody, .andrewBoots, .andrewHelmet, .andrewVest, .andrewShirt, .andrewPants:
            "andrewTexture1_Diffuse"
        case .andrewEyelashes, .andrewHair:
            "andrewTexture2_Diffuse"
        case .coreyBody, .coreySneakers, .coreyPants, .coreyHoody:
            "coreyTexture_Diffuse"
        case .coreyEyelashes, .coreyHair:
            "coreyTexture_Diffuse"
        case .alexisPants, .alexisSneakers, .alexisShirt, .alexisBody, .alexisZipper:
            "alexisTexture1_Diffuse"
        case .alexisEyelashes, .alexisHair:
            "alexisTexture2_Diffuse"
//        case .marcoSneakers, .marcoBody, .marcoShirt, .marcoShorts:
//            "marcoTexture1_Diffuse"
//        case .marcoEyelashes, .marcoHair:
//            "marcoTexture2_Diffuse"
        case .neverRight:
            "neverRightTexture_diffuse"
        }
    }

    var specularImageName: String? {
        switch self {
        case .coreyBody, .coreySneakers, .coreyPants, .coreyHoody, .coreyEyelashes, .coreyHair:
            diffuseImageName
        case .samuelFacialHair, .samuelBody, .samuelGlassesLens, .samuelGlassesFrame, .samuelHair, .samuelHead, .clara, .kimEyelashes, .kimHair, .jadEyelashes, .jadHair, .jadBeard, .rubyEyelashes, .rubyHair:
            nil
        case .kimCloth, .kimBody, .kimSneakers, .kimSocks:
            "kimTexture1_Specular"
        case .jadBody:
            "jadTexture1_Specular"
        case .jadSneakers, .jadPants, .jadHoodie:
            "jadTexture2_Specular"
        case .rubyShoe, .rubyBody, .rubyPants, .rubyShirt:
            "rubyTexture1_Specular"
        case .neverRight:
            "neverRightTexture_specular"
        case .deeJay:
            "deejayTexture_Specular"
        case .cainBody, .cainPants, .cainShirt:
            "cainTexture1_Specular"
        case .cainMask, .cainCap, .cainShoes:
            "cainTexture2_Specular"
        case .cainEyelashes:
            nil
        case .andrewBody, .andrewBoots, .andrewHelmet, .andrewVest, .andrewShirt, .andrewPants:
            "andrewTexture1_Specular"
        case .andrewEyelashes, .andrewHair:
            nil
        case .alexisPants, .alexisSneakers, .alexisShirt, .alexisBody, .alexisZipper:
            "alexisTexture1_Specular"
        case .alexisEyelashes, .alexisHair:
            nil
//        case .marcoSneakers, .marcoBody, .marcoShirt, .marcoShorts:
//            "marcoTexture1_Specular"
//        case .marcoEyelashes, .marcoHair:
//            nil
        }
    }

    var transparentImageName: String? {
        switch self {
        case .samuelGlassesLens:
            //Handled specially with isBlackGlasses
            nil
        case .kimEyelashes, .kimHair, .jadEyelashes, .jadHair, .jadBeard, .rubyEyelashes, .rubyHair, .cainEyelashes, .andrewEyelashes, .andrewHair, .coreyEyelashes, .coreyHair, .alexisEyelashes, .alexisHair/*, .marcoEyelashes, .marcoHair*/:
            diffuseImageName
        case .samuelFacialHair, .samuelBody, .samuelGlassesFrame, .samuelHair, .samuelHead, .clara, .coreyBody, .coreySneakers, .coreyPants, .coreyHoody, .kimCloth, .kimBody, .kimSneakers, .kimSocks, .deeJay, .jadBody, .jadSneakers, .jadPants, .jadHoodie, .rubyShoe, .rubyBody, .rubyPants, .rubyShirt, .cainMask, .cainBody, .cainCap, .cainPants, .cainShirt, .cainShoes, .andrewBody, .andrewBoots, .andrewHelmet, .andrewVest, .andrewShirt, .andrewPants, .alexisPants, .alexisSneakers, .alexisShirt, .alexisBody, .alexisZipper, /*.marcoSneakers, .marcoBody, .marcoShirt, .marcoShorts,*/ .neverRight:
                nil
        }
    }
}
