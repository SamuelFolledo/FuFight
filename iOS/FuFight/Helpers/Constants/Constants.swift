//
//  Constants.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/17/24.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import SwiftUI
import SceneKit

//MARK: Firebase Auth constants
let auth = Auth.auth()

let fakePhotoUrl = URL(string: "https://firebasestorage.googleapis.com/v0/b/fufight-51d75.appspot.com/o/Accounts%2FPhotos%2FqFLqUnDkyVZTAT1cH6WIThWjzMq1.jpg?alt=media&token=dcd076a4-afca-47fc-95fb-870bc285a23f")!
let fakeAccount = Account()


//MARK: Firebase Firestore database constants
let db = Firestore.firestore()
let accountsDb = db.collection(kACCOUNTS)
let roomsDb = db.collection(kROOMS)
let gamesDb = db.collection(kGAMES)
let historiesDb = db.collection(kHISTORIES)

//MARK: Firebase Storage constants
let storage = Storage.storage().reference()
let accountPhotoStorage = storage.child(kACCOUNTS).child(kPHOTOS)

//Constant values
let accountPhotoCompressionQuality: Double = 0.3
let smallerHorizontalPadding: CGFloat = 12
let horizontalPadding: CGFloat = 24
let accountImagePickerHeight: CGFloat = 160
let defaultMaxTime: Int = 5
let defaultMaxHp: CGFloat = 100
let defaultEnemyHp: CGFloat = 100
let fighterCellSize: CGFloat = 80
let characterItemSpacing: CGFloat = 2
let characterItemBorderWidth: CGFloat = 5
let homeSelectedTabItemHeight: CGFloat = 63
let homeTabBarHeight: CGFloat = 77
let homeTabBarHeightPadded: CGFloat = homeTabBarHeight + 30
let homeBottomViewHeight: CGFloat = 120
let charactersBottomButtonsHeight: CGFloat = 40
let homeNavBarHeight: CGFloat = 120
let navBarIconSize: CGFloat = 25
let navBarButtonMaxWidth: CGFloat = 50
let buttonMinWidthMultiplier: CGFloat = 0.4
let buttonMaxWidthMultiplier: CGFloat = 0.65
let rectangleCornerRadius: CGFloat = 8
let homeTopTrailingButtonTypeHeight: CGFloat = 35

var animationToTest: AnimationType = .punchHeadRightHard

//Fonts
let defaultFontSize: CGFloat = 22

//Colors
let systemUiColor = UIColor.label
let systemColor = Color(uiColor: systemUiColor)
let backgroundUiColor = UIColor.systemBackground
let backgroundColor = Color(uiColor: backgroundUiColor)
let primaryUiColor = UIColor.label
let primaryColor = Color(uiColor: primaryUiColor)
let secondaryUiColor = UIColor.systemMint
let secondaryColor = Color(uiColor: secondaryUiColor)
let disabledUiColor = UIColor.systemGray2
let disabledColor = Color(uiColor: disabledUiColor)
let destructiveUiColor = UIColor.systemRed
let destructiveColor = Color(uiColor: destructiveUiColor)
let unselectedTabColor: Color = Color(uiColor: .lightGray)

//MARK: - Constant Assets
//Backgrounds
let backgroundUiImage = UIImage(named: "homeBackground")!
let backgroundImage: some View = Image(uiImage: backgroundUiImage).backgroundImageModifier()
let backgroundOverImage: some View = Image("homeBackgroundOverlay").backgroundImageModifier()
let gameBackgroundUiImage = UIImage(named: "gameBackground")!
let gameBackgroundImage: some View = Image(uiImage: gameBackgroundUiImage).backgroundImageModifier()
let accountBackgroundImage: some View = Image("accountImageBackground").defaultImageModifier()
let currencyBackgroundImage: some View = Image("currencyBackground").defaultImageModifier()
let navBarBackgroundImage: some View = Image("navBarBackground").navBarBackgroundImageModifier()
let cityBackgroundImage: some View = Image("cityBackground").defaultImageModifier()
let timerBackgroundImage: some View = Image("timerBackground").defaultImageModifier()
let navBarContainerImage: some View = Image("navBarContainer").containerImageModifier()
let alertBodyBackgroundImage: some View = Image("alertBodyBackground").containerImageModifier()
let alertTitleBackgroundImage_Shadowed: some View = Image("alertTitleBackground-shadowed").containerImageModifier()
let alertTitleBackgroundImage: some View = Image("alertTitleBackground").containerImageModifier()
let dimViewBackground: some View = Color.gray.opacity(0.55)
let roundedButtonBackgroundImage: some View = Image("borderedCircle").containerImageModifier()
let containerBackgroundImage: some View = Image("containerOverlay").containerImageModifier()

//Buttons Folder
let plusImage: some View = Image("plus").defaultImageModifier()
let plusButtonImage: some View = Image("plusButton").defaultImageModifier()
let blueButtonImage: some View = Image("blueButton").buttonImageModifier()
let greenButtonImage: some View = Image("greenButton").buttonImageModifier()
let redButtonImage: some View = Image("redButton").buttonImageModifier()
let yellowButtonImage: some View = Image("yellowButton").buttonImageModifier()

//Icons
let coinImage: some View = Image("coin").defaultImageModifier()
let diamondImage: some View = Image("diamond").defaultImageModifier()
let yellowRingImage: some View = Image("yellowRing").containerImageModifier()

//System Images
let defaultProfilePhoto: UIImage = UIImage(systemName: "person.crop.circle")!
let checkedImage: some View = Image("check")
    .defaultImageModifier()
let uncheckedImage: some View = Image(systemName: "square")
    .foregroundColor(Color.white)
let securedImage: some View = Image(systemName: "eye")
    .foregroundColor(Color.white)
let nonSecuredImage: some View = Image(systemName: "eye.slash")
    .foregroundColor(Color.white)
let invalidImage: some View = Image(systemName: "xmark.circle.fill")
    .foregroundColor(Color.systemRed)
let validImage: some View = Image(systemName: "checkmark.circle.fill")
    .foregroundColor(Color.systemGreen)
let lockImage: some View = Image(systemName: "lock.fill")
    .foregroundColor(Color.white)

let defaultAllPunchAttacks: [Attack] = Punch.allCases.compactMap { Attack($0) }
let defaultAllDashDefenses: [Defense] = Dash.allCases.compactMap { Defense($0) }

///Speed multiplier for the player that has the speed boost
let speedBoostMultiplier: CGFloat = 1.1

let fakePlayer = Player(userId: "fakePlayer",
                        photoUrl: fakePhotoUrl,
                        username: "User",
                        hp: defaultMaxHp,
                        maxHp: defaultMaxHp,
                        fighter: Fighter(type: .samuel, isEnemy: false),
                        state: PlayerState(boostLevel: .none, initiallyHasSpeedBoost: false),
                        moves: Moves(attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses))
let fakeEnemyPlayer = Player(userId: "fakeEnemyPlayer",
                             photoUrl: fakePhotoUrl,
                             username: "Enemy",
                             hp: defaultEnemyHp,
                             maxHp: defaultEnemyHp,
                             fighter: Fighter(type: [FighterType.samuel, FighterType.clara].randomElement()!, isEnemy: true),//Fighter(type: FighterType.allCases.randomElement()!, isEnemy: true),
                             state: PlayerState(boostLevel: .none, initiallyHasSpeedBoost: false),
                             moves: Moves(attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses))

let allAnimations: [AnimationType] = otherAnimations + defaultAllPunchAttacks.compactMap{ $0.animationType } + defaultAllDashDefenses.compactMap{ $0.animationType }
let otherAnimations: [AnimationType] = [.idleFight, .idleStand, .dodgeHeadLeft, .dodgeHeadRight, .hitHeadRightLight, .hitHeadLeftLight, .hitHeadStraightLight, .hitHeadRightMedium, .hitHeadLeftMedium, .hitHeadStraightMedium, .hitHeadRightHard, .hitHeadLeftHard, .hitHeadStraightHard, .killHeadRightLight, .killHeadLeftLight, .killHeadRightMedium, .killHeadLeftMedium, .killHeadRightHard, .killHeadLeftHard]

let fakeAllFighters = FighterType.allCases.compactMap { CharacterObject(fighterType: $0, status: .unlocked) }
let fakeNews: [News] = [
    News(title: "TODO: News", type: .announcement),
    News(title: "TODO: New Character1", type: .newCharacter),
    News(title: "TODO: New Character2", type: .newCharacter),
    News(title: "TODO: Other news", type: .other),
    News(title: "TODO: Other old news", type: .other),
]

let fakeFriends: [Friend] = [.init(username: "fakeUsername0", status: .online, lastOnlineDescription: "", photoUrl: fakePhotoUrl),
                             .init(username: "fakeUsername1", status: .online, lastOnlineDescription: "In-Game", photoUrl: fakePhotoUrl),
                             .init(username: "fakeUsername2", status: .queue, lastOnlineDescription: "", photoUrl: fakePhotoUrl),
                             .init(username: "fakeUsername3", status: .gaming, lastOnlineDescription: "In-Game", photoUrl: fakePhotoUrl),
                             .init(username: "fakeUsername4", status: .offline, lastOnlineDescription: "7 minute(s)", photoUrl: fakePhotoUrl),
                             .init(username: "fakeUsername5", status: .offline, lastOnlineDescription: "11 hour(s)", photoUrl: fakePhotoUrl),
                             .init(username: "fakeUsername6", status: .offline, lastOnlineDescription: "2 day(s)", photoUrl: fakePhotoUrl),
                             .init(username: "fakeUsername7", status: .offline, lastOnlineDescription: "7+ days", photoUrl: fakePhotoUrl),
]

//MARK: - Constant Methods
///Run action after a delayed time in seconds
func runAfterDelay(delay: TimeInterval, action: @escaping () -> Void) {
    Task {
        do {
            try await Task.sleep(delay)
        } catch { // Task canceled
            return
        }

        await MainActor.run {
            action()
        }
    }
}

func createFighterScene(fighterType: FighterType, animation: AnimationType) -> SCNScene {
    let path = fighterType.animationPath(animation)
    guard let scene = SCNScene(named: path) else {
        LOGE("No dae scene found from \(path)")
        return SCNScene()
    }
    scene.rootNode.enumerateChildNodes { (child, stop) in
        if let partName = child.name,
           let part = SkeletonType(rawValue: partName) {
            child.geometry?.firstMaterial = fighterType.getMaterial(for: part)
        }
    }
    return scene
}
