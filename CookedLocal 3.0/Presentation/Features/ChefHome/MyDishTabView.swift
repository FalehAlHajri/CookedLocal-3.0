//
//  MyDishTabView.swift
//  Cooked Local
//

import SwiftUI

struct MyDishTabView: View {
    @ObservedObject var viewModel: MyDishViewModel
    @Binding var selectedTab: HomeTab

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerSection

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                        // Add New Dish Button
                        Button(action: { viewModel.navigateToAddDish() }) {
                            HStack(spacing: DesignTokens.Spacing.xs) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Add New Dish")
                                    .font(.anton(DesignTokens.FontSize.body))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DesignTokens.Spacing.md)
                            .background(Color.brandOrange)
                            .cornerRadius(DesignTokens.CornerRadius.large)
                        }

                        // Your Dish section
                        Text("Your Dish")
                            .font(.anton(DesignTokens.FontSize.subheadline))
                            .foregroundColor(.neutral900)

                        // Food items
                        VStack(spacing: DesignTokens.Spacing.sm) {
                            ForEach(viewModel.foodItems) { item in
                                FoodItemCard(
                                    item: item,
                                    showAddButton: false,
                                    showMenuButton: true,
                                    onTap: { viewModel.navigateToFoodDetail(item) },
                                    onMenu: { viewModel.showMenu(for: item) }
                                )
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
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.vertical, DesignTokens.Spacing.md)
                }
                .background(Color.backgroundColor)
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
        .onAppear {
            Task { await viewModel.refresh() }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("menuDidChange"))) { _ in
            Task { await viewModel.refresh() }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Button(action: { selectedTab = .home }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.neutral900)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(Circle())
            }

            Text("My Dish")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(Color.backgroundColor)
    }
}

#Preview {
    MyDishTabView(
        viewModel: MyDishViewModel(router: Router(), menuService: MenuService()),
        selectedTab: .constant(.categories)
    )
}
