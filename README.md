# FuFight

Multiplayer turn-based 3D fighting game for iOS

This project is my attempt to use the best and newest practices in Swift and popular third party libraries; Combine, Firebase (Firestore, Authentication, Storage, Crashlytics), and uses MVVM pattern.

## Technologies
1. Collada (.dae files) for 3D models and animations. Animations were downloaded from Adobe's [Mixamo](https://www.mixamo.com/) by uploading the character's .fbx file
2. Swift
    - App is mostly in SwiftUI, however, UIKit is required for SceneKit    
    - [SceneKit](https://developer.apple.com/documentation/scenekit) is Apple's 3D rendering engine
    - [Combine](https://developer.apple.com/documentation/combine) is Apple's framework to handle asynchronous events declaratively
    - MVVM pattern, common SwiftUI pattern
    - [Router](https://davidgarywood.com/writing/swiftui-router-pattern/) pattern in charge of handling navigations and creating views which allows flexibility and testability
    - [Codable](https://developer.apple.com/documentation/swift/codable) mapping JSON or dictionaries into a Swift object
    - `async` and `try await` handling background tasks asynchronously
    - `Result` for error handling

3. Firebase
    - Firebase Firestore for database
        - Used Firebase's new property wrappers `@DocumentID`, `@ServerTimestamp`, `@FirestoreQuery`
    - Firebase Authentication for authenticating users. This app also features:
        - Register and log in accounts
        - Forgot email and password
        - Email/username authentication
        - Assign profile picture
        - Update unique username
        - Remember email/username and password
        - Reonboard unfinished account registration
    - Firebase Storage for storing user's photo and other files

## Set up
1. Download repo
2. Download Swift Packages by going to File -> Add Packages and paste the links below
    - FLAnimatedImage (for GIFs): https://github.com/Flipboard/FLAnimatedImage
    - Firebase SDKs: https://github.com/firebase/firebase-ios-sdk
        - Make sure Add to Target's project these followung Package Products:
            1. FirebaseAuth
            2. FirebaseCrashlytics
            3. FirebaseFirestore
            4. FirebaseFirestoreSwift
            5. FirebaseStorage
3. Add GoogleService-Info.plist to the Xcode project by either:
    1. Contact samuelfolledo@gmail.com for a copy of the file
    2. Create your own Firebase project [here](https://console.firebase.google.com/u/0/) and download its GoogleService-Info.plist into your Xcode project. Ensure to enable Firestore, Storage, and Authentication for email and password in the Firebase project

## Game Demo

### Game Rules

1. Each round before the timer runs out, both players can select up to 1 attack and 1 defense move
2. When the current round's timer runs out, damage is applied to opposing enemy's HP depending on each player's selected moves. Selected moves also goes into cooldown at the end of the round
3. Attack rules:
    1. There are 3 types of attack: `light`, `medium`, and `hard`. 
    2. `Light` type of attacks are faster but does lesser damage, meanwhile `hard` type of attacks does more damage but are slower. Cooldown are also longer for hard attacks compared to light attacks.
    3. Landing an attack first **gives the attacker a slight speed boost** for next round and **reduce incoming damage** based on attack type. Hard attacks will reduce incoming damage much more than light attacks
    4. Some attacks can boost the damage of attacks that are not on cooldown for the next round indicated with fire
    5. Each attack type can land either `left` or `right`
4. Defense rules
    1. There are 4 types of defense: `left`, `right`, `up`, `down`
    2. Defense type: `left` or `right` defense move can dodge an attack and receiving 0 damage
    3. Defense type: `up` will increase your speed, increase damage dealt, and damage received
    4. Defense type: `back` will reduce your speed and reduce incoming damage
5. The game ends when one of the player’s HP reduces to 0
6. This game will never result to tie

<img src="https://github.com/SamuelFolledo/FuFight/blob/master/static/demo/version1/gameDemo.gif?raw=true">

---

## Authentication Demo

### Account Creation

- Uses Firebase’s `Authentication` for authentication
- Account creation requires a unique username, unique email, and password. Profile picture is optional
- Email or username along with a password can be used to authenticate
- Account created but incomplete (i.e. user name was not set), after logging in, the app will transition to finishing account creation
- User’s data are stored in `Firebase Firestore` and profile picture in `Firebase Storage`

### Account Deletion

- Deleting accounts gets their `Firebase Firestore`’s data, `Firebase Storage`’s profile picture, and `Firebase Authentication`’s account permanently deleted
- Locally stored account data and remembered email/password are permanently deleted
- Account deletion requires a recent authentication before performing

| Account Creation | Account Deletion |
| --- | --- |
| <img src="https://github.com/SamuelFolledo/FuFight/blob/master/static/demo/version1/accountCreateDemo.gif?raw=true" height="800"> | <img src="https://github.com/SamuelFolledo/FuFight/blob/master/static/demo/version1/accountDeleteDemo.gif?raw=true" height="800"> |

### Account Log In With Email or Username

- Username authentication fetches the user’s email using the unique username, then use that email along with the password to authenticate
- Logging in fetches user’s data from `Firebase Firestore`, user’s profile picture from `Firebase Storage`, and store cache them locally
- With remember email and password feature which gets updated when updating the user’s username

| Log In With Email | Log In With Username |
| --- | --- |
| <img src="https://github.com/SamuelFolledo/FuFight/blob/master/static/demo/version1/accountLogInEmailDemo.gif?raw=true" height="800"> | <img src="https://github.com/SamuelFolledo/FuFight/blob/master/static/demo/version1/accountLogInUsernameDemo.gif?raw=true" height="800"> |

### Account Update Username and Password

- Recent authentication is required in order to update account
- Update email and profile picture is also supported

| Update Username | Update Password |
| --- | --- |
| <img src="https://github.com/SamuelFolledo/FuFight/blob/master/static/demo/version1/accountUsernameUpdateDemo.gif?raw=true" height="800"> | <img src="https://github.com/SamuelFolledo/FuFight/blob/master/static/demo/version1/accountPasswordUpdateDemo.gif?raw=true" height="800"> |

## Important Links
- [Firebase Project](https://console.firebase.google.com/u/0/project/fufight-51d75)
- [Stackoverflow: How to use a .dae file on Xcode](https://stackoverflow.com/a/75093081/7277928)

License under [MIT License](https://github.com/SamuelFolledo/FuFight/blob/master/LICENSE)
