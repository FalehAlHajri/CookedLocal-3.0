//
//  OTPTextField.swift
//  Cooked Local
//

import SwiftUI

struct OTPTextField: View {
    @Binding var text: String
    var isFocused: Bool

    var body: some View {
        TextField("", text: $text)
            .font(.anton(DesignTokens.FontSize.headline))
            .foregroundColor(Color.neutral900)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .frame(width: 43, height: 56)
            .background(Color.white)
            .cornerRadius(DesignTokens.CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small)
                    .stroke(text.isEmpty ? Color.neutral100 : Color.brandOrange, lineWidth: 1)
            )
            .onChange(of: text) { newValue in
                if newValue.count > 1 {
                    text = String(newValue.prefix(1))
                }
            }
    }
}

#Preview {
    HStack(spacing: 12) {
        OTPTextField(text: .constant("1"), isFocused: false)
        OTPTextField(text: .constant(""), isFocused: true)
        OTPTextField(text: .constant(""), isFocused: false)
    }
    .padding()
    .background(Color.backgroundColor)
}
