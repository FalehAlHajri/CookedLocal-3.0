//
//  CategoryChip.swift
//  Cooked Local
//

import SwiftUI

struct CategoryChip: View {
    let category: FoodCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                Text(category.icon)
                    .font(.system(size: DesignTokens.FontSize.body))

                Text(category.name)
                    .font(.system(size: DesignTokens.FontSize.body, weight: .medium))
                    .foregroundColor(isSelected ? .white : .neutral900)
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(isSelected ? Color.brandOrange : Color.white)
            .cornerRadius(DesignTokens.CornerRadius.pill)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.pill)
                    .stroke(isSelected ? Color.clear : Color.neutral100, lineWidth: 1)
            )
        }
    }
}

#Preview {
    HStack {
        CategoryChip(
            category: FoodCategory(name: "Pizza", icon: "🍕"),
            isSelected: false,
            action: {}
        )
        CategoryChip(
            category: FoodCategory(name: "Cake", icon: "🍰"),
            isSelected: true,
            action: {}
        )
    }
    .padding()
    .background(Color.backgroundColor)
}
