//
//  ResetPasswordView.swift
//  Cooked Local
//

import SwiftUI

struct ResetPasswordView: View {
    @StateObject var viewModel: ResetPasswordViewModel

    var body: some View {
        AuthScreenLayout(imageName: "CakeImage", showBackButton: true) {
            Spacer()

            Text("RESET PASSWORD")
                .font(.anton(DesignTokens.FontSize.headline))
                .foregroundColor(Color.neutral900)

            Spacer()

            PasswordTextField(
                placeholder: "New Password",
                text: $viewModel.newPassword
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)

            PasswordTextField(
                placeholder: "Confirm Password",
                text: $viewModel.confirmPassword
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.anton(DesignTokens.FontSize.caption))
                    .foregroundColor(.red)
                    .padding(.horizontal, DesignTokens.Spacing.lg)
            }

            PrimaryButton(
                title: "Reset Password",
                action: {
                    Task {
                        await viewModel.resetPassword()
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
    ResetPasswordView(viewModel: ResetPasswordViewModel(
        router: Router(),
        authService: AuthService(),
        validationService: ValidationService()
    ))
}
