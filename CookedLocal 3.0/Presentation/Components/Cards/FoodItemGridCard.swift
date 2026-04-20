//
//  FoodItemGridCard.swift
//  Cooked Local
//

import SwiftUI

struct FoodItemGridCard: View {
    let item: FoodItem
    var isInCart: Bool = false
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Group {
                if let urlString = item.imageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().aspectRatio(contentMode: .fill)
                                .transition(.opacity.animation(.easeIn(duration: 0.3)))
                        default:
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small)
                                .fill(Color.neutral100)
                                .overlay(Image(systemName: "photo").foregroundColor(.neutral600))
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small)
                                .fill(Color.neutral100)
                                .overlay(Image(systemName: "photo").foregroundColor(.neutral600))
                }
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small))

            Text(item.name)
                .font(.system(size: DesignTokens.FontSize.body, weight: .semibold))
                .foregroundColor(.neutral900)
                .lineLimit(2)

            HStack {
                Text("\(item.currency)\(String(format: "%.2f", item.price))")
                    .font(.anton(DesignTokens.FontSize.body))
                    .foregroundColor(.neutral900)

                Spacer()

                Button(action: onAdd) {
                    HStack(spacing: 4) {
                        if isInCart {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                            Text("Added")
                                .font(.anton(DesignTokens.FontSize.body))
                        } else {
                            Image("plusIcon")
                                .font(.system(size: 12, weight: .bold))
                            Text("Add")
                                .font(.anton(DesignTokens.FontSize.body))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .padding(.vertical, 6)
                    .background(isInCart ? Color.green : Color.brandOrange)
                    .cornerRadius(DesignTokens.CornerRadius.small)
                    .animation(.easeInOut(duration: 0.2), value: isInCart)
                }
            }
        }
        .padding(DesignTokens.Spacing.xs)
        .background(Color.white)
        .cornerRadius(DesignTokens.CornerRadius.medium)
    }
}

#Preview {
    FoodItemGridCard(
        item: FoodItem.samples[0],
        onAdd: {}
    )
    .frame(width: 170)
    .padding()
    .background(Color.backgroundColor)
}
