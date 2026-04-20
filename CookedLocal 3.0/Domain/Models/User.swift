//
//  User.swift
//  Cooked Local
//

import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let email: String
    let role: UserRole
    var profileUrl: String?
    var shopName: String?

    init(
        id: String = UUID().uuidString,
        name: String,
        email: String,
        role: UserRole,
        profileUrl: String? = nil,
        shopName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.profileUrl = profileUrl
        self.shopName = shopName
    }
}
