//
//  SignUpView.swift
//  Cooked Local
//

import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel: SignUpViewModel

    var body: some View {
        AuthScreenLayout(imageName: "GirlEatingPizza", showBackButton: true) {
            Spacer()

            Text("Sign up")
                .font(.anton(DesignTokens.FontSize.headline))
                .foregroundColor(Color.neutral900)

            Spacer()

            OutlinedButton(title: "Sign up with Email") {
                viewModel.continueToDetails()
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)

            // Continue with Apple
            Button(action: {
                // Apple Sign In
            }) {
                HStack(spacing: DesignTokens.Spacing.xs) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 18))
                    Text("Continue with Apple")
                        .font(.anton(DesignTokens.FontSize.body))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.md)
                .background(Color.primary900)
                .cornerRadius(DesignTokens.CornerRadius.large)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)

            // OR divider
            HStack {
                Rectangle()
                    .fill(Color.neutral100)
                    .frame(height: 1)
                Text("OR")
                    .font(.system(size: DesignTokens.FontSize.caption))
                    .foregroundColor(.neutral600)
                    .padding(.horizontal, DesignTokens.Spacing.xs)
                Rectangle()
                    .fill(Color.neutral100)
                    .frame(height: 1)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)

            // Already have an account
            Text("Already have an account ?")
                .font(.system(size: DesignTokens.FontSize.body))
                .foregroundColor(.neutral600)

            OutlinedButton(title: "Sign In") {
                viewModel.navigateToSignIn()
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.bottom, DesignTokens.Spacing.xxl)
        }
    }
}

#Preview {
    SignUpView(viewModel: SignUpViewModel(
        role: .customer,
        router: Router(),
        validationService: ValidationService()
    ))
}
