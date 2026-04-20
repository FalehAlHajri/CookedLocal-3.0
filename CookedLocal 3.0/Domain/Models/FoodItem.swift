//
//  FoodItem.swift
//  Cooked Local
//

import Foundation

// MARK: - SizePrice

struct SizePrice: Hashable {
    let size: String
    let price: Double
    let availableQuantity: Int
    let totalQuantity: Int
}

// MARK: - FoodItem

struct FoodItem: Identifiable, Hashable {
    let id: String
    let name: String
    let imageName: String           // kept for backward compat (default "CakeImage")
    let deliveryTime: String
    let rating: Double
    let reviewCount: Int
    let price: Double
    let currency: String
    let description: String
    let shopName: String
    let shopImageName: String

    // New fields from API
    var imageURL: String?
    var shopId: String
    var categoryId: String?
    var sizePrices: [SizePrice]?
    var isAvailable: Bool
    var shopProfileURL: String?

    init(
        id: String = UUID().uuidString,
        name: String,
        imageName: String = "CakeImage",
        deliveryTime: String = "30-50 mins",
        rating: Double = 4.5,
        reviewCount: Int = 120,
        price: Double,
        currency: String = "£",
        description: String = "A juicy and different fruits item with choclate Flavous . it is mixed up orange and apple. it is Helpful for children . it increase her brain to beeter life.",
        shopName: String = "Tt Bakery Shop",
        shopImageName: String = "chefImage",
        imageURL: String? = nil,
        shopId: String = "",
        categoryId: String? = nil,
        sizePrices: [SizePrice]? = nil,
        isAvailable: Bool = true,
        shopProfileURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.deliveryTime = deliveryTime
        self.rating = rating
        self.reviewCount = reviewCount
        self.price = price
        self.currency = currency
        self.description = description
        self.shopName = shopName
        self.shopImageName = shopImageName
        self.imageURL = imageURL
        self.shopId = shopId
        self.categoryId = categoryId
        self.sizePrices = sizePrices
        self.isAvailable = isAvailable
        self.shopProfileURL = shopProfileURL
    }
}

extension FoodItem {
    static let samples: [FoodItem] = [
        FoodItem(name: "Chines Children Birthday cake in...", imageName: "CakeImage", price: 4.00),
        FoodItem(name: "Chines Children Birthday cake in...", imageName: "birthdayCake", price: 4.00),
        FoodItem(name: "Chines Children Birthday cake in...", imageName: "CakeImage", price: 4.00)
    ]
}
