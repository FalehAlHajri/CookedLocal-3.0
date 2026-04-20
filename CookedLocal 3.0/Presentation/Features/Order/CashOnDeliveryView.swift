//
//  CashOnDeliveryView.swift
//  Cooked Local
//

import SwiftUI

struct CashOnDeliveryView: View {
    @StateObject var viewModel: CashOnDeliveryViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            VStack(spacing: DesignTokens.Spacing.md) {
                IconTextField(
                    icon: "person",
                    placeholder: "User Name",
                    text: $viewModel.userName
                )

                IconTextField(
                    icon: "phone",
                    placeholder: "Phone Number",
                    text: $viewModel.phoneNumber,
                    keyboardType: .phonePad
                )

                IconTextField(
                    icon: "mappin.and.ellipse",
                    placeholder: "Your Location",
                    text: $viewModel.location
                )

                PrimaryButton(title: "Order Now", action: { viewModel.orderNow() }, isLoading: viewModel.isLoading)
                .padding(.top, DesignTokens.Spacing.xs)
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.top, DesignTokens.Spacing.lg)

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

            Text("Cash on Delivery")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
    }
}

// MARK: - Icon Text Field
struct IconTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.neutral600)
                .frame(width: 24)

            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.neutral600))
                .font(.system(size: DesignTokens.FontSize.body))
                .foregroundColor(.neutral900)
                .tint(.neutral900)
                .keyboardType(keyboardType)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(Color.white)
        .cornerRadius(DesignTokens.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                .stroke(Color.neutral100, lineWidth: 1)
        )
    }
}

#Preview {
    CashOnDeliveryView(viewModel: CashOnDeliveryViewModel(router: Router(), cartManager: CartManager()))
}
