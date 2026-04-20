//
//  CategoryViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

private let pageSize = 10

final class CategoryViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedCategory: FoodCategory?
    @Published private(set) var categories: [FoodCategory] = []
    @Published private(set) var foodItems: [FoodItem] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoadingMore: Bool = false
    @Published private(set) var hasMore: Bool = false

    // MARK: - Pagination
    private var currentPage: Int = 1
    private var currentCategoryName: String? = nil

    // MARK: - Dependencies
    private let router: Router
    private let cartManager: CartManager
    private let menuService: MenuService
    private let categoryService: CategoryService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(router: Router, cartManager: CartManager, menuService: MenuService, categoryService: CategoryService) {
        self.router = router
        self.cartManager = cartManager
        self.menuService = menuService
        self.categoryService = categoryService
        cartManager.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        Task { await loadData() }
    }

    // MARK: - Methods
    func selectCategory(_ category: FoodCategory) {
        selectedCategory = category
        currentCategoryName = category.name
        currentPage = 1
        Task { await loadMenus(categoryName: category.name, page: 1, append: false) }
    }

    func addFoodItem(_ item: FoodItem) {
        cartManager.addItem(item)
    }

    func isInCart(_ item: FoodItem) -> Bool {
        cartManager.items.contains { $0.foodItem.id == item.id }
    }

    func navigateToSearch() {
        router.navigate(to: .search)
    }

    func navigateToFoodDetail(_ item: FoodItem) {
        router.navigate(to: .foodDetail(item: item))
    }

    @MainActor
    func loadMore() {
        guard hasMore && !isLoadingMore else { return }
        currentPage += 1
        Task { await loadMenus(categoryName: currentCategoryName, page: currentPage, append: true) }
    }

    @MainActor
    func refresh() async {
        await loadData()
    }

    // MARK: - Private Methods

    @MainActor
    private func loadData() async {
        isLoading = true
        currentPage = 1
        do {
            let apiCategories = try await categoryService.fetchCategories()
            categories = apiCategories.map { $0.toFoodCategory() }
            selectedCategory = categories.first
        } catch {
            // Keep empty on error
        }

        if let selected = selectedCategory {
            currentCategoryName = selected.name
            await loadMenus(categoryName: selected.name, page: 1, append: false)
        }
        isLoading = false
    }

    @MainActor
    private func loadMenus(categoryName: String?, page: Int, append: Bool) async {
        if append { isLoadingMore = true }
        defer { if append { isLoadingMore = false } }
        do {
            let apiMenus = try await menuService.fetchMenus(page: page, limit: pageSize, category: categoryName)
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
            // Keep current items on error
        }
    }
}
