//
//  HomeView.swift
//  Cooked Local
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 0) {
            tabContent

            HomeTabBar(selectedTab: $viewModel.selectedTab, isChef: viewModel.isChef)
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
    }

    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        Group {
            switch viewModel.selectedTab {
            case .home:
                homeContent
            case .categories:
                CategoryTabView(
                    viewModel: viewModel.categoryViewModel,
                    selectedTab: $viewModel.selectedTab
                )
            case .myOrder:
                MyOrderTabView(
                    viewModel: viewModel.myOrderViewModel,
                    selectedTab: $viewModel.selectedTab
                )
            case .profile:
                MyProfileTabView(
                    viewModel: viewModel.myProfileViewModel
                )
            }
        }
        .id(viewModel.selectedTab)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedTab)
    }

    // MARK: - Home Content (Categories Only)
    private var homeContent: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    categoriesSection
                }
                .padding(.bottom, DesignTokens.Spacing.lg)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .background(Color.backgroundColor)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            HStack {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    CachedProfileImage(urlString: viewModel.userProfileURL, size: 44)
                        .id(viewModel.userProfileURL)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.userName)
                            .font(.anton(DesignTokens.FontSize.subheadline))
                            .foregroundColor(.white)

                        if viewModel.locationManager.isLoading {
                            Text("Getting location...")
                                .font(.system(size: DesignTokens.FontSize.caption))
                                .foregroundColor(.white.opacity(0.8))
                        } else if !viewModel.locationManager.locationString.isEmpty {
                            Text(viewModel.locationManager.locationString)
                                .font(.system(size: DesignTokens.FontSize.caption))
                                .foregroundColor(.white.opacity(0.8))
                        } else if let location = viewModel.profileLocation, !location.isEmpty {
                            Text(location)
                                .font(.system(size: DesignTokens.FontSize.caption))
                                .foregroundColor(.white.opacity(0.8))
                        } else {
                            Text("Location unavailable")
                                .font(.system(size: DesignTokens.FontSize.caption))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }

                Spacer()

                DeliveryBadge(
                    itemCount: viewModel.cartItemCount,
                    onCartTap: { viewModel.navigateToCart() },
                    onBellTap: { viewModel.navigateToNotifications() }
                )
            }

            Button(action: { viewModel.navigateToSearch() }) {
                SearchBar(text: .constant(""))
                    .allowsHitTesting(false)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.top, DesignTokens.Spacing.md)
        .padding(.bottom, DesignTokens.Spacing.lg)
        .background(Color.secondaryBackgroundColor)
    }

    struct DeliveryBadge: View {
        let itemCount: Int
        let onCartTap: () -> Void
        let onBellTap: () -> Void

        var body: some View {
            HStack(spacing: 0) {
                // Cart section - tappable
                Button(action: onCartTap) {
                    HStack(spacing: 8) {
                        Image("shoppingBagIcon")
                            .frame(width: 24, height: 24)

                        Text(String(format: "%02d", itemCount))
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

                // Bell section - tappable
                Button(action: onBellTap) {
                    Image("bellIcon")
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 12)
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.secondaryColorLight)
            )
        }
    }


    // MARK: - Categories Section
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            if viewModel.isLoading && viewModel.categories.isEmpty {
                Text("Categories")
                    .font(.anton( DesignTokens.FontSize.subheadline))
                    .foregroundColor(.neutral900)
                    .padding(.horizontal, DesignTokens.Spacing.md)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        ForEach(0..<5, id: \.self) { i in
                            CategoryChipSkeleton(width: CGFloat([80, 90, 70, 100, 85][i % 5]))
                        }
                    }
                    .padding(.horizontal, DesignTokens.Spacing.md)
                }
            } else if !viewModel.categories.isEmpty {
                Text("Categories")
                    .font(.anton( DesignTokens.FontSize.subheadline))
                    .foregroundColor(.neutral900)
                    .padding(.horizontal, DesignTokens.Spacing.md)

                // Grid layout for categories
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: DesignTokens.Spacing.md),
                        GridItem(.flexible(), spacing: DesignTokens.Spacing.md)
                    ],
                    spacing: DesignTokens.Spacing.md
                ) {
                    ForEach(viewModel.categories) { category in
                        CategoryCard(
                            category: category,
                            action: { viewModel.selectCategory(category) }
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.categories.count)
            } else {
                Text("No categories found")
                    .font(.system(size: DesignTokens.FontSize.body))
                    .foregroundColor(.neutral600)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignTokens.Spacing.md)
            }
        }
        .padding(.top, DesignTokens.Spacing.md)
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: FoodCategory
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignTokens.Spacing.sm) {
                // Category Image
                if let imageURL = category.imageURL {
                    CachedAsyncImage(
                        urlString: imageURL,
                        contentMode: .fill
                    ) {
                        Color.gray.opacity(0.2)
                    }
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium))
                } else {
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: "fork.knife")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                }

                // Category Name
                Text(category.name)
                    .font(.system(size: DesignTokens.FontSize.body, weight: .medium))
                    .foregroundColor(.neutral900)
                    .lineLimit(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(router: Router(), cartManager: CartManager(), menuService: MenuService(), categoryService: CategoryService(), userService: UserService()))
}
