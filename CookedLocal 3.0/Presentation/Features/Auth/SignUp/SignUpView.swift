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

            Spacer()

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
