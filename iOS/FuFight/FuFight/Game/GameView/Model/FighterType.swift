//
//  Fighter.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/21/24.
//

import Foundation
import SceneKit

enum FighterType: String, CaseIterable, Identifiable {
    case samuel
    case clara
    case kim
    case deeJay
    case jad
    case ruby
    case cain
    case andrew
    case corey
    case alexis
//    case marco
    case neverRight

    var id: String { rawValue }

    var name: String {
        switch self {
        case .samuel:
            "Samuel"
        case .clara:
            "Clara"
        case .kim:
            "Kim"
        case .deeJay:
            "Dee Jay"
        case .jad:
            "Jad"
        case .ruby:
            "Ruby"
        case .cain:
            "Cain"
        case .andrew:
            "Andrew"
        case .corey:
            "Corey"
        case .alexis:
            "Alexis"
//        case .marco:
//            "Marco"
        case .neverRight:
            "Never Right"
        }
    }

    var headShotImageName: String {
        "\(rawValue)HeadShot"
    }

    var bonesName: String {
        switch self {
        case .samuel:
            "Armature"
        case .clara:
            "Armature-001"
        case .andrew:
            "mixamorig1_Hips"
        case .alexis:
            "mixamorig6_Hips"
        case .jad:
            "mixamorig7_Hips"
        case .corey:
            "mixamorig10_Hips"
        case .ruby, .kim, .deeJay, .cain, .neverRight:
            "mixamorig_Hips"
        }
    }

    var scale: Float {
        switch self {
        case .neverRight:
            0.018
        default:
            0.02
        }
    }

    var daeUrl: URL? {
        return Bundle.main.url(forResource: defaultDaePath, withExtension: "dae")
    }

    var path: String {
        "3DAssets.scnassets/Characters/\(name)"
    }

    private var assetsPath: String {
        "\(path)/assets/"
    }
    private var animationsPath: String {
        "\(path)/animations/"
    }

    var defaultDaePath: String {
        "\(assetsPath)\(rawValue)"
    }

    var isReleased: Bool {
        switch self {
        case .samuel:
            true
        case .clara:
            true
        case .kim:
            false
        case .deeJay:
            false
        case .jad:
            false
        case .ruby:
            false
        case .cain:
            false
        case .andrew:
            false
        case .corey:
            false
        case .alexis:
            false
        case .neverRight:
            false
        }
    }

    var coinCost: Int {
        switch self {
        case .samuel:
            7500
        case .clara:
            5000
        case .kim:
            5000
        case .deeJay:
            5000
        case .jad:
            5000
        case .ruby:
            5000
        case .cain:
            5000
        case .andrew:
            5000
        case .corey:
            5000
        case .alexis:
            5000
        case .neverRight:
            7500
        }
    }

    var summary: String {
        switch self {
        case .samuel:
            "Samuel, a professional corporate worker by day, transforms into a disciplined and relentless fighter by night."
        case .clara:
            "Clara, a fierce street fighter, uses her raw strength and street-smart tactics to dominate her opponents."
        case .kim:
            "Kim, often underestimated for her looks, blends charm and deadly combat skills to outwit and overpower her foes."
        case .deeJay:
            "DeeJay, a DJ by hobby, brings electrifying energy and rhythm to her unpredictable and powerful fighting style."
        case .jad:
            "Jad, a runner with unmatched stamina, uses his endurance and speed to outlast and strike down his opponents."
        case .ruby:
            "Ruby, a chef, utilizes her powerful kicks and agility to deliver swift and decisive blows in the ring."
        case .cain:
            "Cain, a surgeon, leverages his medical knowledge to target opponents' weaknesses with surgical precision."
        case .andrew:
            "Andrew, a rugged construction worker, uses his immense power and resilience to withstand and deliver punishing blows."
        case .corey:
            "Corey, a streamer, combines agility and quick reflexes to captivate his audience and dominate his opponents."
        case .alexis:
            "Alexis, a vegan and fitness enthusiast, channels her healthy lifestyle into exceptional strength and agility in the ring."
        case .neverRight:
            "NeverRight, a zombie with no right hand, relies on relentless tenacity and unpredictable movements to win fights."
        }
    }

    var quickStory: String {
        switch self {
        case .samuel:
            "Samuel is a dual-force to be reckoned with, excelling both in the corporate boardroom and the fighting arena. By day, he dons a suit and tie, navigating high-stakes business deals with precision and confidence. By night, he channels his strategic mind and physical prowess into his fights, making him a formidable opponent who is as disciplined as he is relentless."
        case .clara:
            "Clara is a fierce fighter who honed her skills on the unforgiving streets. Growing up in a tough neighborhood, she learned to defend herself and others with unmatched tenacity. Her street-smart tactics and raw strength make her a dynamic and unpredictable competitor, capable of taking down even the toughest foes with her gritty determination and street-fighting techniques."
        case .kim:
            "Kim, a strikingly beautiful fighter, often finds herself underestimated due to her looks. However, beneath her pretty exterior lies a deadly warrior who has mastered various combat styles. Her ability to leverage her charm and physical agility gives her a unique edge in the ring, where she seamlessly combines grace and ferocity to outwit and overpower her opponents."
        case .deeJay:
            "DeeJay is a charismatic fighter who brings rhythm and energy from the DJ booth into the fighting arena. As a DJ, she knows how to read a crowd and keep the energy high, a skill that translates seamlessly into her fights. Her powerful moves are as electrifying as her beats, making her a captivating and unpredictable fighter who thrives on the thrill of the fight."
        case .jad:
            "Jad, the runner with unmatched stamina, brings his endurance and speed to the fighting arena. His training as a long-distance runner has given him incredible cardiovascular strength, allowing him to outlast his opponents and strike with relentless precision. Jad's ability to maintain his energy and composure under pressure makes him a formidable force who never backs down."
        case .ruby:
            "Ruby is a culinary artist by day and a leg-fighting specialist by night. As a chef, she has honed her precision and creativity, skills that she brings to her unique fighting style. Utilizing powerful kicks and agile movements, Ruby turns her legs into lethal weapons, delivering swift and decisive blows that leave her opponents reeling."
        case .cain:
            "Cain, a skilled surgeon, combines his medical knowledge with his fighting prowess. His understanding of the human body gives him a strategic advantage, allowing him to target his opponents' weaknesses with surgical precision. Cain's calm demeanor and meticulous approach make him a calculating and dangerous fighter who strikes with deadly accuracy."
        case .andrew:
            "Andrew, the rugged construction worker, brings his raw strength and hard-working ethic to the fighting arena. Used to physical labor and demanding tasks, he possesses immense power and resilience. Andrew's brute force and unyielding determination make him a relentless opponent who can withstand and deliver punishing blows."
        case .corey:
            "Corey combines his love for streaming with his passion for fighting. Aspiring to become a popular online personality, he uses his fights as a platform to showcase his skills and charisma. Corey's agility and quick reflexes, honed from hours of gaming and streaming, make him an unpredictable and agile fighter who thrives on the attention of his audience."
        case .alexis:
            "Alexis is a dedicated vegan and fitness enthusiast who channels her healthy lifestyle into her fighting style. Her commitment to plant-based nutrition and rigorous exercise regime gives her exceptional strength and agility. Alexis's disciplined approach to both her diet and training makes her a powerful and resilient fighter who embodies the principles of holistic health and wellness in the ring."
        case .neverRight:
            "NeverRight is an army general who is so confident that he ripped his own right hand to give his enemies a handicap. He makes up for it with relentless left side of his body. His undead resilience allows him to withstand attacks that would incapacitate ordinary fighters, while his left-hand strikes and unpredictable movements keep opponents on their toes. Despite his eerie appearance and missing limb, NeverRight is a force of nature, driven by an insatiable hunger for victory."
        }
    }

    var diamondCost: Int {
        coinCost / 10
    }

    //MARK: - Public Methods
    func animationPath(_ animationType: AnimationType) -> String {
        "\(path)/\(animationType.animationPath)"
    }

    func getMaterial(for skeletonType: SkeletonType) -> SCNMaterial {
        let material = SCNMaterial()
        material.name = skeletonType.name
        material.diffuse.contents = diffusedMaterial(for: skeletonType)
        material.specular.contents = specularMaterial(for: skeletonType)
        material.transparent.contents = transparentMaterial(for: skeletonType)
        return material
    }
}

private extension FighterType {
    func diffusedMaterial(for skeletonType: SkeletonType) -> Any? {
        switch skeletonType {
        case .samuelGlassesLens:
            //Make samuel's glasses black
            return isBlackGlasses ? UIColor.blackLight : UIColor(red: 0, green: 0, blue: 0, alpha: 0.27)
        default:
            if let url = Bundle.main.url(forResource: "\(assetsPath)\(skeletonType.diffuseImageName)", withExtension: "png"),
               let data = try? Data(contentsOf: url) {
                return UIImage(data: data)
            }
        }
        LOGDE("No diffused material found for \(skeletonType)")
        return nil
    }

    func specularMaterial(for skeletonType: SkeletonType) -> Any? {
        if let imageName = skeletonType.specularImageName,
           let url = Bundle.main.url(forResource: "\(assetsPath)\(imageName)", withExtension: "png"),
           let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return UIColor.blackLight
    }

    func transparentMaterial(for skeletonType: SkeletonType) -> Any? {
        if let imageName = skeletonType.transparentImageName,
           let url = Bundle.main.url(forResource: "\(assetsPath)\(imageName)", withExtension: "png"),
           let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return UIColor.blackLight
    }
}
