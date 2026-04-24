//
//  HomeViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

private let pageSize = 10

final class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var searchText: String = ""
    @Published var selectedCategory: FoodCategory?
    @Published var selectedTab: HomeTab = .home
    @Published private(set) var categories: [FoodCategory] = []
    @Published private(set) var foodItems: [FoodItem] = []
    @Published private(set) var popularChefs: [Chef] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoadingMoreFood: Bool = false
    @Published private(set) var isLoadingMoreChefs: Bool = false
    @Published private(set) var foodHasMore: Bool = false
    @Published private(set) var chefsHasMore: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var cartItemCount: Int = 0
    @Published private(set) var userName: String = "Welcome"
    @Published private(set) var userProfileURL: String?
    @Published private(set) var profileLocation: String?

    // MARK: - User Role
    var isChef: Bool {
        SessionManager.shared.currentUser?.userRole == .chef
    }

    private var foodCurrentPage: Int = 1
    private var chefsCurrentPage: Int = 1
    private var currentCategoryName: String? = nil

    // MARK: - Location
    let locationManager = LocationManager.shared

    // MARK: - Tab ViewModels
    let categoryViewModel: CategoryViewModel
    let myOrderViewModel: MyOrderViewModel
    let myProfileViewModel: MyProfileViewModel

    // MARK: - Dependencies
    private let router: Router
    private let cartManager: CartManager
    private let menuService: MenuService
    private let categoryService: CategoryService
    private let userService: UserService
    private var cancellables = Set<AnyCancellable>()

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
        self.categoryViewModel = CategoryViewModel(router: router, cartManager: cartManager, menuService: menuService, categoryService: categoryService)
        self.myOrderViewModel = MyOrderViewModel(router: router, cartManager: cartManager)
        self.myProfileViewModel = MyProfileViewModel(router: router)
        setupCartObserver()
        setupSessionObserver()
        Task { await loadData() }
    }

    // MARK: - Public Methods

    func selectCategory(_ category: FoodCategory) {
        categoryViewModel.selectCategory(category)
        selectedTab = .categories
    }

    func addFoodItem(_ item: FoodItem, size: FoodSize = .medium) {
        cartManager.addItem(item, size: size)
    }

    func isInCart(_ item: FoodItem) -> Bool {
        cartManager.items.contains { $0.foodItem.id == item.id }
    }

    func viewChefShop(_ chef: Chef) {
        router.navigate(to: .shopDetail(chef: chef))
    }

    func navigateToSearch() {
        router.navigate(to: .search)
    }

    func navigateToCart() {
        router.navigate(to: .cart)
    }

    func navigateToNotifications() {
        router.navigate(to: .notifications)
    }

    func navigateToFoodDetail(_ item: FoodItem) {
        router.navigate(to: .foodDetail(item: item))
    }

    func navigateToCategories() {
        selectedTab = .categories
    }

    @MainActor
    func loadMoreFoodItems() {
        guard foodHasMore && !isLoadingMoreFood else { return }
        foodCurrentPage += 1
        Task { await loadMenus(categoryName: currentCategoryName, page: foodCurrentPage, append: true) }
    }

    @MainActor
    func loadMoreChefs() {
        guard chefsHasMore && !isLoadingMoreChefs else { return }
        chefsCurrentPage += 1
        Task { await loadChefs(page: chefsCurrentPage, append: true) }
    }

    @MainActor
    func refresh() async {
        await loadData()
    }

    // MARK: - Private Methods

    private func setupCartObserver() {
        cartManager.$items
            .map { $0.reduce(0) { $0 + $1.quantity } }
            .assign(to: &$cartItemCount)
    }

    private func setupSessionObserver() {
        if let user = SessionManager.shared.currentUser {
            userName = Self.welcomeName(from: user.name)
            userProfileURL = user.profileUrl
        }
        SessionManager.shared.$currentUser
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.userName = Self.welcomeName(from: user.name)
                self?.userProfileURL = user.profileUrl
            }
            .store(in: &cancellables)
    }

    private static func welcomeName(from fullName: String) -> String {
        let firstName = fullName.split(separator: " ").first.map(String.init) ?? fullName
        return "Welcome \(firstName)"
    }

    @MainActor
    private func loadData() async {
        isLoading = true
        errorMessage = nil
        foodCurrentPage = 1
        chefsCurrentPage = 1

        async let categoriesTask: () = loadCategories()
        async let chefsTask: () = loadChefs(page: 1, append: false)
        async let profileTask: () = loadProfile()
        await categoriesTask
        await chefsTask
        await profileTask

        isLoading = false
    }

    @MainActor
    private func loadProfile() async {
        do {
            let profile = try await userService.fetchMyProfile()
            profileLocation = profile.shop?.location
        } catch {
            // Keep existing location
        }
    }

    @MainActor
    private func loadCategories() async {
        do {
            let apiCategories = try await categoryService.fetchCategories()
            categories = apiCategories.map { $0.toFoodCategory() }
            // No default selection — load all items unfiltered
            await loadMenus(categoryName: nil, page: 1, append: false)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func loadMenus(categoryName: String? = nil, page: Int = 1, append: Bool = false) async {
        if append { isLoadingMoreFood = true }
        defer { if append { isLoadingMoreFood = false } }
        do {
            let apiMenus = try await menuService.fetchMenus(page: page, limit: pageSize, category: categoryName)
            let newItems = apiMenus.map { $0.toFoodItem() }
            withAnimation {
                if append {
                    foodItems.append(contentsOf: newItems)
                } else {
                    foodItems = newItems
                }
                foodHasMore = newItems.count == pageSize
            }
        } catch {
            print("[HomeViewModel] loadMenus error: \(error)")
        }
    }

    @MainActor
    private func loadChefs(page: Int = 1, append: Bool = false) async {
        if append { isLoadingMoreChefs = true }
        defer { if append { isLoadingMoreChefs = false } }
        do {
            let apiProviders = try await userService.fetchProviders(page: page, limit: pageSize)
            let newChefs = apiProviders.map { $0.toChef() }
            withAnimation {
                if append {
                    popularChefs.append(contentsOf: newChefs)
                } else {
                    popularChefs = newChefs
                }
                chefsHasMore = newChefs.count == pageSize
            }
        } catch {
            print("[HomeViewModel] loadChefs error: \(error)")
        }
    }
}
