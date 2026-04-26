//
//  SignInDetailsView.swift
//  Cooked Local
//

import SwiftUI
import AuthenticationServices

struct SignInDetailsView: View {
    @StateObject var viewModel: SignInDetailsViewModel

    var body: some View {
        AuthScreenLayout(imageName: "CakeImage", showBackButton: true) {
            Spacer()

            Text("SIGN IN DETAILS")
                .font(.anton(DesignTokens.FontSize.headline))
                .foregroundColor(Color.neutral900)

            Spacer()

            AppTextField(
                placeholder: "Email or Phone Number",
                text: $viewModel.emailOrPhone,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)

            PasswordTextField(
                placeholder: "Password",
                text: $viewModel.password
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)

            HStack {
                Spacer()
                Button(action: {
                    viewModel.navigateToResetPassword()
                }) {
                    Text("Forgot Password?")
                        .font(.anton(DesignTokens.FontSize.caption))
                        .foregroundColor(Color.brandOrange)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.anton(DesignTokens.FontSize.caption))
                    .foregroundColor(.red)
                    .padding(.horizontal, DesignTokens.Spacing.lg)
            }

            PrimaryButton(
                title: "Sign In",
                action: {
                    Task {
                        await viewModel.signIn()
                    }
                },
                isLoading: viewModel.isLoading
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)

            // Apple Sign In
            AppleSignInButton {
                Task {
                    await viewModel.signInWithApple()
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.bottom, DesignTokens.Spacing.xxl)
        }
    }
}

#Preview {
    SignInDetailsView(viewModel: SignInDetailsViewModel(
        role: .customer,
        router: Router(),
        authService: AuthService(),
        validationService: ValidationService()
    ))
}
