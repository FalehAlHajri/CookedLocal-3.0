//
//  AssistantView.swift
//  Cooked Local
//

import SwiftUI

struct AssistantView: View {
    @StateObject var viewModel: AssistantViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            messagesList

            if !viewModel.quickPrompts.isEmpty {
                quickPromptsSection
            }

            inputSection
        }
        .background(Color.backgroundColor)
    }

    private var headerSection: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.neutral900)
                    .frame(width: 32, height: 32)
                    .background(Color.neutral100.opacity(0.5))
                    .clipShape(Circle())
            }

            Text("Ask Cooked Local")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(Color.white)
    }

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(
                            message: message,
                            onActionTap: { action in
                                viewModel.handleSuggestedAction(action)
                                dismiss()
                            }
                        )
                    }
                    if viewModel.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                                .padding(.horizontal, DesignTokens.Spacing.md)
                                .padding(.vertical, DesignTokens.Spacing.sm)
                                .background(Color.neutral100)
                                .cornerRadius(DesignTokens.CornerRadius.pill)
                            Spacer()
                        }
                        .padding(.horizontal, DesignTokens.Spacing.md)
                        .id("loading")
                    }
                }
                .padding(.vertical, DesignTokens.Spacing.md)
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let last = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: viewModel.isLoading) { _ in
                if viewModel.isLoading {
                    withAnimation {
                        proxy.scrollTo("loading", anchor: .bottom)
                    }
                }
            }
        }
    }

    private var quickPromptsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                ForEach(viewModel.quickPrompts, id: \.self) { prompt in
                    Button(action: { viewModel.sendQuickPrompt(prompt) }) {
                        Text(prompt)
                            .font(.system(size: DesignTokens.FontSize.caption, weight: .medium))
                            .foregroundColor(.brandOrange)
                            .padding(.horizontal, DesignTokens.Spacing.sm)
                            .padding(.vertical, 6)
                            .background(Color.brandOrange.opacity(0.12))
                            .cornerRadius(DesignTokens.CornerRadius.pill)
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.xs)
        }
        .background(Color.white)
    }

    private var inputSection: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            TextField("Ask something...", text: $viewModel.inputText)
                .font(.system(size: DesignTokens.FontSize.body))
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(Color.neutral100.opacity(0.5))
                .cornerRadius(DesignTokens.CornerRadius.pill)

            Button(action: { viewModel.sendMessage(viewModel.inputText) }) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.brandOrange)
                    .clipShape(Circle())
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(Color.white)
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    let onActionTap: (AssistantSuggestedAction) -> Void

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: DesignTokens.Spacing.xs) {
                Text(message.text)
                    .font(.system(size: DesignTokens.FontSize.body))
                    .foregroundColor(message.role == .user ? .white : (message.isError ? .red : .neutral900))
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.vertical, DesignTokens.Spacing.sm)
                    .background(message.role == .user ? Color.brandOrange : Color.white)
                    .cornerRadius(DesignTokens.CornerRadius.medium)

                if !message.suggestedActions.isEmpty {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        ForEach(message.suggestedActions) { action in
                            Button(action: { onActionTap(action) }) {
                                Text(action.label)
                                    .font(.system(size: DesignTokens.FontSize.caption, weight: .medium))
                                    .foregroundColor(.brandOrange)
                                    .padding(.horizontal, DesignTokens.Spacing.sm)
                                    .padding(.vertical, 6)
                                    .background(Color.brandOrange.opacity(0.12))
                                    .cornerRadius(DesignTokens.CornerRadius.pill)
                            }
                        }
                    }
                    .padding(.top, 2)
                }
            }

            if message.role == .assistant {
                Spacer()
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .id(message.id)
    }
}
