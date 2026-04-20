//
//  MyOrderTabView.swift
//  Cooked Local
//

import SwiftUI

struct MyOrderTabView: View {
    @ObservedObject var viewModel: MyOrderViewModel
    @Binding var selectedTab: HomeTab

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    filterSection

                    orderItemsSection
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

            Text("My Order")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    // MARK: - Filter Section
    private var filterSection: some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            ForEach(OrderFilter.allCases, id: \.self) { filter in
                Button(action: { viewModel.selectedFilter = filter }) {
                    Text(filter.rawValue)
                        .font(.system(size: DesignTokens.FontSize.caption, weight: .medium))
                        .foregroundColor(viewModel.selectedFilter == filter ? .white : .neutral900)
                        .padding(.horizontal, DesignTokens.Spacing.md)
                        .padding(.vertical, DesignTokens.Spacing.xs)
                        .background(
                            viewModel.selectedFilter == filter
                                ? Color.brandOrange
                                : Color.white
                        )
                        .cornerRadius(DesignTokens.CornerRadius.pill)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.pill)
                                .stroke(
                                    viewModel.selectedFilter == filter
                                        ? Color.clear
                                        : Color.neutral100,
                                    lineWidth: 1
                                )
                        )
                }
            }

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Order Items Section
    private var orderItemsSection: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, DesignTokens.Spacing.xl)
            } else if viewModel.orderItems.isEmpty {
                Text("No orders found.")
                    .font(.system(size: DesignTokens.FontSize.body))
                    .foregroundColor(.neutral600)
                    .frame(maxWidth: .infinity)
                    .padding(.top, DesignTokens.Spacing.xl)
            } else {
                ForEach(viewModel.orderItems) { orderItem in
                    OrderItemCard(
                        orderItem: orderItem,
                        onTap: { viewModel.navigateToFoodDetail(for: orderItem) }
                    )
                    .padding(.horizontal, DesignTokens.Spacing.md)
                }
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
    MyOrderTabView(
        viewModel: MyOrderViewModel(router: Router(), cartManager: CartManager()),
        selectedTab: .constant(.myOrder)
    )
}
