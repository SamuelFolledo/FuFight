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

let fakePhotoUrl = URL(string: "https://firebasestorage.googleapis.com:443/v0/b/fufight-51d75.appspot.com/o/Accounts%2FPhotos%2FNbJGeGskGZb1BT7m9NYm5l87mps1.jpg?alt=media&token=29b66d7a-bd94-42b6-9a77-c1dcfd2accb8")!
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
let smallerHorizontalPadding: CGFloat = 18
let horizontalPadding: CGFloat = 36
let accountImagePickerHeight: CGFloat = 160
let defaultMaxTime: Int = 5
let defaultMaxHp: CGFloat = 100
let defaultEnemyHp: CGFloat = 100
let fighterCellSize: CGFloat = 80
let characterItemSpacing: CGFloat = 2
let characterItemBorderWidth: CGFloat = 5
let homeBottomViewHeight: CGFloat = 120
let charactersBottomButtonsHeight: CGFloat = 40
let homeNavBarHeight: CGFloat = 100
let navBarIconSize: CGFloat = 25

var animationToTest: AnimationType = .punchHeadRightHard

//Fonts
let defaultFontSize: CGFloat = 16
let tabFont = Font.system(size: 12, weight: .semibold)
let smallTitleFont = Font.system(size: defaultFontSize + 4, weight: .bold)
let textFont = Font.system(size: defaultFontSize, weight: .regular)
let characterFont = Font.system(size: 14, weight: .semibold)
let characterDetailFont = Font.system(size: 12, weight: .medium)
let mediumTextFont = textFont.weight(.medium)
let boldedTextFont = textFont.weight(.bold)
let buttonFont = Font.system(size: defaultFontSize, weight: .semibold)
let boldedButtonFont = buttonFont.weight(.bold)
let mediumTitleFont = Font.system(size: defaultFontSize * 2, weight: .bold)
let largeTitleFont = Font.system(size: defaultFontSize * 4, weight: .bold)
let extraLargeTitleFont = Font.system(size: defaultFontSize * 8, weight: .bold)
let navBarFont = Font.system(size: 13, weight: .semibold)

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
let blackColor = Color.black

//MARK: - Constant Assets
//Backgrounds
let backgroundUiImage = UIImage(named: "homeBackground")!
let backgroundImage: some View = Image(uiImage: backgroundUiImage).backgroundImageModifier()
let gameBackgroundUiImage = UIImage(named: "gameBackground")!
let gameBackgroundImage: some View = Image(uiImage: gameBackgroundUiImage).backgroundImageModifier()
let accountBackgroundImage: some View = Image("accountImageBackground").defaultImageModifier()
let currencyBackgroundImage: some View = Image("currencyBackground").defaultImageModifier()
let navBarBackgroundImage: some View = Image("navBarBackground").defaultImageModifier()
let cityBackgroundImage: some View = Image("cityBackground").defaultImageModifier()
let timerBackgroundImage: some View = Image("timerBackground").defaultImageModifier()
let navBarContainerImage: some View = Image("navBarContainer").containerImageModifier()

//Buttons Folder
let backButtonImage: some View = Image("backButton").buttonImageModifier()
let homeButtonImage: some View = Image("homeButton").buttonImageModifier()
let homeButtonSelectedImage: some View = Image("homeButtonSelected").buttonImageModifier()
let noButtonImage: some View = Image("noButton").buttonImageModifier()
let playButtonImage: some View = Image("playButton").buttonImageModifier()
let plusImage: some View = Image("plus").defaultImageModifier()
let plusButtonImage: some View = Image("plusButton").defaultImageModifier()
let restartButtonImage: some View = Image("restartButton").buttonImageModifier()
let resumeButtonImage: some View = Image("resumeButton").buttonImageModifier()
let yesButtonButtonImage: some View = Image("yesButton").buttonImageModifier()

//Icons
let coinImage: some View = Image("coin").defaultImageModifier()
let diamondImage: some View = Image("diamond").defaultImageModifier()

//System Images
let defaultProfilePhoto: UIImage = UIImage(systemName: "person.crop.circle")!
let checkedImage: UIImage = UIImage(systemName: "checkmark.square.fill")!
let uncheckedImage: UIImage = UIImage(systemName: "square")!
let securedImage: some View = Image(systemName: "eye")
    .foregroundColor(.label)
let nonSecuredImage: some View = Image(systemName: "eye.slash")
    .foregroundColor(.label)
let invalidImage: some View = Image(systemName: "xmark.circle.fill")
    .foregroundColor(Color.systemRed)
let validImage: some View = Image(systemName: "checkmark.circle.fill")
    .foregroundColor(Color.systemGreen)

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
                             fighter: Fighter(type: FighterType.allCases.randomElement()!, isEnemy: true),
                             state: PlayerState(boostLevel: .none, initiallyHasSpeedBoost: false),
                             moves: Moves(attacks: defaultAllPunchAttacks, defenses: defaultAllDashDefenses))

let allAnimations: [AnimationType] = otherAnimations + defaultAllPunchAttacks.compactMap{ $0.animationType } + defaultAllDashDefenses.compactMap{ $0.animationType }
let otherAnimations: [AnimationType] = [.idleFight, .idleStand, .dodgeHeadLeft, .dodgeHeadRight, .hitHeadRightLight, .hitHeadLeftLight, .hitHeadStraightLight, .hitHeadRightMedium, .hitHeadLeftMedium, .hitHeadStraightMedium, .hitHeadRightHard, .hitHeadLeftHard, .hitHeadStraightHard, .killHeadRightLight, .killHeadLeftLight, .killHeadRightMedium, .killHeadLeftMedium, .killHeadRightHard, .killHeadLeftHard]

let characters = FighterType.allCases.compactMap { CharacterObject(fighterType: $0) }

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
