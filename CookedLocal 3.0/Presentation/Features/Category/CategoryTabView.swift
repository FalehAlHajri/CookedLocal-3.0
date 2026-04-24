//
//  CategoryTabView.swift
//  Cooked Local
//

import SwiftUI

struct CategoryTabView: View {
    @ObservedObject var viewModel: CategoryViewModel
    @Binding var selectedTab: HomeTab

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    searchBarSection

                    categoriesSection

                    if viewModel.isLoading && viewModel.foodItems.isEmpty {
                        loadingSection
                    } else if let error = viewModel.errorMessage, viewModel.foodItems.isEmpty {
                        errorSection(message: error)
                    } else {
                        foodItemsSection
                    }
                }
                .padding(.bottom, DesignTokens.Spacing.lg)
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
        .background(Color.backgroundColor)
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Button(action: { selectedTab = .home }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.neutral900)
                    .frame(width: 44, height: 44)
                    .background(Color.neutral100.opacity(0.5))
                    .clipShape(Circle())
            }

            Text("Category")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Spacer()

            cartButton
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    private var cartButton: some View {
        Button(action: { viewModel.navigateToCart() }) {
            HStack(spacing: 8) {
                Image("shoppingBagIcon")
                    .frame(width: 24, height: 24)

                Text(String(format: "%02d", viewModel.cartItemCount))
                    .font(.anton(DesignTokens.FontSize.subheadline))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.brandOrange)
            )
        }
    }

    // MARK: - Search Bar Section
    private var searchBarSection: some View {
        Button(action: { viewModel.navigateToSearch() }) {
            HStack {
                Text("Search Your Food/Chef")
                    .font(.system(size: DesignTokens.FontSize.body))
                    .foregroundColor(.neutral600)

                Spacer()

                Image(systemName: "magnifyingglass")
                    .foregroundColor(.brandOrange)
                    .font(.system(size: 18, weight: .medium))
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(Color.white)
            .cornerRadius(DesignTokens.CornerRadius.medium)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Categories Section
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Explore Categories")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)
                .padding(.horizontal, DesignTokens.Spacing.md)

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
    }

    // MARK: - Loading Section
    private var loadingSection: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading dishes...")
                .font(.system(size: DesignTokens.FontSize.body))
                .foregroundColor(.neutral600)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }

    // MARK: - Error Section
    private func errorSection(message: String) -> some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.neutral600)

            Text(message)
                .font(.system(size: DesignTokens.FontSize.body))
                .foregroundColor(.neutral600)
                .multilineTextAlignment(.center)

            Button(action: {
                Task { await viewModel.refresh() }
            }) {
                Text("Retry")
                    .font(.system(size: DesignTokens.FontSize.body, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.vertical, DesignTokens.Spacing.sm)
                    .background(Color.brandOrange)
                    .cornerRadius(DesignTokens.CornerRadius.pill)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Food Items Section
    private var foodItemsSection: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            if viewModel.foodItems.isEmpty {
                VStack(spacing: DesignTokens.Spacing.md) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 40))
                        .foregroundColor(.neutral600)

                    Text("No dishes found in this category.")
                        .font(.system(size: DesignTokens.FontSize.body))
                        .foregroundColor(.neutral600)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
                .padding(.horizontal, DesignTokens.Spacing.md)
            } else {
                ForEach(viewModel.foodItems) { item in
                    FoodItemCard(
                        item: item,
                        isInCart: viewModel.isInCart(item),
                        onAdd: { viewModel.addFoodItem(item) },
                        onTap: { viewModel.navigateToFoodDetail(item) }
                    )
                    .padding(.horizontal, DesignTokens.Spacing.md)
                }

                if viewModel.hasMore {
                    Button {
                        viewModel.loadMore()
                    } label: {
                        if viewModel.isLoadingMore {
                            ProgressView().scaleEffect(0.8)
                        } else {
                            HStack(spacing: 4) {
                                Text("See more")
                                    .font(.system(size: DesignTokens.FontSize.body))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.neutral600)
                        }
                    }
                    .padding(.top, DesignTokens.Spacing.xs)
                }
            }
        }
    }
}

#Preview {
    CategoryTabView(
        viewModel: CategoryViewModel(router: Router(), cartManager: CartManager(), menuService: MenuService(), categoryService: CategoryService()),
        selectedTab: .constant(.categories)
    )
}
