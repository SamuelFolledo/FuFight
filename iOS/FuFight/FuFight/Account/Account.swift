//
//  Account.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class Account: ObservableObject, Codable {
    @DocumentID private(set) var id: String?
    @Published private(set) var username: String?
    @Published private(set) var email: String?
    @Published private(set) var phoneNumber: String?
    @Published private(set) var createdAt: Date?
    @Published var photoUrl: URL?
    @Published var status: Account.Status = .loggedOut
    @Published var coins: Int = 0
    @Published var diamonds: Int = 0

    var userId: String {
        return id!
    }
    var displayName: String {
        return username ?? ""
    }
    ///Returns the currently signed in Account
    static var current: Account? {
        if let account = AccountManager.getCurrent() {
            return account
        } else if let firUser = auth.currentUser {
            return Account(firUser)
        }
        return nil
    }

    //MARK: - Initializers
    ///Use this initializer for previews only
    init() {
        LOGD("Fake account initialized", from: Account.self)
        id = "fakeId"
        photoUrl = fakePhotoUrl
        email = "samuelfolledo@gmail.com"
        username = "Fake Samuel"
    }

    ///Initializer for sign up only
    convenience init(_ authResult: AuthDataResult) {
        self.init()
        self.email = authResult.user.email
        self.phoneNumber = authResult.user.phoneNumber
        self.username = authResult.user.displayName
        self.photoUrl = authResult.user.photoURL
        self.createdAt = authResult.user.metadata.creationDate
        self.id = authResult.user.uid
    }

    init(_ firUser: User) {
        self.id = firUser.uid
        self.username = firUser.displayName
        self.photoUrl = firUser.photoURL
        self.email = firUser.email
        self.phoneNumber = firUser.phoneNumber
        self.createdAt = firUser.metadata.creationDate
    }

    deinit { }

    //MARK: - Codable overrides
    private enum CodingKeys : String, CodingKey {
        case id, username, photoUrl, email, phoneNumber, createdAt, status, coins, diamonds
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        if let photoUrl {
            try container.encode(photoUrl, forKey: .photoUrl)
        }
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(email, forKey: .email)
        if let phoneNumber {
            try container.encode(phoneNumber, forKey: .phoneNumber)
        }
        try container.encode(status.rawValue, forKey: .status)
        try container.encode(coins, forKey: .coins)
        try container.encode(diamonds, forKey: .diamonds)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decodeIfPresent(String.self, forKey: .id)
        self.username = try values.decodeIfPresent(String.self, forKey: .username)!
        self.photoUrl = try values.decodeIfPresent(URL.self, forKey: .photoUrl)!
        self.email = try values.decodeIfPresent(String.self, forKey: .email)!
        self.phoneNumber = try values.decodeIfPresent(String.self, forKey: .phoneNumber)
        self.createdAt = try values.decodeIfPresent(Date.self, forKey: .createdAt)!
        let statusRawValue = try values.decodeIfPresent(String.self, forKey: .status)!
        self.status = Status(rawValue: statusRawValue) ?? .unfinished
        self.coins = try values.decodeIfPresent(Int.self, forKey: .coins) ?? 0
        self.diamonds = try values.decodeIfPresent(Int.self, forKey: .diamonds) ?? 0
    }

    //MARK: Public Methods

    func finishAccountCreation(username: String, photoUrl: URL) {
        self.username = username
        self.photoUrl = photoUrl
    }

    func updateUsername(_ newUsername: String) {
        self.username = newUsername
    }

    func update(with user: Account) {
        if let id = user.id,
           self.id != id {
            self.id = id
        }
        if let username = user.username,
           self.username != username {
            self.username = username
        }
        if let photoUrl = user.photoUrl,
           self.photoUrl != photoUrl {
            self.photoUrl = photoUrl
        }
        if let email = user.email {
            self.email = email
        }
        if let phoneNumber = user.phoneNumber {
            self.phoneNumber = phoneNumber
        }
        if let createdAt = user.createdAt {
            self.createdAt = createdAt
        }
        self.coins = user.coins
        self.diamonds = user.diamonds
    }

    func reset() {
        //setting username to empty will remove the Delete account button on AuthenticationView
        username = ""
    }
}

//MARK: - Custom Account Classes
extension Account {
    enum Status: String {
        case loggedIn
        ///When account is created but unfinished
        case unfinished
        case loggedOut
    }
}
