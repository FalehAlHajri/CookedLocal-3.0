//
//  FoodDetailView.swift
//  Cooked Local
//

import SwiftUI

struct FoodDetailView: View {
    @StateObject var viewModel: FoodDetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    foodImageSection

                    foodInfoSection

                    detailsSection

                    sizeSection
                }
                .padding(.bottom, 100)
            }

            Spacer()

            bottomBar
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Button(action: { viewModel.goBack() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.neutral900)
                    .frame(width: 44, height: 44)
                    .background(Color.neutral100.opacity(0.5))
                    .clipShape(Circle())
            }

            Text(viewModel.foodItem.name)
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)
                .lineLimit(1)

            Spacer()

            if !viewModel.isFromChef {
                cartButton
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    private var cartButton: some View {
        Button(action: { viewModel.navigateToCart() }) {
            HStack(spacing: 8) {
                Image("shoppingBagIcon")
                    .frame(width: 24, height: 24)

                Text(String(format: "%02d", viewModel.cartItemCount))
                    .font(.anton(DesignTokens.FontSize.subheadline))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.brandOrange)
            )
        }
    }

    // MARK: - Food Image Section
    private var foodImageSection: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let urlString = viewModel.foodItem.imageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().aspectRatio(contentMode: .fill)
                                .transition(.opacity.animation(.easeIn(duration: 0.3)))
                        default:
                            Rectangle().fill(Color.neutral100).overlay(Image(systemName: "photo").font(.system(size: 32)).foregroundColor(.neutral600))
                        }
                    }
                } else {
                    Rectangle().fill(Color.neutral100).overlay(Image(systemName: "photo").font(.system(size: 32)).foregroundColor(.neutral600))
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium))

            if viewModel.isFromOrder {
                Text("Delivered")
                    .font(.system(size: DesignTokens.FontSize.caption, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .padding(.vertical, 6)
                    .background(Color.brandOrange)
                    .cornerRadius(DesignTokens.CornerRadius.small)
                    .padding(DesignTokens.Spacing.sm)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Food Info Section
    private var foodInfoSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            // Chef info
            HStack(spacing: DesignTokens.Spacing.xs) {
                Group {
                    if let urlString = viewModel.foodItem.shopProfileURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img): img.resizable().aspectRatio(contentMode: .fill)
                            default: Image(systemName: "person.circle.fill").resizable().foregroundColor(.neutral600)
                            }
                        }
                    } else {
                        Image(systemName: "person.circle.fill").resizable().foregroundColor(.neutral600)
                    }
                }
                .frame(width: 28, height: 28)
                .clipShape(Circle())

                Text(viewModel.foodItem.shopName)
                    .font(.system(size: DesignTokens.FontSize.body, weight: .medium))
                    .foregroundColor(.neutral900)
            }

            // Name + Price
            HStack {
                Text(viewModel.foodItem.name)
                    .font(.system(size: DesignTokens.FontSize.body, weight: .semibold))
                    .foregroundColor(.neutral900)
                    .lineLimit(1)

                Spacer()

                Text("\(viewModel.foodItem.currency)\(String(format: "%.2f", viewModel.foodItem.price))")
                    .font(.anton(DesignTokens.FontSize.subheadline))
                    .foregroundColor(.neutral900)
            }

            // Delivery + Rating
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                        .foregroundColor(.neutral600)

                    Text("\(viewModel.foodItem.deliveryTime) Delivery")
                        .font(.system(size: DesignTokens.FontSize.caption))
                        .foregroundColor(.neutral600)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.starColor)

                    Text("\(String(format: "%.1f", viewModel.foodItem.rating)) (\(viewModel.foodItem.reviewCount)+)")
                        .font(.system(size: DesignTokens.FontSize.caption))
                        .foregroundColor(.neutral600)
                }
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Details :")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Text(viewModel.foodItem.description)
                .font(.system(size: DesignTokens.FontSize.body))
                .foregroundColor(.neutral600)
                .lineSpacing(4)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Size Section
    private var sizeSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Size :")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            HStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(FoodSize.allCases, id: \.self) { size in
                    sizeChip(size)
                }
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    private func sizeChip(_ size: FoodSize) -> some View {
        Button(action: { viewModel.selectedSize = size }) {
            VStack(spacing: 4) {
                Text(size.rawValue)
                    .font(.system(size: DesignTokens.FontSize.caption, weight: .medium))

                Text("\(viewModel.foodItem.currency) \(String(format: "%.2f", sizePrice(for: size)))")
                    .font(.anton(DesignTokens.FontSize.caption))
            }
            .foregroundColor(viewModel.selectedSize == size ? .white : .neutral900)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(
                viewModel.selectedSize == size
                    ? Color.brandOrange
                    : Color.white
            )
            .cornerRadius(DesignTokens.CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small)
                    .stroke(
                        viewModel.selectedSize == size ? Color.clear : Color.neutral100,
                        lineWidth: 1
                    )
            )
        }
    }

    private func sizePrice(for size: FoodSize) -> Double {
        viewModel.price(for: size)
    }

    // MARK: - Bottom Bar
    @ViewBuilder
    private var bottomBar: some View {
        if viewModel.isFromChef {
            EmptyView()
        } else if viewModel.isFromOrder {
            orderBottomBar
        } else {
            cartBottomBar
        }
    }

    private var cartBottomBar: some View {
        HStack {
            // Quantity controls
            HStack(spacing: DesignTokens.Spacing.sm) {
                Button(action: { viewModel.decrementQuantity() }) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.neutral900)
                        .frame(width: 30, height: 30)
                        .background(Color.neutral100.opacity(0.5))
                        .clipShape(Circle())
                }

                Text(String(format: "%02d", viewModel.quantity))
                    .font(.anton(DesignTokens.FontSize.body))
                    .foregroundColor(.neutral900)

                Button(action: { viewModel.incrementQuantity() }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.neutral900)
                        .frame(width: 30, height: 30)
                        .background(Color.neutral100.opacity(0.5))
                        .clipShape(Circle())
                }
            }

            Spacer()

            // Add to Cart button
            Button(action: { viewModel.addToCart() }) {
                Text("Add to Cart")
                    .font(.anton(DesignTokens.FontSize.body))
                    .foregroundColor(.white)
                    .padding(.horizontal, DesignTokens.Spacing.xl)
                    .padding(.vertical, DesignTokens.Spacing.sm)
                    .background(Color.brandOrange)
                    .cornerRadius(DesignTokens.CornerRadius.pill)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(Color.white)
    }

    private var orderBottomBar: some View {
        Button(action: { viewModel.navigateToReview() }) {
            Text("Add Review")
                .font(.anton(DesignTokens.FontSize.body))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(Color.brandOrange)
                .cornerRadius(DesignTokens.CornerRadius.pill)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(Color.white)
    }
}

#Preview {
    FoodDetailView(
        viewModel: FoodDetailViewModel(
            foodItem: FoodItem.samples[0],
            router: Router(),
            cartManager: CartManager()
        )
    )
}
