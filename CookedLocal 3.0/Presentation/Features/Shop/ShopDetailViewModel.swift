//
//  ShopDetailViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class ShopDetailViewModel: ObservableObject {
    // MARK: - Properties
    let chef: Chef
    @Published var selectedCategory: FoodCategory?
    @Published private(set) var categories: [FoodCategory] = []
    @Published private(set) var popularFoodItems: [FoodItem] = []
    @Published private(set) var allFoodItems: [FoodItem] = []
    @Published private(set) var foodItems: [FoodItem] = []
    @Published private(set) var hasMore: Bool = false
    @Published private(set) var isLoading: Bool = false

    private var displayedCount: Int = 10

    // MARK: - Computed Properties
    var bio: String { chef.bio ?? "No bio available" }
    var location: String { chef.location ?? LocationManager.shared.locationString }
    var deliveryTime: String { "30-50 mins Delivery" }

    // MARK: - Dependencies
    private let router: Router
    private let cartManager: CartManager
    private let menuService: MenuService

    // MARK: - Initialization
    init(chef: Chef, router: Router, cartManager: CartManager, menuService: MenuService, categoryService: CategoryService) {
        self.chef = chef
        self.router = router
        self.cartManager = cartManager
        self.menuService = menuService
        Task { await loadData() }
    }

    // MARK: - Methods
    func selectCategory(_ category: FoodCategory) {
        selectedCategory = category
        displayedCount = 10
        Task { await loadMenusForCategory(category.name) }
    }

    func loadMore() {
        displayedCount += 10
        let slice = Array(allFoodItems.prefix(displayedCount))
        foodItems = slice
        hasMore = allFoodItems.count > displayedCount
    }

    func addFoodItem(_ item: FoodItem) {
        cartManager.addItem(item)
    }

    func isInCart(_ item: FoodItem) -> Bool {
        cartManager.items.contains { $0.foodItem.id == item.id }
    }

    func navigateToFoodDetail(_ item: FoodItem) {
        router.navigate(to: .foodDetail(item: item))
    }

    func goBack() {
        router.pop()
    }

    @MainActor
    func refresh() async {
        await loadData()
    }

    // MARK: - Private Methods

    @MainActor
    private func loadData() async {
        isLoading = true
        await loadAllMenus()
        isLoading = false
    }

    @MainActor
    private func loadAllMenus() async {
        do {
            let shopId = chef.shopId.isEmpty ? nil : chef.shopId
            let apiMenus = try await menuService.fetchMenus(limit: 100, shopId: shopId)
            let items = apiMenus.map { $0.toFoodItem() }

            // Derive unique categories from this shop's menus
            var seen = Set<String>()
            let shopCategories: [FoodCategory] = apiMenus.compactMap { menu in
                guard let cat = menu.category, !seen.contains(cat.id) else { return nil }
                seen.insert(cat.id)
                return cat.toFoodCategory()
            }

            withAnimation {
                allFoodItems = items
                foodItems = Array(items.prefix(displayedCount))
                hasMore = items.count > displayedCount
                popularFoodItems = Array(items.prefix(2))
                categories = shopCategories
                if selectedCategory == nil {
                    selectedCategory = shopCategories.first
                }
            }
        } catch {
            // Keep empty on error
        }
    }

    @MainActor
    private func loadMenusForCategory(_ categoryName: String) async {
        do {
            let shopId = chef.shopId.isEmpty ? nil : chef.shopId
            let apiMenus = try await menuService.fetchMenus(
                limit: 100,
                category: categoryName,
                shopId: shopId
            )
            let items = apiMenus.map { $0.toFoodItem() }
            withAnimation {
                allFoodItems = items
                foodItems = Array(items.prefix(displayedCount))
                hasMore = items.count > displayedCount
            }
        } catch {
            // Keep current items on error
        }
    }
}
