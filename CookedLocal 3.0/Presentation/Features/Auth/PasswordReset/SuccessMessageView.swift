//
//  SuccessMessageView.swift
//  Cooked Local
//

import SwiftUI

struct SuccessMessageView: View {
    let message: String
    var subtitle: String = "Successfully"
    var buttonTitle: String = "Back to Sign In"
    var navigateToHome: Bool = false
    @EnvironmentObject private var router: Router

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            SuccessBadge()
                .frame(width: 120, height: 120)

            Spacer()
                .frame(height: DesignTokens.Spacing.xxl)

            Text(message)
                .font(.anton(DesignTokens.FontSize.headline))
                .foregroundColor(Color.neutral900)

            Spacer()
                .frame(height: DesignTokens.Spacing.xs)

            Text(subtitle)
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(Color.neutral600)

            Spacer()

            PrimaryButton(title: buttonTitle) {
                if navigateToHome {
                    router.popToRoot()
                    router.navigate(to: .home)
                } else {
                    router.popToRoot()
                    router.navigate(to: .signIn())
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.bottom, DesignTokens.Spacing.xxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }
}

#Preview {
    SuccessMessageView(message: "Password Updated!")
        .environmentObject(Router())
}
