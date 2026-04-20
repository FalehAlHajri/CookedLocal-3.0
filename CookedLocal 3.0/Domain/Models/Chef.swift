//
//  Chef.swift
//  Cooked Local
//

import Foundation

// MARK: - ChefSocialInfo

struct ChefSocialInfo: Hashable {
    let facebookUrl: String?
    let instagramUrl: String?
    let whatsappNumber: String?
}

// MARK: - Chef

struct Chef: Identifiable, Hashable {
    let id: String
    let name: String
    let bannerImageName: String
    let profileImageName: String
    let rating: Double
    let reviewCount: Int
    let hasFacebook: Bool
    let hasInstagram: Bool
    let hasWhatsApp: Bool

    // New fields from API
    var imageURL: String?
    var bannerURL: String?
    var bio: String?
    var shopId: String
    var socialInfo: ChefSocialInfo?
    var location: String?
    var qualification: String?

    init(
        id: String = UUID().uuidString,
        name: String,
        bannerImageName: String,
        profileImageName: String,
        rating: Double = 4.5,
        reviewCount: Int = 120,
        hasFacebook: Bool = true,
        hasInstagram: Bool = true,
        hasWhatsApp: Bool = true,
        imageURL: String? = nil,
        bannerURL: String? = nil,
        bio: String? = nil,
        shopId: String = "",
        socialInfo: ChefSocialInfo? = nil,
        location: String? = nil,
        qualification: String? = nil
    ) {
        self.id = id
        self.name = name
        self.bannerImageName = bannerImageName
        self.profileImageName = profileImageName
        self.rating = rating
        self.reviewCount = reviewCount
        self.hasFacebook = hasFacebook
        self.hasInstagram = hasInstagram
        self.hasWhatsApp = hasWhatsApp
        self.imageURL = imageURL
        self.bannerURL = bannerURL
        self.bio = bio
        self.shopId = shopId
        self.socialInfo = socialInfo
        self.location = location
        self.qualification = qualification
    }
}

extension Chef {
    static let samples: [Chef] = [
        Chef(name: "Tt Bakery Shop", bannerImageName: "bgShef", profileImageName: "chefImage"),
        Chef(name: "Tt Bakery Shop", bannerImageName: "bgShef", profileImageName: "chefImage"),
        Chef(name: "Tt Bakery Shop", bannerImageName: "bgShef", profileImageName: "chefImage"),
        Chef(name: "Tt Bakery Shop", bannerImageName: "bgShef", profileImageName: "chefImage")
    ]
}
