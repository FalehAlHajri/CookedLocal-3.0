//
//  OutlinedButton.swift
//  Cooked Local
//

import SwiftUI

struct OutlinedButton: View {
    let title: String
    let action: () -> Void
    var foregroundColor: Color = .neutral900
    var borderColor: Color = .neutral100

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.anton(DesignTokens.FontSize.body))
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.md)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                        .stroke(borderColor, lineWidth: 1)
                )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        OutlinedButton(title: "Join as a Chef", action: {})
        OutlinedButton(title: "Sign In", action: {})
    }
    .padding()
}
