//
//  ShimmerView.swift
//  Cooked Local
//

import SwiftUI

// MARK: - Shimmer Modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1.0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: Color.white.opacity(0.5), location: 0.4),
                            .init(color: Color.white.opacity(0.5), location: 0.6),
                            .init(color: .clear, location: 1.0)
                        ]),
                        startPoint: .init(x: phase, y: 0.5),
                        endPoint: .init(x: phase + 1.0, y: 0.5)
                    )
                    .blendMode(.screen)
                }
                .allowsHitTesting(false)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.4)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1.0
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Skeleton Card Views

struct FoodItemCardSkeleton: View {
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small)
                .fill(Color.neutral100)
                .frame(width: 80, height: 80)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4).fill(Color.neutral100).frame(width: 120, height: 14)
                RoundedRectangle(cornerRadius: 4).fill(Color.neutral100).frame(width: 80, height: 12)
                RoundedRectangle(cornerRadius: 4).fill(Color.neutral100).frame(width: 60, height: 12)
                HStack {
                    RoundedRectangle(cornerRadius: 4).fill(Color.neutral100).frame(width: 60, height: 14)
                    Spacer()
                    RoundedRectangle(cornerRadius: 8).fill(Color.neutral100).frame(width: 60, height: 28)
                }
            }
        }
        .padding(DesignTokens.Spacing.sm)
        .background(Color.white)
        .cornerRadius(DesignTokens.CornerRadius.medium)
        .shimmer()
    }
}

struct CategoryChipSkeleton: View {
    let width: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.pill)
            .fill(Color.neutral100)
            .frame(width: width, height: 36)
            .shimmer()
    }
}

struct ChefCardSkeleton: View {
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                .fill(Color.neutral100)
                .frame(height: 100)

            VStack(alignment: .leading, spacing: 8) {
                Circle().fill(Color.neutral100).frame(width: 50, height: 50)
                    .offset(y: -25)
                    .padding(.horizontal, DesignTokens.Spacing.sm)

                RoundedRectangle(cornerRadius: 4).fill(Color.neutral100).frame(width: 100, height: 12)
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .offset(y: -20)

                RoundedRectangle(cornerRadius: 4).fill(Color.neutral100).frame(height: 28)
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .padding(.bottom, DesignTokens.Spacing.sm)
                    .offset(y: -16)
            }
        }
        .background(Color.white)
        .cornerRadius(DesignTokens.CornerRadius.medium)
        .shimmer()
    }
}
