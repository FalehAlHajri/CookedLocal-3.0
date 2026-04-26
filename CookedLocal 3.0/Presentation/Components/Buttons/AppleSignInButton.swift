//
//  AppleSignInButton.swift
//  Cooked Local
//

import SwiftUI
import AuthenticationServices

struct AppleSignInButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "apple.logo")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Text("Continue with Apple")
                    .font(.system(size: DesignTokens.FontSize.body, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background(Color.black)
            .cornerRadius(DesignTokens.CornerRadius.large)
        }
    }
}

#Preview {
    AppleSignInButton(action: {})
        .padding()
}
