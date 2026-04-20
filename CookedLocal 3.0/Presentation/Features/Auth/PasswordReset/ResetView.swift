//
//  ResetView.swift
//  Cooked Local
//

import SwiftUI

struct ResetView: View {
    @StateObject var viewModel: ResetViewModel

    var body: some View {
        AuthScreenLayout(imageName: "CakeImage", showBackButton: true) {
            Spacer()

            Text("RESET PASSWORD")
                .font(.anton(DesignTokens.FontSize.headline))
                .foregroundColor(Color.neutral900)

            Text("Enter your email to receive a verification code")
                .font(.anton(DesignTokens.FontSize.caption))
                .foregroundColor(Color.neutral600)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignTokens.Spacing.lg)

            Spacer()

            AppTextField(
                placeholder: "Email or Phone Number",
                text: $viewModel.emailOrPhone,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.anton(DesignTokens.FontSize.caption))
                    .foregroundColor(.red)
                    .padding(.horizontal, DesignTokens.Spacing.lg)
            }

            PrimaryButton(
                title: "Submit",
                action: {
                    Task {
                        await viewModel.requestReset()
                    }
                },
                isLoading: viewModel.isLoading
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.bottom, DesignTokens.Spacing.xxl)
        }
    }
}

#Preview {
    ResetView(viewModel: ResetViewModel(
        router: Router(),
        authService: AuthService(),
        validationService: ValidationService()
    ))
}
