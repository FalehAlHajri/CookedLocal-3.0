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

enum PaymentState: Equatable {
    case idle
    case creatingSession
    case waitingForPayment
    case verifying
    case success
    case cancelled
    case processing
    case error(String)

    static func == (lhs: PaymentState, rhs: PaymentState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.creatingSession, .creatingSession),
             (.waitingForPayment, .waitingForPayment),
             (.verifying, .verifying),
             (.success, .success),
             (.cancelled, .cancelled),
             (.processing, .processing):
            return true
        case let (.error(a), .error(b)):
            return a == b
        default:
            return false
        }
    }
}

extension Notification.Name {
    static let paymentDeepLink = Notification.Name("paymentDeepLink")
}

final class PaymentViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedMethod: PaymentMethod = .cashOnDelivery
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var statusMessage: String?
    @Published private(set) var paymentState: PaymentState = .idle

    // MARK: - Dependencies
    private let router: Router
    private let cartManager: CartManager
    private let orderService: OrderService
    private let address: String
    private let note: String?
    private var cancellables = Set<AnyCancellable>()
    private var pendingSessionId: String?

    // MARK: - Initialization
    init(router: Router, cartManager: CartManager, orderService: OrderService, address: String, note: String?) {
        self.router = router
        self.cartManager = cartManager
        self.orderService = orderService
        self.address = address
        self.note = note
        setupDeepLinkObserver()
    }

    // MARK: - Methods
    @MainActor
    func proceed() {
        switch selectedMethod {
        case .stripe:
            startStripeCheckout()
        case .cashOnDelivery:
            router.navigate(to: .cashOnDelivery)
        }
    }

    func goBack() {
        router.pop()
    }

    @MainActor
    func retry() {
        statusMessage = nil
        errorMessage = nil
        paymentState = .idle
        startStripeCheckout()
    }

    // MARK: - Private

    private func setupDeepLinkObserver() {
        NotificationCenter.default.publisher(for: .paymentDeepLink)
            .compactMap { $0.object as? URL }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                Task { @MainActor in
                    self?.handleDeepLink(url)
                }
            }
            .store(in: &cancellables)
    }

    @MainActor
    private func handleDeepLink(_ url: URL) {
        switch url.host {
        case "payment-success":
            if let sessionId = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first(where: { $0.name == "session_id" })?
                .value {
                verifyPayment(sessionId: sessionId)
            }
        case "payment-cancelled":
            paymentState = .cancelled
            errorMessage = "Payment was cancelled. You can try again."
            isLoading = false
        default:
            break
        }
    }

    @MainActor
    private func startStripeCheckout() {
        isLoading = true
        errorMessage = nil
        statusMessage = nil
        paymentState = .creatingSession

        let menuList = cartManager.items.map { cartItem in
            MenuOrderItemRequest(
                menu: cartItem.foodItem.id,
                size: cartItem.selectedSize.rawValue.lowercased(),
                total_quantity: cartItem.quantity
            )
        }

        Task {
            do {
                let session = try await orderService.createCheckoutSession(
                    menuList: menuList,
                    address: address,
                    note: note,
                    successUrl: "cookedlocal://payment-success?session_id={CHECKOUT_SESSION_ID}",
                    cancelUrl: "cookedlocal://payment-cancelled"
                )
                pendingSessionId = session.id
                guard let url = URL(string: session.url) else {
                    errorMessage = "Invalid checkout URL"
                    paymentState = .error("Invalid checkout URL")
                    isLoading = false
                    return
                }
                paymentState = .waitingForPayment
                await UIApplication.shared.open(url)
            } catch let apiError as APIError {
                errorMessage = apiError.errorDescription
                paymentState = .error(apiError.errorDescription ?? "Unknown error")
            } catch {
                errorMessage = error.localizedDescription
                paymentState = .error(error.localizedDescription)
            }
            isLoading = false
        }
    }

    @MainActor
    private func verifyPayment(sessionId: String) {
        guard paymentState == .waitingForPayment || paymentState == .processing else { return }
        isLoading = true
        errorMessage = nil
        statusMessage = nil
        paymentState = .verifying

        Task {
            do {
                let status = try await orderService.checkSessionStatus(sessionId: sessionId)
                if status.status == "complete" && status.payment_status == "paid" {
                    cartManager.clearCart()
                    paymentState = .success
                    router.navigate(to: .success(
                        message: "Payment Successful",
                        subtitle: "Hurrah! Your Parcel is on the way",
                        buttonTitle: "Back to Home",
                        navigateToHome: true
                    ))
                } else if status.status == "open" || status.payment_status == "unpaid" {
                    paymentState = .processing
                    statusMessage = "Payment is still processing. You can check your orders later."
                } else {
                    paymentState = .cancelled
                    errorMessage = "Payment was not completed. Please try again."
                }
            } catch let apiError as APIError {
                errorMessage = apiError.errorDescription
                paymentState = .error(apiError.errorDescription ?? "Unknown error")
            } catch {
                errorMessage = error.localizedDescription
                paymentState = .error(error.localizedDescription)
            }
            isLoading = false
        }
    }
}
