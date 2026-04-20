//
//  ChefOrderTabView.swift
//  Cooked Local
//

import SwiftUI

struct ChefOrderTabView: View {
    @ObservedObject var viewModel: ChefOrderViewModel
    @Binding var selectedTab: HomeTab

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    filterSection

                    orderItemsSection
                }
                .padding(.bottom, viewModel.hasSelection && viewModel.selectedFilter == .pending ? 80 : DesignTokens.Spacing.lg)
            }
            .background(Color.backgroundColor)

            if viewModel.hasSelection && viewModel.selectedFilter == .pending {
                makeDeliveryButton
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
                Button(action: { viewModel.selectFilter(filter) }) {
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
                        showSelectionIndicator: viewModel.selectedFilter == .pending,
                        isSelected: viewModel.isItemSelected(orderItem),
                        onTap: {
                            if viewModel.selectedFilter == .pending {
                                viewModel.toggleSelection(orderItem)
                            }
                        }
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

    // MARK: - Make As Delivery Button
    private var makeDeliveryButton: some View {
        Button(action: { viewModel.makeAsDelivery() }) {
            Text("Make As Delivery (\(viewModel.selectedCount))")
                .font(.anton(DesignTokens.FontSize.body))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.md)
                .background(Color.brandOrange)
                .cornerRadius(DesignTokens.CornerRadius.large)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(Color.backgroundColor)
    }
}

// MARK: - OrderItemCard

struct OrderItemCard: View {
    let orderItem: APIOrderItem
    var showSelectionIndicator: Bool = false
    var isSelected: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Thumbnail
            Group {
                if let urlString = orderItem.menu?.thumbnail, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().aspectRatio(contentMode: .fill)
                                .transition(.opacity.animation(.easeIn(duration: 0.3)))
                        default:
                            thumbnailPlaceholder
                        }
                    }
                } else {
                    thumbnailPlaceholder
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(orderItem.menu?.title ?? "Order")
                        .font(.system(size: DesignTokens.FontSize.body, weight: .semibold))
                        .foregroundColor(.neutral900)
                        .lineLimit(1)

                    Spacer()

                    if showSelectionIndicator {
                        Circle()
                            .fill(isSelected ? Color.brandOrange : Color.clear)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(isSelected ? Color.brandOrange : Color.neutral100, lineWidth: 2)
                            )
                    }
                }

                if let size = orderItem.size {
                    Text("Size: \(size.capitalized)")
                        .font(.system(size: DesignTokens.FontSize.caption))
                        .foregroundColor(.neutral600)
                }

                if let qty = orderItem.totalQuantity {
                    Text("Qty: \(qty)")
                        .font(.system(size: DesignTokens.FontSize.caption))
                        .foregroundColor(.neutral600)
                }

                HStack {
                    if let price = orderItem.menu?.normalPrice {
                        Text("£ \(String(format: "%.2f", price))")
                            .font(.anton(DesignTokens.FontSize.body))
                            .foregroundColor(.neutral900)
                    }

                    Spacer()

                    if let status = orderItem.deliveryStatus {
                        Text(status.capitalized)
                            .font(.system(size: DesignTokens.FontSize.caption, weight: .medium))
                            .foregroundColor(statusColor(status))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(statusColor(status).opacity(0.1))
                            .cornerRadius(DesignTokens.CornerRadius.small)
                    }
                }
            }
        }
        .padding(DesignTokens.Spacing.sm)
        .background(Color.white)
        .cornerRadius(DesignTokens.CornerRadius.medium)
        .onTapGesture { onTap?() }
    }

    private var thumbnailPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small)
                .fill(Color.neutral100)
            Image(systemName: "fork.knife")
                .font(.system(size: 24))
                .foregroundColor(.neutral600)
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "delivered": return .green
        case "cancelled": return .red
        default: return .brandOrange
        }
    }
}

#Preview {
    ChefOrderTabView(
        viewModel: ChefOrderViewModel(router: Router()),
        selectedTab: .constant(.myOrder)
    )
}
