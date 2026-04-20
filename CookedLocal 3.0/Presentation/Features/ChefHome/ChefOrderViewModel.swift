//
//  ChefOrderViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

private let pageSize = 10

final class ChefOrderViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedFilter: OrderFilter = .pending
    @Published private(set) var orderItems: [APIOrderItem] = []
    @Published var selectedItemIds: Set<String> = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoadingMore: Bool = false
    @Published private(set) var hasMore: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Pagination
    private var currentPage: Int = 1

    // MARK: - Computed Properties
    var selectedCount: Int { selectedItemIds.count }
    var hasSelection: Bool { !selectedItemIds.isEmpty }

    // MARK: - Dependencies
    private let router: Router
    private let orderService: OrderService

    // MARK: - Initialization
    init(router: Router, orderService: OrderService = OrderService()) {
        self.router = router
        self.orderService = orderService
        Task { await loadOrders(page: 1, append: false) }
    }

    // MARK: - Methods

    func toggleSelection(_ item: APIOrderItem) {
        if selectedItemIds.contains(item.id) {
            selectedItemIds.remove(item.id)
        } else {
            selectedItemIds.insert(item.id)
        }
    }

    func isItemSelected(_ item: APIOrderItem) -> Bool {
        selectedItemIds.contains(item.id)
    }

    @MainActor
    func makeAsDelivery() {
        let ids = Array(selectedItemIds)
        selectedItemIds.removeAll()
        Task {
            do {
                try await orderService.updateDeliveryStatus(orderIds: ids, status: "delivered")
                currentPage = 1
                await loadOrders(page: 1, append: false)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    @MainActor
    func selectFilter(_ filter: OrderFilter) {
        selectedFilter = filter
        selectedItemIds.removeAll()
        currentPage = 1
        Task { await loadOrders(page: 1, append: false) }
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
        await loadOrders(page: 1, append: false)
    }

    // MARK: - Private Methods

    @MainActor
    private func loadOrders(page: Int, append: Bool) async {
        if append {
            isLoadingMore = true
        } else {
            isLoading = true
        }
        errorMessage = nil
        defer {
            isLoading = false
            isLoadingMore = false
        }
        do {
            let newItems = try await orderService.fetchShopOrders(
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
            errorMessage = error.localizedDescription
        }
    }
}
