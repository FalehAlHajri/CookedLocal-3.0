//
//  CashOnDeliveryViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class CashOnDeliveryViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var userName: String = ""
    @Published var phoneNumber: String = ""
    @Published var location: String = ""
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Dependencies
    private let router: Router
    private let cartManager: CartManager
    private let orderService: OrderService

    // MARK: - Initialization
    init(router: Router, cartManager: CartManager, orderService: OrderService = OrderService()) {
        self.router = router
        self.cartManager = cartManager
        self.orderService = orderService

        // Pre-fill user name from session
        if let user = SessionManager.shared.currentUser {
            self.userName = user.name
        }
    }

    // MARK: - Computed
    var isFormValid: Bool {
        !userName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        !location.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Methods

    @MainActor
    func orderNow() {
        guard isFormValid else {
            errorMessage = "Please fill in all fields."
            return
        }

        isLoading = true
        errorMessage = nil

        // Build menu list from cart items
        let menuList: [MenuOrderItem] = cartManager.items.map { cartItem in
            MenuOrderItem(
                menuId: cartItem.foodItem.id,
                size: cartItem.selectedSize.rawValue.lowercased(),
                totalQuantity: cartItem.quantity
            )
        }

        let paymentInfo = PaymentInfo(
            customerName: userName,
            customerPhone: phoneNumber,
            customerAddress: location
        )

        Task {
            do {
                _ = try await orderService.createOrder(
                    totalPrice: cartManager.totalPrice,
                    menuList: menuList,
                    address: location,
                    paymentMethod: "cash",
                    note: nil,
                    paymentInfo: paymentInfo
                )
                cartManager.clearCart()
                router.navigate(to: .success(
                    message: "Order Placed!",
                    subtitle: "Hurrah! Your Parcel is on the way",
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

    func goBack() {
        router.pop()
    }
}
