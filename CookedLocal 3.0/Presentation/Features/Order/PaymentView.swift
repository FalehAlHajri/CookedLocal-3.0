//
//  PaymentView.swift
//  Cooked Local
//

import SwiftUI

struct PaymentView: View {
    @StateObject var viewModel: PaymentViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            VStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    PaymentOptionRow(
                        method: method,
                        isSelected: viewModel.selectedMethod == method,
                        onSelect: { viewModel.selectedMethod = method }
                    )
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                }

                PrimaryButton(title: "Next", action: { viewModel.proceed() }, isLoading: viewModel.isLoading)
                .padding(.top, DesignTokens.Spacing.sm)
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.top, DesignTokens.Spacing.md)

            Spacer()
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

            Text("Payment")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
    }
}

// MARK: - Payment Option Row
struct PaymentOptionRow: View {
    let method: PaymentMethod
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: method.icon)
                    .font(.system(size: 16))
                    .foregroundColor(method.iconColor)
                    .frame(width: 24)

                Text(method.displayName)
                    .font(.system(size: DesignTokens.FontSize.body, weight: .medium))
                    .foregroundColor(.neutral900)

                Spacer()

                Circle()
                    .stroke(isSelected ? Color.brandOrange : Color.neutral100, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .fill(isSelected ? Color.brandOrange : Color.clear)
                            .frame(width: 12, height: 12)
                    )
            }
            .padding(DesignTokens.Spacing.md)
            .background(Color.white)
            .cornerRadius(DesignTokens.CornerRadius.medium)
        }
    }
}

#Preview {
    PaymentView(viewModel: PaymentViewModel(router: Router(), cartManager: CartManager(), orderService: OrderService()))
}
