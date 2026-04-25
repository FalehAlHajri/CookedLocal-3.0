//
//  AssistantButton.swift
//  Cooked Local
//

import SwiftUI

struct AssistantFloatingButton: View {
    let userRole: String
    let currentScreen: String
    let context: AssistantContext
    let router: Router
    let assistantService: AssistantService

    @State private var showAssistant = false

    var body: some View {
        Button(action: { showAssistant = true }) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                Image(systemName: "message.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)

                Text("Ask")
                    .font(.system(size: DesignTokens.FontSize.caption, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, 10)
            .background(Color.brandOrange)
            .cornerRadius(DesignTokens.CornerRadius.pill)
            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
        }
        .padding(.trailing, DesignTokens.Spacing.md)
        .padding(.bottom, DesignTokens.Spacing.lg)
        .sheet(isPresented: $showAssistant) {
            AssistantView(
                viewModel: AssistantViewModel(
                    assistantService: assistantService,
                    router: router,
                    userRole: userRole,
                    currentScreen: currentScreen,
                    context: context
                )
            )
        }
    }
}
