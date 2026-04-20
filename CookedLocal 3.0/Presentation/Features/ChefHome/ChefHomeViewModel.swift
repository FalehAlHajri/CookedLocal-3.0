//
//  ChefHomeViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class ChefHomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedCategory: FoodCategory?
    @Published var selectedTab: HomeTab = .home
    @Published var showMenuForItem: FoodItem?
    @Published private(set) var categories: [FoodCategory] = []
    @Published private(set) var foodItems: [FoodItem] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoadingMore: Bool = false
    @Published private(set) var hasMore: Bool = false

    private var currentPage: Int = 1
    private var currentCategoryName: String? = nil
    private let pageSize = 10

    // MARK: - User Info
    var userName: String {
        let user = SessionManager.shared.currentUser
        if let shopName = user?.shopName, !shopName.isEmpty {
            return shopName
        }
        return user?.name ?? "Welcome"
    }
    let locationManager = LocationManager.shared

    // MARK: - Order Stats (from dashboard)
    @Published private(set) var pendingOrderCount: Int = 0
    @Published private(set) var deliveredOrderCount: Int = 0
    @Published private(set) var cancelledOrderCount: Int = 0

    // MARK: - Tab ViewModels
    let myDishViewModel: MyDishViewModel
    let chefOrderViewModel: ChefOrderViewModel
    let myProfileViewModel: MyProfileViewModel

    // MARK: - Dependencies
    private let router: Router
    private let cartManager: CartManager
    private let menuService: MenuService
    private let categoryService: CategoryService
    private let userService: UserService

    // MARK: - Initialization
    init(
        router: Router,
        cartManager: CartManager,
        menuService: MenuService,
        categoryService: CategoryService,
        userService: UserService
    ) {
        self.router = router
        self.cartManager = cartManager
        self.menuService = menuService
        self.categoryService = categoryService
        self.userService = userService
        self.myDishViewModel = MyDishViewModel(router: router, menuService: menuService)
        self.chefOrderViewModel = ChefOrderViewModel(router: router)
        self.myProfileViewModel = MyProfileViewModel(router: router, isChef: true)
        Task { await loadData() }
    }

    // MARK: - Methods

    func selectCategory(_ category: FoodCategory) {
        if selectedCategory?.id == category.id {
            selectedCategory = nil
            currentCategoryName = nil
            currentPage = 1
            Task { await loadMenus(categoryName: nil, page: 1, append: false) }
        } else {
            selectedCategory = category
            currentCategoryName = category.name
            currentPage = 1
            Task { await loadMenus(categoryName: category.name, page: 1, append: false) }
        }
    }

    @MainActor
    func loadMore() {
        guard hasMore && !isLoadingMore else { return }
        currentPage += 1
        Task { await loadMenus(categoryName: currentCategoryName, page: currentPage, append: true) }
    }

    @MainActor
    func refreshFoodItems() {
        currentPage = 1
        Task { await loadMenus(categoryName: currentCategoryName, page: 1, append: false) }
        Task { await loadDashboard() }
    }

    func navigateToNotifications() {
        router.navigate(to: .notifications)
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

    // MARK: - Private Methods

    @MainActor
    private func loadData() async {
        isLoading = true
        async let categoriesTask = loadCategories()
        async let dashboardTask = loadDashboard()
        await categoriesTask
        await dashboardTask
        isLoading = false
    }

    @MainActor
    private func loadCategories() async {
        do {
            let apiCategories = try await categoryService.fetchCategories()
            categories = apiCategories.map { $0.toFoodCategory() }
            // No default selection — load all items unfiltered
            await loadMenus(categoryName: nil, page: 1, append: false)
        } catch {
            // Keep empty on error
        }
    }

    @MainActor
    private func loadMenus(categoryName: String? = nil, page: Int = 1, append: Bool = false) async {
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
            print("[ChefHomeViewModel] loadMenus error: \(error)")
        }
    }

    @MainActor
    private func loadDashboard() async {
        do {
            let dashboard = try await userService.fetchProviderDashboard()
            pendingOrderCount = dashboard.pendingOrders ?? 0
            deliveredOrderCount = dashboard.deliveredOrders ?? 0
            cancelledOrderCount = dashboard.cancelledOrders ?? 0
        } catch {
            // Keep default zeros
        }
    }
}
