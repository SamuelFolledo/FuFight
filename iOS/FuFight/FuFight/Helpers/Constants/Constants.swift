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

let fakePhotoUrl = Account.current?.photoUrl ?? URL(string: "https://firebasestorage.googleapis.com:443/v0/b/fufight-51d75.appspot.com/o/Accounts%2FPhotos%2FS4L442FyMoNRfJEV05aFCHFMC7R2.jpg?alt=media&token=0f185bff-4d16-450d-84c6-5d7645a97fb9")!
let fakeAccount = Account()


//MARK: Firebase Firestore database constants
let db = Firestore.firestore()
let accountsDb = db.collection(kACCOUNTS)
let usernamesDb = db.collection(kUSERNAMES)

//MARK: Firebase Storage constants
let storage = Storage.storage().reference()
let accountPhotoStorage = storage.child(kACCOUNTS).child(kPHOTOS)

//Fonts
let defaultFontSize: CGFloat = 16
let smallTitleFont = Font.system(size: defaultFontSize + 4, weight: .bold)
let textFont = Font.system(size: defaultFontSize, weight: .regular)
let mediumTextFont = textFont.weight(.medium)
let boldedTextFont = textFont.weight(.bold)
let buttonFont = Font.system(size: defaultFontSize, weight: .semibold)
let boldedButtonFont = buttonFont.weight(.bold)
let largeTitleFont = Font.system(size: defaultFontSize * 2, weight: .bold)
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

//Constant images
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
let accountPhotoCompressionQuality: Double = 0.3
let horizontalPadding: CGFloat = 36
let accountImagePickerHeight: CGFloat = 160
let defaultMaxTime: Int = 5

