//
//  ConfirmOrderViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class ConfirmOrderViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var cartItems: [CartItem] = []
    @Published private(set) var subtotal: Double = 0
    @Published private(set) var totalItems: Int = 0
    let deliveryFee: Double = 0.00
    let deliveryAddress: String = "Nottingham, UK"

    // MARK: - Computed Properties
    var totalBill: Double {
        subtotal + deliveryFee
    }

    // MARK: - Dependencies
    private let router: Router
    private let cartManager: CartManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(router: Router, cartManager: CartManager) {
        self.router = router
        self.cartManager = cartManager
        setupCartObserver()
    }

    // MARK: - Methods
    func removeItem(_ cartItem: CartItem) {
        cartManager.removeItem(cartItem.foodItem)
    }

    func incrementQuantity(_ cartItem: CartItem) {
        cartManager.incrementQuantity(for: cartItem.foodItem)
    }

    func decrementQuantity(_ cartItem: CartItem) {
        cartManager.decrementQuantity(for: cartItem.foodItem)
    }

    func placeOrder() {
        router.navigate(to: .payment)
    }

    func goBack() {
        router.pop()
    }

    // MARK: - Private Methods
    private func setupCartObserver() {
        cartManager.$items
            .sink { [weak self] items in
                self?.cartItems = items
                self?.subtotal = items.reduce(0) { $0 + $1.foodItem.price * Double($1.quantity) }
                self?.totalItems = items.reduce(0) { $0 + $1.quantity }
            }
            .store(in: &cancellables)
    }
}
