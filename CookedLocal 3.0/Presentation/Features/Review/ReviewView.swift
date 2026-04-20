//
//  ReviewView.swift
//  Cooked Local
//

import SwiftUI

struct ReviewView: View {
    @StateObject var viewModel: ReviewViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            VStack(spacing: DesignTokens.Spacing.lg) {
                starRatingSection

                reviewInputSection

                sendButton

                Spacer()
            }
            .padding(.top, DesignTokens.Spacing.lg)
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

            Text("Review")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    // MARK: - Star Rating
    private var starRatingSection: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            ForEach(1...5, id: \.self) { star in
                Button(action: { viewModel.rating = star }) {
                    Image(systemName: star <= viewModel.rating ? "star.fill" : "star")
                        .font(.system(size: 28))
                        .foregroundColor(star <= viewModel.rating ? .starColor : .neutral100)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Review Input
    private var reviewInputSection: some View {
        ZStack(alignment: .topLeading) {
            if viewModel.reviewText.isEmpty {
                Text("Write your review")
                    .font(.system(size: DesignTokens.FontSize.body))
                    .foregroundColor(.neutral600)
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.vertical, DesignTokens.Spacing.md)
            }

            TextEditor(text: $viewModel.reviewText)
                .font(.system(size: DesignTokens.FontSize.body))
                .foregroundColor(.neutral900)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.sm)
        }
        .frame(height: 140)
        .background(Color.white)
        .cornerRadius(DesignTokens.CornerRadius.medium)
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Send Button
    private var sendButton: some View {
        Button(action: { viewModel.sendReview() }) {
            Text("Send Review")
                .font(.anton(DesignTokens.FontSize.body))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(Color.brandOrange)
                .cornerRadius(DesignTokens.CornerRadius.pill)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }
}

#Preview {
    ReviewView(
        viewModel: ReviewViewModel(
            foodItem: FoodItem.samples[0],
            router: Router()
        )
    )
}
