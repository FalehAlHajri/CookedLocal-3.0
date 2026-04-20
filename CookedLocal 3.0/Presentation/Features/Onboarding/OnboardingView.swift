//
//  OnboardingView.swift
//  Cooked Local
//

import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel: OnboardingViewModel
    @State private var showLogo = true
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0

    var body: some View {
        ZStack {
            // Logo intro screen
            if showLogo {
                logoIntroScreen
            } else {
                // Regular onboarding flow
                regularOnboarding
            }
        }
    }

    // MARK: - Logo Intro Screen
    private var logoIntroScreen: some View {
        ZStack {
            Color.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: DesignTokens.Spacing.lg) {
                Spacer()

                // App Logo from Assets
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                // Brand Name
                VStack(spacing: DesignTokens.Spacing.sm) {
                    Text("COOKED")
                        .font(.anton(48))
                        .foregroundColor(.neutral900)

                    Text("LOCAL")
                        .font(.anton(48))
                        .foregroundColor(.brandOrange)
                }
                .opacity(logoOpacity)

                Spacer()

                // Tagline
                Text("Local Food, Delivered Fresh")
                    .font(.system(size: DesignTokens.FontSize.body))
                    .foregroundColor(.neutral600)
                    .opacity(logoOpacity)
                    .padding(.bottom, DesignTokens.Spacing.xxl)
            }
        }
        .onAppear {
            // Animate logo in
            withAnimation(.easeOut(duration: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            // After 2 seconds, fade out and proceed
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeIn(duration: 0.5)) {
                    logoOpacity = 0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        showLogo = false
                    }
                }
            }
        }
    }

    // MARK: - Regular Onboarding
    private var regularOnboarding: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    Image("GirlEatingPizza")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height * DesignTokens.ImageHeight.onboardingScreenRatio)
                        .clipped()

                    CurvedShape()
                        .fill(Color.white)
                        .frame(height: geometry.size.height * DesignTokens.ImageHeight.onboardingScreenRatio * 0.355)
                }

                VStack(spacing: DesignTokens.Spacing.md) {
                    Spacer()

                    Text("Find your Delicious Food")
                        .font(.anton(DesignTokens.FontSize.subheadline))
                        .foregroundColor(Color.neutral600)

                    Text("Cooked Local")
                        .font(.anton(DesignTokens.FontSize.headline))
                        .foregroundColor(Color.neutral900)

                    Spacer()

                    PrimaryButton(title: "Get Started") {
                        viewModel.navigateToRoleSelection()
                    }
                    .padding(.horizontal, DesignTokens.Spacing.xl)
                    .padding(.bottom, DesignTokens.Spacing.xxl)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel(router: Router()))
}
