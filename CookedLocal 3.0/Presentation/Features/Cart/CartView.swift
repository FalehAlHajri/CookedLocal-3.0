//
//  CartView.swift
//  Cooked Local
//

import SwiftUI

struct CartView: View {
    @StateObject var viewModel: CartViewModel
    @EnvironmentObject var container: DependencyContainer

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            if viewModel.cartItems.isEmpty {
                emptyCartView
            } else {
                cartListView
                Spacer()
                checkoutBar
            }
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
        .overlay(assistantOverlay, alignment: .bottomTrailing)
    }

    private var assistantOverlay: some View {
        let context = AssistantContext(
            userId: SessionManager.shared.currentUser?.id,
            currentScreen: "cart",
            cartItems: viewModel.cartItems.map { item in
                AssistantCartItem(
                    menuId: item.foodItem.id,
                    name: item.foodItem.name,
                    size: item.selectedSize.rawValue,
                    quantity: item.quantity,
                    price: item.foodItem.price
                )
            },
            availableMenus: nil,
            recentOrders: nil
        )
        return AssistantFloatingButton(
            userRole: SessionManager.shared.currentUser?.role ?? "customer",
            currentScreen: "cart",
            context: context,
            router: viewModel.router,
            assistantService: container.assistantService
        )
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

            Text(viewModel.cartItems.isEmpty ? "Cart" : "My Cart list")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    // MARK: - Empty Cart View
    private var emptyCartView: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Spacer()

            Image("emptycartIcon")
                .font(.system(size: 80))
                .foregroundColor(.neutral600)

            Text("Your Cart is empty")
                .font(.anton(DesignTokens.FontSize.headline))
                .foregroundColor(.neutral900)

            Text("Fill up your cart fresh food ,start\nOrdering now !")
                .font(.system(size: DesignTokens.FontSize.body))
                .foregroundColor(.neutral600)
                .multilineTextAlignment(.center)

            Button(action: { viewModel.goBack() }) {
                Text("View Food Item Now")
                    .font(.anton(DesignTokens.FontSize.body))
                    .foregroundColor(.white)
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.vertical, DesignTokens.Spacing.sm)
                    .background(Color.brandOrange)
                    .cornerRadius(DesignTokens.CornerRadius.pill)
            }

            Spacer()
        }
    }

    // MARK: - Cart List View
    private var cartListView: some View {
        ScrollView(showsIndicators: false) {
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
            .padding(.top, DesignTokens.Spacing.xs)
        }
    }

    // MARK: - Checkout Bar
    private var checkoutBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("£\(String(format: "%.2f", viewModel.totalPrice))")
                    .font(.anton(DesignTokens.FontSize.subheadline))
                    .foregroundColor(.neutral900)

                Text("Total \(viewModel.totalItems) Items added")
                    .font(.system(size: DesignTokens.FontSize.caption))
                    .foregroundColor(.neutral600)
            }

            Spacer()

            Button(action: { viewModel.checkout() }) {
                Text("Checkout")
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

#Preview {
    CartView(viewModel: CartViewModel(router: Router(), cartManager: CartManager()))
}
