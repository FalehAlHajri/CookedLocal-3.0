//
//  AddDishViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class AddDishViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedCategory: String = ""
    @Published var dishTitle: String = ""
    @Published var dishDescription: String = ""
    @Published var deliveryTime: String = "30-45 mins"
    @Published var sizes: [DishSizeEntry] = [DishSizeEntry()]
    @Published var selectedImage: UIImage?
    @Published private(set) var categories: [FoodCategory] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // Derived
    var categoryNames: [String] {
        categories.map { $0.name }
    }
    private var selectedCategoryId: String? {
        categories.first(where: { $0.name == selectedCategory })?.id
    }

    // MARK: - Dependencies
    private let router: Router
    private let menuService: MenuService
    private let categoryService: CategoryService

    // MARK: - Initialization
    init(router: Router, menuService: MenuService, categoryService: CategoryService) {
        self.router = router
        self.menuService = menuService
        self.categoryService = categoryService
        Task { await loadCategories() }
    }

    // MARK: - Methods

    func addAnotherSize() {
        sizes.append(DishSizeEntry())
    }

    @MainActor
    func submitDish() {
        guard !dishTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a dish title."
            return
        }
        guard let categoryId = selectedCategoryId else {
            errorMessage = "Please select a category."
            return
        }
        guard dishDescription.count >= 5 else {
            errorMessage = "Description must be at least 5 characters."
            return
        }
        guard selectedImage != nil else {
            errorMessage = "Please select a food image."
            return
        }

        // Build size prices from entries
        var sizePrices: [MenuSizePriceInput] = []
        for entry in sizes {
            guard !entry.size.isEmpty, let price = Double(entry.price), price > 0 else {
                errorMessage = "Please fill in all size and price fields."
                return
            }
            sizePrices.append(MenuSizePriceInput(
                size: entry.size,
                price: price,
                totalQuantity: 50
            ))
        }

        isLoading = true
        errorMessage = nil

        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)

        Task {
            do {
                try await menuService.createMenu(
                    title: dishTitle,
                    description: dishDescription,
                    categoryId: categoryId,
                    sizePrices: sizePrices,
                    deliveryTime: deliveryTime,
                    image: imageData
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

    func goBack() {
        router.pop()
    }

    // MARK: - Private

    @MainActor
    private func loadCategories() async {
        do {
            let apiCategories = try await categoryService.fetchCategories()
            categories = apiCategories.map { $0.toFoodCategory() }
            if let first = categories.first {
                selectedCategory = first.name
            }
        } catch {
            print("[AddDishViewModel] loadCategories error: \(error)")
        }
    }
}
