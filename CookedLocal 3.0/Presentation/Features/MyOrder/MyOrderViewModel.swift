//
//  MyOrderViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

enum OrderFilter: String, CaseIterable {
    case pending = "Pending"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
}

private let pageSize = 10

final class MyOrderViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedFilter: OrderFilter = .pending {
        didSet {
            currentPage = 1
            Task { await loadOrders(page: 1, append: false) }
        }
    }
    @Published private(set) var orderItems: [APIOrderItem] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoadingMore: Bool = false
    @Published private(set) var hasMore: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Pagination
    private var currentPage: Int = 1

    // MARK: - Dependencies
    private let router: Router
    private let cartManager: CartManager
    private let orderService: OrderService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(router: Router, cartManager: CartManager, orderService: OrderService = OrderService()) {
        self.router = router
        self.cartManager = cartManager
        self.orderService = orderService
        Task { await loadOrders(page: 1, append: false) }
    }

    // MARK: - Methods

    func navigateToFoodDetail(for orderItem: APIOrderItem) {
        guard let menu = orderItem.menu else { return }
        let foodItem = FoodItem(
            id: menu.id,
            name: menu.title ?? "Order",
            imageName: "CakeImage",
            deliveryTime: menu.deliveryTime ?? "30-50 mins",
            rating: menu.avgRating ?? 4.5,
            reviewCount: menu.totalReviews ?? 0,
            price: menu.normalPrice ?? 0,
            imageURL: menu.thumbnail
        )
        router.navigate(to: .foodDetail(item: foodItem, isFromOrder: true))
    }

    @MainActor
    func loadMore() {
        guard hasMore && !isLoadingMore else { return }
        currentPage += 1
        Task { await loadOrders(page: currentPage, append: true) }
    }

    @MainActor
    func refresh() async {
        currentPage = 1
        do {
            let newItems = try await orderService.fetchMyOrders(
                status: selectedFilter.rawValue.lowercased(),
                page: 1,
                limit: pageSize
            )
            orderItems = newItems
            hasMore = newItems.count == pageSize
            errorMessage = nil
        } catch {
            // Keep existing data on any error (cancellation, network, etc.)
        }
    }

    // MARK: - Private Methods

    @MainActor
    private func loadOrders(page: Int, append: Bool) async {
        if append {
            isLoadingMore = true
        } else if orderItems.isEmpty {
            isLoading = true
        }
        errorMessage = nil
        defer {
            isLoading = false
            isLoadingMore = false
        }
        do {
            let newItems = try await orderService.fetchMyOrders(
                status: selectedFilter.rawValue.lowercased(),
                page: page,
                limit: pageSize
            )
            if append {
                orderItems.append(contentsOf: newItems)
            } else {
                orderItems = newItems
            }
            hasMore = newItems.count == pageSize
        } catch {
            if error is CancellationError { return }
            errorMessage = error.localizedDescription
            if !append { orderItems = [] }
        }
    }
}
