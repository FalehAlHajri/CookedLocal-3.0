//
//  AppTextField.swift
//  Cooked Local
//

import SwiftUI

struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder).foregroundColor(.neutral600)
        )
        .font(.system(size: DesignTokens.FontSize.body))
        .foregroundColor(.neutral900)
        .tint(.neutral900)
        .keyboardType(keyboardType)
        .textInputAutocapitalization(autocapitalization)
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
        AppTextField(placeholder: "Email or Phone Number", text: .constant(""))
        AppTextField(placeholder: "Name", text: .constant("John Doe"))
    }
    .padding()
}
