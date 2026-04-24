//
//  FoodDetailViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

enum FoodSize: String, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
}

final class FoodDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedSize: FoodSize = .medium
    @Published var quantity: Int = 1
    @Published private(set) var cartItemCount: Int = 0

    // MARK: - Properties
    let foodItem: FoodItem
    let isFromOrder: Bool
    let isFromChef: Bool

    // MARK: - Dependencies
    private let router: Router
    private let cartManager: CartManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(foodItem: FoodItem, router: Router, cartManager: CartManager, isFromOrder: Bool = false, isFromChef: Bool = false) {
        self.foodItem = foodItem
        self.router = router
        self.cartManager = cartManager
        self.isFromOrder = isFromOrder
        self.isFromChef = isFromChef
        setupCartObserver()
    }

    // MARK: - Computed

    var priceForSelectedSize: Double {
        price(for: selectedSize)
    }

    func price(for size: FoodSize) -> Double {
        if let sizePrices = foodItem.sizePrices,
           let match = sizePrices.first(where: { $0.size.lowercased() == size.rawValue.lowercased() }) {
            return match.price
        }
        return foodItem.price
    }

    // MARK: - Methods

    func goBack() {
        router.pop()
    }

    func incrementQuantity() {
        quantity += 1
    }

    func decrementQuantity() {
        guard quantity > 1 else { return }
        quantity -= 1
    }

    func addToCart() {
        for _ in 0..<quantity {
            cartManager.addItem(foodItem, size: selectedSize)
        }
        router.pop()
    }

    func navigateToCart() {
        router.navigate(to: .cart)
    }

    func navigateToReview() {
        router.navigate(to: .review(item: foodItem))
    }

    private func setupCartObserver() {
        cartManager.$items
            .map { $0.reduce(0) { $0 + $1.quantity } }
            .receive(on: DispatchQueue.main)
            .assign(to: &$cartItemCount)
    }
}
