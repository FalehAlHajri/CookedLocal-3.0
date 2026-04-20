//
//  PasswordTextField.swift
//  Cooked Local
//

import SwiftUI

struct PasswordTextField: View {
    let placeholder: String
    @Binding var text: String
    @State private var isVisible: Bool = false

    var body: some View {
        HStack {
            if isVisible {
                TextField(
                    "",
                    text: $text,
                    prompt: Text(placeholder).foregroundColor(.neutral600)
                )
                .font(.system(size: DesignTokens.FontSize.body))
                .foregroundColor(.neutral900)
                .tint(.neutral900)
            } else {
                SecureField(
                    "",
                    text: $text,
                    prompt: Text(placeholder).foregroundColor(.neutral600)
                )
                .font(.system(size: DesignTokens.FontSize.body))
                .foregroundColor(.neutral900)
                .tint(.neutral900)
            }

            Button(action: {
                isVisible.toggle()
            }) {
                Image(systemName: isVisible ? "eye" : "eye.slash")
                    .foregroundColor(Color.neutral600)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(Color.white)
        .cornerRadius(DesignTokens.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                .stroke(Color.neutral100, lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        PasswordTextField(placeholder: "Password", text: .constant(""))
        PasswordTextField(placeholder: "Confirm Password", text: .constant("secret123"))
    }
    .padding()
}
