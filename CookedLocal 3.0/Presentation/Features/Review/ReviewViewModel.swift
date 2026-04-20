//
//  ReviewViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class ReviewViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var rating: Int = 1
    @Published var reviewText: String = ""
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Properties
    let foodItem: FoodItem

    // MARK: - Dependencies
    private let router: Router
    private let orderService: OrderService

    // MARK: - Initialization
    init(foodItem: FoodItem, router: Router, orderService: OrderService = OrderService()) {
        self.foodItem = foodItem
        self.router = router
        self.orderService = orderService
    }

    // MARK: - Methods

    func goBack() {
        router.pop()
    }

    @MainActor
    func sendReview() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Backend route: POST /add/review/:id where :id is menuId
                try await orderService.addReview(
                    menuId: foodItem.id,
                    rating: rating,
                    comment: reviewText
                )
                router.pop()
            } catch let apiError as APIError {
                errorMessage = apiError.errorDescription
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
