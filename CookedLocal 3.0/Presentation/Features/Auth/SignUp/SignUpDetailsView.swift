//
//  SignUpDetailsView.swift
//  Cooked Local
//

import SwiftUI
import AuthenticationServices

struct SignUpDetailsView: View {
    @StateObject var viewModel: SignUpDetailsViewModel

    var body: some View {
        AuthScreenLayout(imageName: "CakeImage", showBackButton: true) {
            Spacer()

            Text("SIGN UP DETAILS")
                .font(.anton(DesignTokens.FontSize.headline))
                .foregroundColor(Color.neutral900)

            Spacer()

            AppTextField(
                placeholder: viewModel.role == .chef ? "Shop Name" : "Name",
                text: $viewModel.name
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)

            AppTextField(
                placeholder: "Email",
                text: $viewModel.email,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)

            PasswordTextField(
                placeholder: "Password",
                text: $viewModel.password
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.anton(DesignTokens.FontSize.caption))
                    .foregroundColor(.red)
                    .padding(.horizontal, DesignTokens.Spacing.lg)
            }

            PrimaryButton(
                title: "Sign Up",
                action: {
                    Task {
                        await viewModel.signUp()
                    }
                },
                isLoading: viewModel.isLoading
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)

            AppleSignInButton {
                Task {
                    await viewModel.signInWithApple()
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.bottom, DesignTokens.Spacing.xxl)
        }
        .onChange(of: viewModel.name) { _ in viewModel.validateForm() }
        .onChange(of: viewModel.email) { _ in viewModel.validateForm() }
        .onChange(of: viewModel.password) { _ in viewModel.validateForm() }
    }
}

#Preview {
    SignUpDetailsView(viewModel: SignUpDetailsViewModel(
        role: .customer,
        router: Router(),
        authService: AuthService(),
        validationService: ValidationService()
    ))
}
