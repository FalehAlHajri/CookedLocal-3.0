//
//  SplashView.swift
//  Cooked Local
//

import SwiftUI

struct SplashView: View {
    @StateObject var viewModel: SplashViewModel
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var showLogo = true

    var body: some View {
        ZStack {
            if showLogo {
                // App Logo Splash Screen
                logoSplashScreen
            } else {
                // Navigate to next screen via ViewModel
                EmptyView()
            }
        }
        .onAppear {
            viewModel.startSplashTimer()
            animateLogo()
        }
    }

    private var logoSplashScreen: some View {
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

                // Tagline
                Text("Local food, Delivered Fresh.")
                    .font(.system(size: DesignTokens.FontSize.body))
                    .foregroundColor(.neutral600)
                    .opacity(logoOpacity)

                Spacer()
            }
        }
    }

    private func animateLogo() {
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
                showLogo = false
            }
        }
    }
}

#Preview {
    SplashView(viewModel: SplashViewModel(router: Router()))
}
