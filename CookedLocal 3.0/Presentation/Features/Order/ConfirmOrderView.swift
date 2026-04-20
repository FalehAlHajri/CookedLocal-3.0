//
//  ConfirmOrderView.swift
//  Cooked Local
//

import SwiftUI

struct ConfirmOrderView: View {
    @StateObject var viewModel: ConfirmOrderViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignTokens.Spacing.md) {
                    addressSection

                    cartItemsSection

                    receiptSection
                }
                .padding(.bottom, 100)
            }

            Spacer()

            bottomBar
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
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

            Text("Confirm  Order")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    // MARK: - Address Section
    private var addressSection: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Image("locationIcon")
                .font(.system(size: 28))
                .foregroundColor(.brandOrange)

            Text(viewModel.deliveryAddress)
                .font(.system(size: DesignTokens.FontSize.body))
                .foregroundColor(.neutral900)
                .lineLimit(2)

            Spacer()

            Image(systemName: "chevron.down")
                .font(.system(size: 14))
                .foregroundColor(.neutral600)
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color.white)
        .cornerRadius(DesignTokens.CornerRadius.medium)
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Cart Items Section
    private var cartItemsSection: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            ForEach(viewModel.cartItems) { item in
                CartItemCard(
                    cartItem: item,
                    onRemove: { viewModel.removeItem(item) },
                    onIncrement: { viewModel.incrementQuantity(item) },
                    onDecrement: { viewModel.decrementQuantity(item) }
                )
                .padding(.horizontal, DesignTokens.Spacing.md)
            }
        }
    }

    // MARK: - Receipt Section
    private var receiptSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Receipt")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            HStack {
                Text("Subtotal ")
                    .font(.system(size: DesignTokens.FontSize.body))
                    .foregroundColor(.neutral900)
                + Text("(Includes VAT)")
                    .font(.system(size: DesignTokens.FontSize.caption))
                    .foregroundColor(.neutral600)

                Spacer()

                Text("£\(String(format: "%.2f", viewModel.subtotal))")
                    .font(.system(size: DesignTokens.FontSize.body))
                    .foregroundColor(.neutral900)
            }

            HStack {
                Text("Delivery Fee")
                    .font(.system(size: DesignTokens.FontSize.body))
                    .foregroundColor(.neutral900)

                Spacer()

                Text("£\(String(format: "%.2f", viewModel.deliveryFee))")
                    .font(.system(size: DesignTokens.FontSize.body))
                    .foregroundColor(.neutral900)
            }

            DashedDivider()
                .padding(.vertical, 4)

            HStack {
                Text("Total Bill")
                    .font(.system(size: DesignTokens.FontSize.body, weight: .semibold))
                    .foregroundColor(.neutral900)

                Spacer()

                Text("£\(String(format: "%.2f", viewModel.totalBill))")
                    .font(.system(size: DesignTokens.FontSize.body, weight: .semibold))
                    .foregroundColor(.neutral900)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color.white)
        .cornerRadius(DesignTokens.CornerRadius.medium)
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("£ \(String(format: "%.2f", viewModel.totalBill))")
                    .font(.anton(DesignTokens.FontSize.subheadline))
                    .foregroundColor(.neutral900)

                Text("Total \(viewModel.totalItems) Items added")
                    .font(.system(size: DesignTokens.FontSize.caption))
                    .foregroundColor(.neutral600)
            }

            Spacer()

            Button(action: { viewModel.placeOrder() }) {
                Text("Place Order")
                    .font(.anton(DesignTokens.FontSize.body))
                    .foregroundColor(.white)
                    .padding(.horizontal, DesignTokens.Spacing.xl)
                    .padding(.vertical, DesignTokens.Spacing.sm)
                    .background(Color.brandOrange)
                    .cornerRadius(DesignTokens.CornerRadius.pill)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(Color.white)
    }
}

// MARK: - Dashed Divider
struct DashedDivider: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 3]))
            .foregroundColor(.neutral100)
        }
        .frame(height: 1)
    }
}

#Preview {
    ConfirmOrderView(viewModel: ConfirmOrderViewModel(router: Router(), cartManager: CartManager()))
}
