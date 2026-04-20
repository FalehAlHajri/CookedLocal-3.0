//
//  DynamicLaunchScreenView.swift
//  Cooked Local
//

import SwiftUI
import Combine

/// Dynamic launch screen that loads images from backend
struct DynamicLaunchScreenView: View {
    @StateObject private var viewModel = LaunchScreenViewModel()

    var body: some View {
        ZStack {
            // Background color
            Color.backgroundColor
                .ignoresSafeArea()

            // Dynamic background image from backend
            if let imageUrl = viewModel.launchImageUrl {
                CachedAsyncImage(
                    urlString: imageUrl,
                    contentMode: .fill
                ) {
                    Color.clear
                }
                .ignoresSafeArea()
                .overlay(
                    // Gradient overlay for text readability
                    LinearGradient(
                        colors: [.black.opacity(0.3), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            // Content overlay
            VStack(spacing: DesignTokens.Spacing.lg) {
                Spacer()

                // Logo/Brand
                if viewModel.showLogo {
                    VStack(spacing: DesignTokens.Spacing.md) {
                        Text("COOKED")
                            .font(.anton(DesignTokens.FontSize.display))
                            .foregroundColor(.white)

                        Text("LOCAL")
                            .font(.anton(DesignTokens.FontSize.display))
                            .foregroundColor(.white)
                    }
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 4)
                    .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                // Loading indicator
                if viewModel.isLoading {
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)

                        Text("Loading...")
                            .font(.system(size: DesignTokens.FontSize.caption))
                            .foregroundColor(.white)
                    }
                }

                // Tagline from backend
                if let tagline = viewModel.tagline {
                    Text(tagline)
                        .font(.system(size: DesignTokens.FontSize.body))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignTokens.Spacing.lg)
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                }

                Spacer()
                    .frame(height: 50)
            }
        }
        .onAppear {
            viewModel.loadLaunchScreenData()
        }
    }
}

// MARK: - ViewModel

@MainActor
final class LaunchScreenViewModel: ObservableObject {
    @Published var launchImageUrl: String?
    @Published var tagline: String?
    @Published var isLoading = true
    @Published var showLogo = false

    private let commonService = CommonService()

    func loadLaunchScreenData() {
        // Animate logo appearance
        withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
            showLogo = true
        }

        // Fetch launch screen configuration from backend
        Task {
            do {
                let config = try await commonService.getLaunchScreenConfig()
                launchImageUrl = config.imageUrl
                tagline = config.tagline
            } catch {
                // Use defaults if fetch fails
                tagline = "Local Food, Delivered Fresh"
            }
            isLoading = false
        }
    }
}

// MARK: - API Response Types

struct LaunchScreenConfig: Codable {
    let imageUrl: String?
    let tagline: String?
    let themeColor: String?
    let duration: Int? // seconds to show splash

    enum CodingKeys: String, CodingKey {
        case imageUrl = "image_url"
        case tagline
        case themeColor = "theme_color"
        case duration
    }
}
