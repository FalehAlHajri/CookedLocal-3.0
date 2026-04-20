//
//  SearchViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class SearchViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var searchText: String = ""
    @Published var selectedCategory: FoodCategory?
    @Published private(set) var categories: [FoodCategory] = []
    @Published private(set) var suggestions: [SearchSuggestion] = []
    @Published private(set) var foodItems: [FoodItem] = []
    @Published private(set) var isLoading: Bool = false

    // MARK: - Dependencies
    private let router: Router
    private let cartManager: CartManager
    private let menuService: MenuService
    private let categoryService: CategoryService
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    private var suppressSuggestions = false

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
        Task { await loadInitialData() }
        setupSearchObserver()
    }

    // MARK: - Methods
    func selectCategory(_ category: FoodCategory) {
        selectedCategory = category
        Task { await loadMenus(categoryName: category.name) }
    }

    func selectSuggestion(_ suggestion: SearchSuggestion) {
        suppressSuggestions = true
        suggestions = []
        searchText = suggestion.text
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

    // MARK: - Private Methods

    @MainActor
    private func loadInitialData() async {
        isLoading = true
        do {
            let apiCategories = try await categoryService.fetchCategories()
            categories = apiCategories.map { $0.toFoodCategory() }
            if let cake = categories.first(where: { $0.name.lowercased() == "cake" }) {
                selectedCategory = cake
            } else {
                selectedCategory = categories.first
            }
        } catch {
            categories = FoodCategory.samples
            selectedCategory = categories.first
        }

        // Load all menus initially
        do {
            let apiMenus = try await menuService.fetchMenus()
            foodItems = apiMenus.map { $0.toFoodItem() }
        } catch {
            foodItems = []
        }
        isLoading = false
    }

    private func setupSearchObserver() {
        $searchText
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.performSearch(for: text)
            }
            .store(in: &cancellables)
    }

    private func performSearch(for query: String) {
        searchTask?.cancel()
        searchTask = Task { @MainActor in
            if query.trimmingCharacters(in: .whitespaces).isEmpty {
                suggestions = []
                await loadMenus()
            } else {
                await searchMenus(title: query)
            }
        }
    }

    @MainActor
    private func loadMenus(categoryName: String? = nil) async {
        isLoading = true
        do {
            let apiMenus = try await menuService.fetchMenus(category: categoryName)
            foodItems = apiMenus.map { $0.toFoodItem() }
            suggestions = []
        } catch {
            // Keep current items on error
        }
        isLoading = false
    }

    @MainActor
    private func searchMenus(title: String) async {
        isLoading = true
        async let suggestionsTask = menuService.fetchSuggestions(query: title)
        async let menusTask = menuService.fetchMenus(title: title)
        do {
            let apiSuggestions = try await suggestionsTask
            if suppressSuggestions {
                suppressSuggestions = false
            } else {
                suggestions = apiSuggestions.map { $0.toSearchSuggestion() }
            }
        } catch {
            suppressSuggestions = false
            suggestions = []
        }
        do {
            let apiMenus = try await menusTask
            foodItems = apiMenus.map { $0.toFoodItem() }
        } catch {
            // Keep current items on error
        }
        isLoading = false
    }
}
