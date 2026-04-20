//
//  MyDishViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

private let pageSize = 10

final class MyDishViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var foodItems: [FoodItem] = []
    @Published var showMenuForItem: FoodItem?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoadingMore: Bool = false
    @Published private(set) var hasMore: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Pagination
    private var currentPage: Int = 1

    // MARK: - Dependencies
    private let router: Router
    private let menuService: MenuService

    // MARK: - Initialization
    init(router: Router, menuService: MenuService) {
        self.router = router
        self.menuService = menuService
        Task { await loadData(page: 1, append: false) }
    }

    // MARK: - Methods

    func navigateToAddDish() {
        router.navigate(to: .addDish)
    }

    func navigateToFoodDetail(_ item: FoodItem) {
        router.navigate(to: .foodDetail(item: item, isFromChef: true))
    }

    func showMenu(for item: FoodItem) {
        showMenuForItem = item
    }

    func editDish(_ item: FoodItem) {
        showMenuForItem = nil
        router.navigate(to: .editDish(item: item))
    }

    @MainActor
    func deleteDish(_ item: FoodItem) {
        showMenuForItem = nil
        foodItems.removeAll { $0.id == item.id }
        Task {
            try? await menuService.deleteMenu(id: item.id)
        }
    }

    @MainActor
    func loadMore() {
        guard hasMore && !isLoadingMore else { return }
        currentPage += 1
        Task { await loadData(page: currentPage, append: true) }
    }

    @MainActor
    func refresh() async {
        currentPage = 1
        await loadData(page: 1, append: false)
    }

    // MARK: - Private Methods

    @MainActor
    private func loadData(page: Int, append: Bool) async {
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
            let apiMenus = try await menuService.fetchMenus(page: page, limit: pageSize)
            let newItems = apiMenus.map { $0.toFoodItem() }
            withAnimation {
                if append {
                    foodItems.append(contentsOf: newItems)
                } else {
                    foodItems = newItems
                }
                hasMore = newItems.count == pageSize
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
