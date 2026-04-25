//
//  CartViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class CartViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var cartItems: [CartItem] = []
    @Published private(set) var totalPrice: Double = 0
    @Published private(set) var totalItems: Int = 0

    // MARK: - Dependencies
    let router: Router
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
        cartManager.removeCartItem(cartItem)
    }

    func incrementQuantity(_ cartItem: CartItem) {
        cartManager.incrementQuantity(for: cartItem)
    }

    func decrementQuantity(_ cartItem: CartItem) {
        cartManager.decrementQuantity(for: cartItem)
    }

    func goBack() {
        router.pop()
    }

    func checkout() {
        router.navigate(to: .confirmOrder)
    }

    // MARK: - Private Methods
    private func setupCartObserver() {
        cartManager.$items
            .sink { [weak self] items in
                self?.cartItems = items
                self?.totalPrice = items.reduce(0) { $0 + $1.effectivePrice * Double($1.quantity) }
                self?.totalItems = items.reduce(0) { $0 + $1.quantity }
            }
            .store(in: &cancellables)
    }
}
