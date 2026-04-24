//
//  EditDishViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class EditDishViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedCategory: String
    @Published var dishTitle: String
    @Published var dishDescription: String
    @Published var deliveryTime: String
    @Published var sizes: [DishSizeEntry]
    @Published var selectedImage: UIImage?
    @Published private(set) var categories: [FoodCategory] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Dependencies
    private let router: Router
    let foodItem: FoodItem
    private let menuService: MenuService
    private let categoryService: CategoryService

    // Derived category id
    private var selectedCategoryId: String? {
        categories.first(where: { $0.name == selectedCategory })?.id
    }

    // MARK: - Initialization
    init(foodItem: FoodItem, router: Router, menuService: MenuService, categoryService: CategoryService) {
        self.foodItem = foodItem
        self.router = router
        self.menuService = menuService
        self.categoryService = categoryService
        self.dishTitle = foodItem.name
        self.dishDescription = foodItem.description
        self.deliveryTime = foodItem.deliveryTime
        self.selectedCategory = ""

        // Initialize sizes from food item
        if let sizePrices = foodItem.sizePrices, !sizePrices.isEmpty {
            self.sizes = sizePrices.map {
                DishSizeEntry(size: $0.size.capitalized, price: String(format: "%.2f", $0.price))
            }
        } else {
            self.sizes = [DishSizeEntry(size: "Medium", price: String(format: "%.2f", foodItem.price))]
        }

        Task { await loadCategories() }
    }

    // MARK: - Methods
    func addAnotherSize() {
        sizes.append(DishSizeEntry())
    }

    func removeSize(at index: Int) {
        guard sizes.count > 1 else { return }
        sizes.remove(at: index)
    }

    @MainActor
    func updateDish() {
        guard !dishTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a dish title."
            return
        }

        var sizePrices: [MenuSizePriceInput] = []
        for entry in sizes {
            guard !entry.size.isEmpty, let price = Double(entry.price), price > 0 else {
                errorMessage = "Please fill in all size and price fields."
                return
            }
            sizePrices.append(MenuSizePriceInput(
                size: entry.size,
                price: price,
                totalQuantity: 999
            ))
        }

        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)

        isLoading = true
        errorMessage = nil

        Task { @MainActor in
            do {
                try await menuService.updateMenu(
                    id: foodItem.id,
                    title: dishTitle,
                    description: dishDescription,
                    categoryId: selectedCategoryId,
                    sizePrices: sizePrices,
                    deliveryTime: deliveryTime,
                    image: imageData
                )
                NotificationCenter.default.post(name: Notification.Name("menuDidChange"), object: nil)
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
            // Set selected category from food item's category
            if let catId = foodItem.categoryId,
               let match = categories.first(where: { $0.id == catId }) {
                selectedCategory = match.name
            } else if let first = categories.first {
                selectedCategory = first.name
            }
        } catch {
            print("[EditDishViewModel] loadCategories error: \(error)")
        }
    }
}

// MARK: - Dish Size Entry
struct DishSizeEntry: Identifiable {
    let id = UUID().uuidString
    var size: String = ""
    var price: String = ""
}
