//
//  PaymentMethodsView.swift
//  Cooked Local
//

import SwiftUI

struct PaymentMethodsView: View {
    @EnvironmentObject private var router: Router
    @State private var hasPaymentMethods: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            if hasPaymentMethods {
                filledStateView
            } else {
                emptyStateView
            }
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Button(action: { router.pop() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.neutral900)
                    .frame(width: 44, height: 44)
                    .background(Color.neutral100.opacity(0.5))
                    .clipShape(Circle())
            }

            Text("Payment")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    // MARK: - Filled State
    private var filledStateView: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            // Stripe card
            HStack(spacing: DesignTokens.Spacing.sm) {
                Circle()
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text("S")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )

                Text("Pay with Stripe")
                    .font(.system(size: DesignTokens.FontSize.body))
                    .foregroundColor(.neutral900)

                Spacer()
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(Color.white)
            .cornerRadius(DesignTokens.CornerRadius.medium)
            .padding(.horizontal, DesignTokens.Spacing.md)

            addPaymentButton

            Spacer()
        }
        .padding(.top, DesignTokens.Spacing.sm)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Spacer()

            Image(systemName: "creditcard.trianglebadge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.brandOrange)

            Text("No Payment Method Added")
                .font(.anton(DesignTokens.FontSize.headline))
                .foregroundColor(.neutral900)

            Text("You can add your payment Method")
                .font(.system(size: DesignTokens.FontSize.body))
                .foregroundColor(.neutral600)

            addPaymentButton

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Add Payment Button
    private var addPaymentButton: some View {
        Button(action: { hasPaymentMethods = true }) {
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                Text("Add Payment")
                    .font(.anton(DesignTokens.FontSize.body))
            }
            .foregroundColor(.white)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(Color.brandOrange)
            .cornerRadius(DesignTokens.CornerRadius.pill)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }
}

#Preview {
    PaymentMethodsView()
        .environmentObject(Router())
}
