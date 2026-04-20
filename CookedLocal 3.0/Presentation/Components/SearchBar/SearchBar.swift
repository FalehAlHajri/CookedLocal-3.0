//
//  SearchBar.swift
//  Cooked Local
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search Your Food/Chef"

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.neutral600))
                .font(.system(size: DesignTokens.FontSize.body))
                .foregroundColor(.neutral900)
                .tint(.neutral900)

            Image(systemName: "magnifyingglass")
                .foregroundColor(.brandOrange)
                .font(.system(size: 18, weight: .medium))
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(Color.white)
        .cornerRadius(DesignTokens.CornerRadius.medium)
    }
}

#Preview {
    ZStack {
        Color.brandOrange
        SearchBar(text: .constant(""))
            .padding()
    }
}
