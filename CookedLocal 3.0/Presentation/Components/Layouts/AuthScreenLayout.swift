//
//  AuthScreenLayout.swift
//  Cooked Local
//

import SwiftUI

struct AuthScreenLayout<Content: View>: View {
    @EnvironmentObject private var router: Router
    let imageName: String
    let showBackButton: Bool
    let content: Content

    init(imageName: String, showBackButton: Bool = false, @ViewBuilder content: () -> Content) {
        self.imageName = imageName
        self.showBackButton = showBackButton
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ZStack(alignment: .bottom) {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height * DesignTokens.ImageHeight.authScreenRatio)
                                .clipped()

                            SelectRoleCurvedShape()
                                .fill(Color.backgroundColor)
                                .frame(height: geometry.size.height * DesignTokens.ImageHeight.authScreenRatio * DesignTokens.ImageHeight.curveRatio)
                        }

                        VStack(spacing: DesignTokens.Spacing.md) {
                            content
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.backgroundColor)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .background(Color.backgroundColor)
            }

            if showBackButton {
                Button(action: { router.pop() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .padding(.leading, DesignTokens.Spacing.md)
                .padding(.top, 56)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }
}

#Preview {
    AuthScreenLayout(imageName: "CakeImage") {
        Spacer()
        Text("SIGN UP")
            .font(.anton(DesignTokens.FontSize.headline))
            .foregroundColor(Color.neutral900)
        Spacer()
        AppTextField(placeholder: "Email", text: .constant(""))
            .padding(.horizontal, DesignTokens.Spacing.lg)
        PrimaryButton(title: "Continue", action: {})
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.bottom, DesignTokens.Spacing.xxl)
    }
}
