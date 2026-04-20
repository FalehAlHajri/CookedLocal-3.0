//
//  SearchView.swift
//  Cooked Local
//

import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    if !viewModel.suggestions.isEmpty {
                        suggestionsSection
                    }

                    recommendedSection
                }
                .padding(.bottom, DesignTokens.Spacing.lg)
            }
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
        .onAppear {
            isSearchFocused = true
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Button(action: { viewModel.goBack() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.neutral900)
                    .frame(width: 44, height: 44)
                    .background(Color.neutral100.opacity(0.5))
                    .clipShape(Circle())
            }

            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.brandOrange)
                    .font(.system(size: 18, weight: .medium))

                TextField("", text: $viewModel.searchText, prompt: Text("Search Your Food/Chef").foregroundColor(.neutral600))
                    .font(.system(size: DesignTokens.FontSize.body))
                    .foregroundColor(.neutral900)
                    .tint(.neutral900)
                    .focused($isSearchFocused)
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(Color.neutral100.opacity(0.3))
            .cornerRadius(DesignTokens.CornerRadius.medium)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.top, DesignTokens.Spacing.md)
        .padding(.bottom, DesignTokens.Spacing.sm)
    }

    // MARK: - Suggestions Section
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            ForEach(viewModel.suggestions) { suggestion in
                Button(action: { viewModel.selectSuggestion(suggestion) }) {
                    HStack(spacing: 4) {
                        Text(suggestion.text)
                            .font(.system(size: DesignTokens.FontSize.body))
                            .foregroundColor(.neutral900)

                        if let shopName = suggestion.shopName {
                            Text(shopName)
                                .font(.system(size: DesignTokens.FontSize.body))
                                .foregroundColor(.neutral600.opacity(0.6))
                        }

                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.top, DesignTokens.Spacing.xs)
    }

    // MARK: - Recommended Section
    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Recommended")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)
                .padding(.horizontal, DesignTokens.Spacing.md)

            categoriesSection

            foodItemsSection
        }
    }

    // MARK: - Categories Section
    private var categoriesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                ForEach(viewModel.categories) { category in
                    CategoryChip(
                        category: category,
                        isSelected: viewModel.selectedCategory?.id == category.id,
                        action: { viewModel.selectCategory(category) }
                    )
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
        }
    }

    // MARK: - Food Items Section
    private var foodItemsSection: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            ForEach(viewModel.foodItems) { item in
                FoodItemCard(
                    item: item,
                    isInCart: viewModel.isInCart(item),
                    onAdd: { viewModel.addFoodItem(item) },
                    onTap: { viewModel.navigateToFoodDetail(item) }
                )
                .padding(.horizontal, DesignTokens.Spacing.md)
            }
        }
    }
}

#Preview {
    SearchView(viewModel: SearchViewModel(router: Router(), cartManager: CartManager(), menuService: MenuService(), categoryService: CategoryService()))
}
