//
//  CartManager.swift
//  Cooked Local
//

import Foundation
import Combine

final class CartManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var items: [CartItem] = []

    // MARK: - Computed Properties
    var totalItems: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var totalPrice: Double {
        items.reduce(0) { $0 + $1.effectivePrice * Double($1.quantity) }
    }

    // MARK: - Methods

    func addItem(_ foodItem: FoodItem, size: FoodSize = .medium) {
        let resolvedSize = resolveSize(for: foodItem, requested: size)
        let key = "\(foodItem.id)_\(resolvedSize.rawValue)"
        if let index = items.firstIndex(where: { $0.cartKey == key }) {
            items[index].quantity += 1
        } else {
            items.append(CartItem(foodItem: foodItem, selectedSize: resolvedSize))
        }
    }

    /// Returns the requested size if available, otherwise the first available size from the item.
    private func resolveSize(for foodItem: FoodItem, requested: FoodSize) -> FoodSize {
        guard let sizePrices = foodItem.sizePrices, !sizePrices.isEmpty else {
            return requested
        }
        let availableSizes = sizePrices.map { $0.size.lowercased() }
        if availableSizes.contains(requested.rawValue.lowercased()) {
            return requested
        }
        // Fallback priority: medium → small → large → first available
        for fallback in [FoodSize.medium, .small, .large] {
            if availableSizes.contains(fallback.rawValue.lowercased()) {
                return fallback
            }
        }
        return requested
    }

    /// Remove all items for a food item across all sizes
    func removeItem(_ foodItem: FoodItem) {
        items.removeAll { $0.foodItem.id == foodItem.id }
    }

    /// Remove a specific food item with a given size
    func removeItem(_ foodItem: FoodItem, size: FoodSize) {
        let key = "\(foodItem.id)_\(size.rawValue)"
        items.removeAll { $0.cartKey == key }
    }

    func removeCartItem(_ cartItem: CartItem) {
        items.removeAll { $0.id == cartItem.id }
    }

    func incrementQuantity(for cartItem: CartItem) {
        if let index = items.firstIndex(where: { $0.id == cartItem.id }) {
            items[index].quantity += 1
        }
    }

    func decrementQuantity(for cartItem: CartItem) {
        if let index = items.firstIndex(where: { $0.id == cartItem.id }) {
            if items[index].quantity > 1 {
                items[index].quantity -= 1
            } else {
                items.remove(at: index)
            }
        }
    }

    // Backward compat overloads matching old FoodItem-only CartManager API
    func incrementQuantity(for foodItem: FoodItem) {
        if let index = items.firstIndex(where: { $0.foodItem.id == foodItem.id }) {
            items[index].quantity += 1
        }
    }

    func decrementQuantity(for foodItem: FoodItem) {
        if let index = items.firstIndex(where: { $0.foodItem.id == foodItem.id }) {
            if items[index].quantity > 1 {
                items[index].quantity -= 1
            } else {
                items.remove(at: index)
            }
        }
    }

    func clearCart() {
        items.removeAll()
    }
}
