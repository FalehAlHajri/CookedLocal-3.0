//
//  CartItemCard.swift
//  Cooked Local
//

import SwiftUI

struct CartItemCard: View {
    let cartItem: CartItem
    let onRemove: () -> Void
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Group {
                if let urlString = cartItem.foodItem.imageURL,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().aspectRatio(contentMode: .fill)
                        default:
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small)
                                .fill(Color.neutral100)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.neutral600)
                                )
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small)
                        .fill(Color.neutral100)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.neutral600)
                        )
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(cartItem.foodItem.name)
                        .font(.system(size: DesignTokens.FontSize.body, weight: .semibold))
                        .foregroundColor(.neutral900)
                        .lineLimit(1)

                    Spacer()

                    Button(action: onRemove) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12))
                            .foregroundColor(.neutral600)
                    }
                }

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                        .foregroundColor(.neutral600)

                    Text("\(cartItem.foodItem.deliveryTime) Delivery")
                        .font(.system(size: DesignTokens.FontSize.caption))
                        .foregroundColor(.neutral600)
                }

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.starColor)

                    Text("\(String(format: "%.1f", cartItem.foodItem.rating)) (\(cartItem.foodItem.reviewCount)+)")
                        .font(.system(size: DesignTokens.FontSize.caption))
                        .foregroundColor(.neutral600)
                }

                HStack {
                    Text("\(cartItem.foodItem.currency) \(String(format: "%.2f", cartItem.foodItem.price))")
                        .font(.anton(DesignTokens.FontSize.body))
                        .foregroundColor(.neutral900)

                    Spacer()

                    HStack(spacing: DesignTokens.Spacing.xs) {
                        Button(action: onDecrement) {
                            Image(systemName: "minus")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(Color.neutral900)
                                .clipShape(Circle())
                        }

                        Text(String(format: "%02d", cartItem.quantity))
                            .font(.anton(DesignTokens.FontSize.body))
                            .foregroundColor(.neutral900)

                        Button(action: onIncrement) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(Color.neutral900)
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
        .padding(DesignTokens.Spacing.sm)
        .background(Color.white)
        .cornerRadius(DesignTokens.CornerRadius.medium)
    }
}

#Preview {
    CartItemCard(
        cartItem: CartItem(foodItem: FoodItem.samples[0]),
        onRemove: {},
        onIncrement: {},
        onDecrement: {}
    )
    .padding()
    .background(Color.backgroundColor)
}
