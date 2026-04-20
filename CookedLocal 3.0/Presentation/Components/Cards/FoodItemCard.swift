//
//  FoodItemCard.swift
//  Cooked Local
//

import SwiftUI

struct FoodItemCard: View {
    let item: FoodItem
    var showAddButton: Bool = true
    var showMenuButton: Bool = false
    var showSelectionIndicator: Bool = false
    var isSelected: Bool = false
    var isInCart: Bool = false
    var onAdd: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil
    var onMenu: (() -> Void)? = nil

    @State private var isPressed: Bool = false

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            foodImage
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.system(size: DesignTokens.FontSize.body, weight: .semibold))
                        .foregroundColor(.neutral900)
                        .lineLimit(1)

                    if showMenuButton || showSelectionIndicator {
                        Spacer()
                    }

                    if showMenuButton {
                        Button(action: { onMenu?() }) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 14))
                                .foregroundColor(.neutral600)
                                .rotationEffect(.degrees(90))
                                .frame(width: 24, height: 24)
                        }
                    }

                    if showSelectionIndicator {
                        Circle()
                            .fill(isSelected ? Color.brandOrange : Color.clear)
                            .frame(width: 20, height: 20)
                            .overlay(Circle().stroke(isSelected ? Color.brandOrange : Color.neutral100, lineWidth: 2))
                            .animation(.easeInOut(duration: 0.2), value: isSelected)
                    }
                }

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                        .foregroundColor(.neutral600)
                    Text("\(item.deliveryTime) Delivery")
                        .font(.system(size: DesignTokens.FontSize.caption))
                        .foregroundColor(.neutral600)
                }

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.starColor)
                    Text("\(String(format: "%.1f", item.rating)) (\(item.reviewCount)+)")
                        .font(.system(size: DesignTokens.FontSize.caption))
                        .foregroundColor(.neutral600)
                }

                HStack {
                    Text("\(item.currency) \(String(format: "%.2f", item.price))")
                        .font(.anton(DesignTokens.FontSize.body))
                        .foregroundColor(.neutral900)

                    Spacer()

                    if showAddButton, let onAdd = onAdd {
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
            }
        }
        .padding(DesignTokens.Spacing.sm)
        .background(Color.white)
        .cornerRadius(DesignTokens.CornerRadius.medium)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            withAnimation { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation { isPressed = false }
            }
            onTap?()
        }
    }

    @ViewBuilder
    private var foodImage: some View {
        if let urlString = item.imageURL, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .transition(.opacity.animation(.easeIn(duration: 0.3)))
                case .failure:
                    localFallbackImage
                case .empty:
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small)
                        .fill(Color.neutral100)
                        .overlay(ProgressView().scaleEffect(0.7))
                @unknown default:
                    localFallbackImage
                }
            }
        } else {
            localFallbackImage
        }
    }

    private var localFallbackImage: some View {
        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small)
            .fill(Color.neutral100)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundColor(.neutral600)
            )
    }
}

#Preview {
    VStack {
        FoodItemCard(item: FoodItem.samples[0], onAdd: { })
        FoodItemCard(item: FoodItem.samples[0], showAddButton: false)
    }
    .padding()
    .background(Color.backgroundColor)
}
