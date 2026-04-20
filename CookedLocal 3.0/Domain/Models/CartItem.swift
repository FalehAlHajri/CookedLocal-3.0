//
//  CartItem.swift
//  Cooked Local
//

import Foundation

struct CartItem: Identifiable, Hashable {
    let id: String
    let foodItem: FoodItem
    var quantity: Int
    let selectedSize: FoodSize

    init(
        id: String = UUID().uuidString,
        foodItem: FoodItem,
        quantity: Int = 1,
        selectedSize: FoodSize = .medium
    ) {
        self.id = id
        self.foodItem = foodItem
        self.quantity = quantity
        self.selectedSize = selectedSize
    }

    /// Price for this item considering the selected size
    var effectivePrice: Double {
        if let sizePrices = foodItem.sizePrices,
           let match = sizePrices.first(where: { $0.size.lowercased() == selectedSize.rawValue.lowercased() }) {
            return match.price
        }
        return foodItem.price
    }

    /// Unique cart key based on item id + size
    var cartKey: String {
        "\(foodItem.id)_\(selectedSize.rawValue)"
    }
}
