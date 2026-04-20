//
//  FoodCategory.swift
//  Cooked Local
//

import Foundation

struct FoodCategory: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    var imageURL: String?

    init(id: String = UUID().uuidString, name: String, icon: String, imageURL: String? = nil) {
        self.id = id
        self.name = name
        self.icon = icon
        self.imageURL = imageURL
    }
}

extension FoodCategory {
    static let samples: [FoodCategory] = [
        FoodCategory(name: "Pizza", icon: "🍕"),
        FoodCategory(name: "Cake", icon: "🍰"),
        FoodCategory(name: "Burger", icon: "🍔"),
        FoodCategory(name: "Pasta", icon: "🍝")
    ]
}
