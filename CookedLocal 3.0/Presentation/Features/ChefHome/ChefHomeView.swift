//
//  ChefHomeView.swift
//  Cooked Local
//

import SwiftUI

struct ChefHomeView: View {
    @StateObject var viewModel: ChefHomeViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                tabContent

                HomeTabBar(selectedTab: $viewModel.selectedTab, isChef: true)
            }

            // Menu overlay
            if let item = viewModel.showMenuForItem {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.showMenuForItem = nil
                    }

                DishMenuPopup(
                    onEdit: { viewModel.editDish(item) },
                    onDelete: { viewModel.deleteDish(item) }
                )
            }
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
                chefHomeContent
            case .categories:
                MyDishTabView(
                    viewModel: viewModel.myDishViewModel,
                    selectedTab: $viewModel.selectedTab
                )
            case .myOrder:
                ChefOrderTabView(
                    viewModel: viewModel.chefOrderViewModel,
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

    // MARK: - Chef Home Content
    private var chefHomeContent: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    orderOverviewSection

                    yourDishSection

                    foodItemsSection
                }
                .padding(.bottom, DesignTokens.Spacing.lg)
            }
            .refreshable {
                await viewModel.refreshFoodItemsAsync()
            }
            .background(Color.backgroundColor)
        }
        .onAppear { viewModel.refreshFoodItems() }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("menuDidChange"))) { _ in
            viewModel.refreshFoodItems()
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            HStack(spacing: DesignTokens.Spacing.sm) {
                CachedProfileImage(urlString: SessionManager.shared.currentUser?.profileUrl, size: 44)

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

            Button(action: { viewModel.navigateToNotifications() }) {
                Image("bellIcon")
                    .frame(width: 24, height: 24)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(Color.secondaryColorLight)
                    )
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.top, DesignTokens.Spacing.md)
        .padding(.bottom, DesignTokens.Spacing.lg)
        .background(Color.secondaryBackgroundColor)
    }

    // MARK: - Order Overview Section
    private var orderOverviewSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Order Overview")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)
                .padding(.horizontal, DesignTokens.Spacing.md)

            HStack(spacing: DesignTokens.Spacing.sm) {
                OrderStatCard(
                    title: "Pending Order",
                    count: viewModel.pendingOrderCount,
                    backgroundColor: Color.white,
                    titleColor: .neutral600,
                    countColor: .neutral900
                )

                OrderStatCard(
                    title: "Delivered Order",
                    count: viewModel.deliveredOrderCount,
                    backgroundColor: Color.brandOrange,
                    titleColor: .white.opacity(0.8),
                    countColor: .white
                )

                OrderStatCard(
                    title: "Cancelled Order",
                    count: viewModel.cancelledOrderCount,
                    backgroundColor: Color.white,
                    titleColor: .neutral600,
                    countColor: .neutral900
                )
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
        }
        .padding(.top, DesignTokens.Spacing.md)
    }

    // MARK: - Your Dish Section
    private var yourDishSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Your Dish")
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
                    showAddButton: false,
                    showMenuButton: true,
                    onTap: { viewModel.navigateToFoodDetail(item) },
                    onMenu: {
                        viewModel.showMenu(for: item)
                    }
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

// MARK: - Order Stat Card
struct OrderStatCard: View {
    let title: String
    let count: Int
    let backgroundColor: Color
    let titleColor: Color
    let countColor: Color

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            Text("\(count)")
                .font(.anton(DesignTokens.FontSize.headline))
                .foregroundColor(countColor)

            Text(title)
                .font(.system(size: DesignTokens.FontSize.caption))
                .foregroundColor(titleColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(backgroundColor)
        .cornerRadius(DesignTokens.CornerRadius.medium)
    }
}

// MARK: - Dish Menu Popup
struct DishMenuPopup: View {
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onEdit) {
                Text("Edit")
                    .font(.system(size: DesignTokens.FontSize.body, weight: .medium))
                    .foregroundColor(.neutral900)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignTokens.Spacing.sm)
            }

            Divider()

            Button(action: onDelete) {
                Text("Delete")
                    .font(.system(size: DesignTokens.FontSize.body, weight: .medium))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignTokens.Spacing.sm)
            }
        }
        .background(Color.white)
        .cornerRadius(DesignTokens.CornerRadius.medium)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .frame(width: 140)
    }
}

#Preview {
    ChefHomeView(viewModel: ChefHomeViewModel(router: Router(), cartManager: CartManager(), menuService: MenuService(), categoryService: CategoryService(), userService: UserService()))
}
