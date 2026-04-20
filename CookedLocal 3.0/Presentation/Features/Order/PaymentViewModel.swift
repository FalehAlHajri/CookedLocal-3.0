//
//  PaymentViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

enum PaymentMethod: String, CaseIterable {
    case stripe
    case cashOnDelivery

    var displayName: String {
        switch self {
        case .stripe: return "Pay with Stripe"
        case .cashOnDelivery: return "Cash on Delivery"
        }
    }

    var icon: String {
        switch self {
        case .stripe: return "creditcard.fill"
        case .cashOnDelivery: return "sterlingsign"
        }
    }

    var iconColor: Color {
        switch self {
        case .stripe: return .purple
        case .cashOnDelivery: return .neutral900
        }
    }
}

final class PaymentViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedMethod: PaymentMethod = .cashOnDelivery
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Dependencies
    private let router: Router
    private let cartManager: CartManager
    private let orderService: OrderService

    // MARK: - Initialization
    init(router: Router, cartManager: CartManager, orderService: OrderService) {
        self.router = router
        self.cartManager = cartManager
        self.orderService = orderService
    }

    // MARK: - Methods
    @MainActor
    func proceed() {
        switch selectedMethod {

        case .stripe:
            placeOnlineOrder()

        case .cashOnDelivery:
            router.navigate(to: .cashOnDelivery)
        }
    }

    func goBack() {
        router.pop()
    }

    // MARK: - Private

    @MainActor
    private func placeOnlineOrder() {
        isLoading = true
        errorMessage = nil

        let menuList: [MenuOrderItem] = cartManager.items.map { cartItem in
            MenuOrderItem(
                menuId: cartItem.foodItem.id,
                size: cartItem.selectedSize.rawValue.lowercased(),
                totalQuantity: cartItem.quantity
            )
        }

        Task {
            do {
                // TODO: Integrate actual Stripe payment and get transactionId
                let transactionId = "stripe_\(UUID().uuidString)"
                _ = try await orderService.createOrder(
                    totalPrice: cartManager.totalPrice,
                    menuList: menuList,
                    address: "Online Payment Order",
                    paymentMethod: "online",
                    note: nil,
                    transactionId: transactionId
                )
                cartManager.clearCart()
                router.navigate(to: .success(
                    message: "Payment Successful",
                    subtitle: "Hurrah ! Your Parcel on the way",
                    buttonTitle: "Back to Home",
                    navigateToHome: true
                ))
            } catch let apiError as APIError {
                errorMessage = apiError.errorDescription
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
