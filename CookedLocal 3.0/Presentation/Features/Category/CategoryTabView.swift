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

                    foodItemsSection
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
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
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

#Preview {
    CategoryTabView(
        viewModel: CategoryViewModel(router: Router(), cartManager: CartManager(), menuService: MenuService(), categoryService: CategoryService()),
        selectedTab: .constant(.categories)
    )
}
