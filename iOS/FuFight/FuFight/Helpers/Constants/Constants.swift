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

//MARK: Firebase Auth constants
let auth = Auth.auth()

let fakePhotoUrl = URL(string: "https://firebasestorage.googleapis.com:443/v0/b/fufight-51d75.appspot.com/o/Accounts%2FPhotos%2FS4L442FyMoNRfJEV05aFCHFMC7R2.jpg?alt=media&token=0f185bff-4d16-450d-84c6-5d7645a97fb9")!
let fakeAccount = Account()


//MARK: Firebase Firestore database constants
let db = Firestore.firestore()
let accountsDb = db.collection(kACCOUNTS)
let usernamesDb = db.collection(kUSERNAMES)

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

//Fonts
let defaultFontSize: CGFloat = 16
let smallTitleFont = Font.system(size: defaultFontSize + 4, weight: .bold)
let textFont = Font.system(size: defaultFontSize, weight: .regular)
let mediumTextFont = textFont.weight(.medium)
let boldedTextFont = textFont.weight(.bold)
let buttonFont = Font.system(size: defaultFontSize, weight: .semibold)
let boldedButtonFont = buttonFont.weight(.bold)
let mediumTitleFont = Font.system(size: defaultFontSize * 2, weight: .bold)
let largeTitleFont = Font.system(size: defaultFontSize * 4, weight: .bold)
let extraLargeTitleFont = Font.system(size: defaultFontSize * 8, weight: .bold)

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

//Buttons Folder
let backButtonImage: some View = Image("backButton").defaultImageModifier()
let homeButtonImage: some View = Image("homeButton").defaultImageModifier()
let homeButtonSelectedImage: some View = Image("homeButtonSelected").defaultImageModifier()
let noButtonImage: some View = Image("noButton").defaultImageModifier()
let playButtonImage: some View = Image("playButton").defaultImageModifier()
let plusImage: some View = Image("plus").defaultImageModifier()
let plusButtonImage: some View = Image("plusButton").defaultImageModifier()
let restartButtonImage: some View = Image("restartButton").defaultImageModifier()
let resumeButtonImage: some View = Image("resumeButton").defaultImageModifier()
let yesButtonButtonImage: some View = Image("yesButton").defaultImageModifier()

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

let defaultAllPunchAttacks: [Attack] = Punch.allCases.map { Attack($0) }
let defaultAllDashDefenses: [Defend] = Dash.allCases.map { Defend($0) }
