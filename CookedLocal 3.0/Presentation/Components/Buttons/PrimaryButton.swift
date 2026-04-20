//
//  PrimaryButton.swift
//  Cooked Local
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isEnabled: Bool = true
    var backgroundColor: Color = .brandOrange

    var body: some View {
        Button(action: {
            if !isLoading && isEnabled {
                action()
            }
        }) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.anton(DesignTokens.FontSize.body))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background(isEnabled ? backgroundColor : backgroundColor.opacity(0.5))
            .cornerRadius(DesignTokens.CornerRadius.large)
        }
        .disabled(!isEnabled || isLoading)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Sign Up", action: {})
        PrimaryButton(title: "Loading...", action: {}, isLoading: true)
        PrimaryButton(title: "Disabled", action: {}, isEnabled: false)
    }
    .padding()
}
