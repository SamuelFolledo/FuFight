//
//  AccountNetworkManager.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/17/24.
//

import Foundation
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
        do {
            let authData = try await auth.createUser(withEmail: email, password: password)
            LOGD("AUTH: Finished creating user from email: \(authData.user.email ?? "")", from: self)
            return authData
        } catch {
            throw error
        }
    }

    ///Update current account's information on Auth.auth()
    static func updateAuthenticatedAccount(username: String, photoURL: URL) async throws {
        guard !username.isEmpty && !photoURL.absoluteString.isEmpty else {
            fatalError("Error updating authenticated account's username to \(username), and photoUrl to \(photoURL)")
        }
        let changeRequest = auth.currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = username
        changeRequest?.photoURL = photoURL
        do {
            try await changeRequest?.commitChanges()
            LOGD("AUTH: Finished updating user's displayName to \(username) and photoURL to \(photoURL.absoluteString)", from: self)
        } catch {
            throw error
        }
    }

    static func deleteAuthData(userId: String) async throws {
        do {
            try await auth.currentUser?.delete()
            LOGD("AUTH: Finished deleting auth data for userId: \(userId)", from: self)
        } catch {
            throw error
        }
    }

    static func logIn(email: String, password: String) async throws -> AuthDataResult? {
        do {
            let authData = try await auth.signIn(withEmail: email, password: password)
            LOGD("AUTH: Finished loggin in for \(authData.user.displayName ?? "")", from: self)
            return authData
        } catch {
            throw error
        }
    }

    static func logOut() async throws {
        do {
            try auth.signOut()
            LOGD("AUTH: Finished logging out", from: self)
        } catch {
            throw error
        }
    }

    static func resetPassword(withEmail email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
            LOGD("AUTH: Finished resetPassword link to \(email)", from: self)
        } catch {
            throw error
        }
    }
}

//MARK: - Storage Extension
extension AccountNetworkManager {
    ///Uploads the image to Storage for the userId passed
    static func storePhoto(_ image: UIImage, for userId: String) async throws -> URL? {
        guard let imageData = image.jpegData(compressionQuality: photoCompressionQuality) else { return nil }
        let metaData: StorageMetadata = StorageMetadata()
        metaData.contentType = "image/jpg"
        let photoReference = profilePhotoStorage.child("\(userId).jpg")
        do {
            let _ = try await photoReference.putDataAsync(imageData, metadata: metaData)
            let url = try await photoReference.downloadURL()
            LOGD("STORAGE: Finished storing account's profile photo with downloadUrl: \(url.absoluteString)", from: self)
            return url
        } catch {
            throw error
        }
    }

    static func deleteStoredPhoto(_ userId: String) async throws {
        let photoReference = profilePhotoStorage.child("\(userId).jpg")
        do {
            try await photoReference.delete()
            LOGD("STORAGE: Finished deleting profile photo from userId: \(userId)", from: self)
        } catch {
            throw error
        }
    }
}

//MARK: - Firestore Extension
extension AccountNetworkManager {
    ///Update user's data on the databaes. Set merge to false to override existing data
    static func setData(account: Account?, merge: Bool = true) async throws {
        if let account {
            let accountRef = accountDb.document(account.userId)
            do {
                try accountRef.setData(from: account, merge: merge)
                LOGD("DB: Finished setData for \(account.displayName)", from: self)
            } catch {
                throw error
            }
        }
    }

    ///fetch user's data from Firestore and returns an account
    static func fetchData(userId: String) async throws -> Account?
    {
        let accountRef = accountDb.document(userId)
        do {
            let account = try await accountRef.getDocument(as: Account.self)
            LOGD("DB: Finished fetching \(account.displayName)", from: self)
            return account
        } catch {
            throw error
        }
    }

    static func deleteData(_ userId: String) async throws {
        do {
            let accountRef = accountDb.document(userId)
            try await accountRef.delete()
            LOGD("DB: Finished deleting account with userId: \(userId)", from: self)
        } catch {
            throw error
        }
    }

    static func isUnique(username: String) async throws -> Bool {
        do {
            let snapshot = try await accountDb.whereField(kUSERNAME, isEqualTo: username).limit(to: 1).getDocuments()
            let hasDuplicate = !snapshot.documents.isEmpty
            LOGD("DB: Username \(username) has duplicates = \(hasDuplicate)", from: self)
            return hasDuplicate
        } catch {
            throw error
        }
    }

    ///Get uiImage from url
//    static func downloadImage(from url: URL) async throws -> UIImage? {
//        let (data, response) = try await URLSession.shared.data(from: url)
//        LOGD("Finished downloading image: \(response.suggestedFilename ?? url.lastPathComponent)")
//        return UIImage(data: data)
//    }
}
