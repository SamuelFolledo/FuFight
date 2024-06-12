//
//  AccountNetworkManager.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/17/24.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

enum NetworkError: Error {
    ///When there is no error but there is no expected result as well
    case noResult
    case timeout(message: String)
    ///Used when a Account class cannot be created from Firebase's Auth Account
    case invalidAccount
}

class AccountNetworkManager {
    private init() {}
}

//MARK: - Authentication Extension
extension AccountNetworkManager {
    ///Create a user from email and password
    ///Email and password should have been validated already before calling this method
    static func createUser(email: String, password: String) async throws -> AuthDataResult? {
        let authData = try await auth.createUser(withEmail: email, password: password)
        LOGD("AUTH: Finished creating user from email: \(authData.user.email ?? "")", from: self)
        return authData
    }

    ///Deletes and log out the current authenticated user
    static func deleteAuthData(userId: String) async throws {
        try await auth.currentUser?.delete()
        LOGD("AUTH: Finished deleting and logging out the authenticated user with userId: \(userId)", from: self)
    }

    static func logIn(email: String, password: String) async throws -> AuthDataResult? {
        let authData = try await auth.signIn(withEmail: email, password: password)
        LOGD("AUTH: Finished logging in for \(authData.user.displayName ?? "")", from: self)
        return authData
    }

    static func logOut() async throws {
        try auth.signOut()
        LOGD("AUTH: Finished logging out", from: self)
    }

    static func resetPassword(withEmail email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
        LOGD("AUTH: Finished resetPassword link to \(email)", from: self)
    }

    static func reauthenticateUser(password: String) async throws {
        let email = Account.current?.email ?? auth.currentUser!.email!
        let credential = EmailAuthProvider.credential(withEmail: email.trimmed, password: password)
        try await auth.currentUser?.reauthenticate(with: credential)
        LOGD("AUTH: Finished reauthenticating user withEmail: \(email)", from: self)
    }

    static func updatePassword(_ password: String) async throws {
        try await auth.currentUser?.updatePassword(to: password)
        LOGD("AUTH: Finished updating user's password", from: self)
    }

    ///Update current account's username and/or photUrl
    static func updateAuthenticatedUser(username: String? = nil, photoUrl: URL? = nil) async throws {
        let username = (username ?? "").trimmed
        let photoUrlString = (photoUrl?.absoluteString ?? "").trimmed
        let hasUsername = !username.isEmpty
        let hasPhotoUrl = !photoUrlString.isEmpty
        let changeRequest = auth.currentUser?.createProfileChangeRequest()
        if hasUsername {
            LOGD("Updating authenticated user's username to \(username)", from: self)
            changeRequest?.displayName = username
        }
        if hasPhotoUrl {
            LOGD("Updating authenticated user's photoUrl to \(photoUrlString)", from: self)
            changeRequest?.photoURL = photoUrl
        }
        try await changeRequest?.commitChanges()
        LOGD("AUTH: Finished updating user's displayName to \(username) and photoUrl to \(photoUrlString)", from: self)
    }
}

//MARK: - Storage Extension
extension AccountNetworkManager {
    ///Uploads the image to Storage for the userId passed
    static func storePhoto(_ image: UIImage, for userId: String) async throws -> URL? {
        guard let imageData = image.jpegData(compressionQuality: accountPhotoCompressionQuality) else { return nil }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        let photoReference = accountPhotoStorage.child("\(userId).jpg")
        let _ = try await photoReference.putDataAsync(imageData, metadata: metaData)
        let url = try await photoReference.downloadURL()
        LOGD("STORAGE: Finished storing account's profile photo with downloadUrl: \(url.absoluteString)", from: self)
        return url
    }

    static func deleteStoredPhoto(_ userId: String) async throws {
        let photoReference = accountPhotoStorage.child("\(userId).jpg")
        try await photoReference.delete()
        LOGD("STORAGE: Finished deleting profile photo from userId: \(userId)", from: self)
    }
}

//MARK: - Firestore Database Extension
extension AccountNetworkManager {
    ///Update user's data on the database. Set merge to false to override existing data
    static func setData(account: Account?, merge: Bool = true) async throws {
        if let account {
            let accountsRef = accountsDb.document(account.userId)
            try accountsRef.setData(from: account, merge: merge)
            LOGD("DB: Finished setData for \(account.displayName)", from: self)
        }
    }

    ///fetch user's data from Firestore and returns an account
    static func fetchData(userId: String) async throws -> Account? {
        let accountsRef = accountsDb.document(userId)
        let account = try await accountsRef.getDocument(as: Account.self)
        LOGD("DB: Finished fetching \(account.displayName)", from: self)
        return account
    }

    ///Get the document from the Account collections using their username
    static func fetchAccountDocument(with username: String) async throws -> QueryDocumentSnapshot? {
        return try await accountsDb.whereFilter(Filter.whereField(kUSERNAME, isEqualTo: username)).limit(to: 1).getDocuments().documents.first
    }

    ///Delete user's data from Accounts collection
    static func deleteData(_ userId: String) async throws {
        let accountsRef = accountsDb.document(userId)
        try await accountsRef.delete()
        LOGD("DB: Finished deleting account with userId: \(userId)", from: self)
    }

    ///Set username to the database into Accounts collections
    static func updateUsername(to username: String, for userId: String) async throws {
        let username = username.trimmed
        guard !userId.isEmpty,
              !username.isEmpty else { return }
        ///Update Accounts collection
        let accountsRef = accountsDb.document(userId)
        try await accountsRef.setData([kUSERNAME: username], merge: true)
    }

    ///Check Accounts collection in database if username is unique
    static func isUnique(username: String) async throws -> Bool {
        if let _ = try await fetchAccountDocument(with: username) {
            return false
        }
        let isUsernameUnique = true
        LOGD("DB: Username \(username) is unique = \(isUsernameUnique)", from: self)
        return isUsernameUnique
    }

    ///Fetch the email from Usernames collection
    static func fetchEmailFrom(username: String) async throws -> String? {
        guard let accountDocument = try await fetchAccountDocument(with: username) else { return nil }
        if let email = accountDocument.data()[kEMAIL] as? String {
            LOGD("DB: Finished fetching email \(email) from username \(username)", from: self)
            return email
        }
        return nil
    }

    ///Returns true if user has completed onboarding
    static func isAccountValid(userId: String) async throws -> Bool {
        let accountsRef = accountsDb.document(userId)
        let isValid = try await accountsRef.getDocument().exists
        LOGD("Finished validating account \(isValid), id \(userId)")
        return isValid
    }
}
