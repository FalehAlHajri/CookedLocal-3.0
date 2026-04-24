//
//  ShopDetailView.swift
//  Cooked Local
//

import SwiftUI

struct ShopDetailView: View {
    @StateObject var viewModel: ShopDetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    bannerAndProfileSection

                    chefInfoSection

                    bioSection

                    qualificationSection

                    Divider()
                        .padding(.horizontal, DesignTokens.Spacing.md)

                    infoCardsSection

                    popularFoodSection

                    categoriesSection

                    foodItemsSection

                    seeMoreButton
                }
                .padding(.bottom, DesignTokens.Spacing.lg)
            }
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

            Text("View Shop")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Spacer()

            cartButton
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

    // MARK: - Banner & Profile Section
    private var bannerAndProfileSection: some View {
        ZStack(alignment: .bottom) {
            // Banner image
            Group {
                if let urlString = viewModel.chef.bannerURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().aspectRatio(contentMode: .fill)
                                .transition(.opacity.animation(.easeIn(duration: 0.3)))
                        default:
                            Rectangle().fill(Color.neutral100)
                        }
                    }
                } else {
                    Rectangle().fill(Color.neutral100)
                }
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .clipped()

            // Profile image
            Group {
                if let urlString = viewModel.chef.imageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().aspectRatio(contentMode: .fill)
                                .transition(.opacity.animation(.easeIn(duration: 0.3)))
                        default:
                            Image(systemName: "person.circle.fill").resizable().foregroundColor(.neutral600)
                        }
                    }
                } else {
                    Image(systemName: "person.circle.fill").resizable().foregroundColor(.neutral600)
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 3))
            .offset(y: 40)
        }
        .padding(.bottom, 40)
    }

    // MARK: - Chef Info Section
    private var chefInfoSection: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            Text(viewModel.chef.name)
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.starColor)

                Text("\(String(format: "%.1f", viewModel.chef.rating)) (\(viewModel.chef.reviewCount)+)")
                    .font(.system(size: DesignTokens.FontSize.caption))
                    .foregroundColor(.neutral600)
            }

            HStack(spacing: DesignTokens.Spacing.xs) {
                if viewModel.chef.hasFacebook {
                    socialIcon("facebook")
                }
                if viewModel.chef.hasInstagram {
                    socialIcon("instagram")
                }
                if viewModel.chef.hasWhatsApp {
                    socialIcon("whatsapp")
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Bio Section
    private var bioSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text("Bio :")
                .font(.anton(DesignTokens.FontSize.body))
                .foregroundColor(.neutral900)

            Text(viewModel.bio)
                .font(.system(size: DesignTokens.FontSize.body))
                .foregroundColor(.neutral600)
                .lineSpacing(4)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Qualification Section
    @ViewBuilder
    private var qualificationSection: some View {
        if let qualURL = viewModel.chef.qualification, !qualURL.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text("Chef Qualification")
                    .font(.anton(DesignTokens.FontSize.body))
                    .foregroundColor(.neutral900)

                if let url = URL(string: qualURL) {
                    Link(destination: url) {
                        Text("View Qualification")
                            .font(.system(size: DesignTokens.FontSize.body))
                            .foregroundColor(.brandOrange)
                            .underline()
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
        }
    }

    // MARK: - Info Cards Section
    private var infoCardsSection: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            InfoCard(
                icon: "locationIcon",
                text: viewModel.location
            )
            .frame(height: 120)

            InfoCard(
                icon: "clockIcon",
                text: viewModel.deliveryTime
            )
            .frame(height: 120)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Popular Food Section
    private var popularFoodSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Text("Most Popular Food")
                    .font(.anton(DesignTokens.FontSize.subheadline))
                    .foregroundColor(.neutral900)

                Spacer()

                if viewModel.allFoodItems.count > 2 {
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Text("See more")
                                .font(.system(size: DesignTokens.FontSize.caption))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.neutral600)
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: DesignTokens.Spacing.sm),
                    GridItem(.flexible(), spacing: DesignTokens.Spacing.sm)
                ],
                spacing: DesignTokens.Spacing.sm
            ) {
                ForEach(viewModel.popularFoodItems) { item in
                    FoodItemGridCard(
                        item: item,
                        isInCart: viewModel.isInCart(item),
                        onAdd: { viewModel.addFoodItem(item) }
                    )
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
        }
    }

    // MARK: - Categories Section
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Categories")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)
                .padding(.horizontal, DesignTokens.Spacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignTokens.Spacing.xs) {
                    ForEach(viewModel.categories) { category in
                        CategoryChip(
                            category: category,
                            isSelected: viewModel.selectedCategory?.id == category.id,
                            action: { viewModel.selectCategory(category) }
                        )
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
            }
        }
    }

    // MARK: - Food Items Section
    private var foodItemsSection: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            ForEach(viewModel.foodItems) { item in
                FoodItemCard(
                    item: item,
                    isInCart: viewModel.isInCart(item),
                    onAdd: { viewModel.addFoodItem(item) },
                    onTap: { viewModel.navigateToFoodDetail(item) }
                )
                .padding(.horizontal, DesignTokens.Spacing.md)
            }
        }
    }

    // MARK: - See More Button
    @ViewBuilder
    private var seeMoreButton: some View {
        if viewModel.hasMore {
            Button(action: { viewModel.loadMore() }) {
                HStack(spacing: 4) {
                    Text("See more")
                        .font(.system(size: DesignTokens.FontSize.body))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                }
                .foregroundColor(.neutral600)
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Helpers
    private func socialIcon(_ name: String) -> some View {
        Circle()
            .frame(width: 24, height: 24)
            .overlay(
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
            )
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let icon: String
    let text: String

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            Image(icon)
                .font(.system(size: 24))
                .foregroundColor(.neutral600)

            Text(text)
                .font(.system(size: DesignTokens.FontSize.caption))
                .foregroundColor(.neutral600)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DesignTokens.Spacing.md)
        .background(Color.white)
        .cornerRadius(DesignTokens.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                .stroke(Color.neutral100, lineWidth: 1)
        )
    }
}
