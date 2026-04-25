//
//  AssistantViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

enum ChatMessageRole: String {
    case user
    case assistant
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: ChatMessageRole
    let text: String
    let suggestedActions: [AssistantSuggestedAction]
    let isError: Bool
    let timestamp = Date()
}

final class AssistantViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published private(set) var isLoading: Bool = false

    private let assistantService: AssistantService
    private let userRole: String
    private let currentScreen: String
    private let context: AssistantContext
    private let router: Router

    init(
        assistantService: AssistantService,
        router: Router,
        userRole: String,
        currentScreen: String,
        context: AssistantContext
    ) {
        self.assistantService = assistantService
        self.router = router
        self.userRole = userRole
        self.currentScreen = currentScreen
        self.context = context
        addWelcomeMessage()
    }

    var quickPrompts: [String] {
        userRole == "provider" ? chefPrompts : customerPrompts
    }

    private let customerPrompts = [
        "What should I eat today?",
        "Suggest something spicy",
        "Show me meals under £10",
        "Recommend popular dishes",
        "Help me track my order",
        "How do refunds work?",
        "Help me reorder"
    ]

    private let chefPrompts = [
        "How do I add a dish?",
        "Improve my dish description",
        "Suggest a dish title",
        "How should I price this dish?",
        "How do I upload my qualification PDF?",
        "How do I update availability?",
        "How do payouts work?"
    ]

    @MainActor
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        messages.append(ChatMessage(role: .user, text: trimmed, suggestedActions: [], isError: false))
        inputText = ""
        fetchReply(for: trimmed)
    }

    @MainActor
    func sendQuickPrompt(_ prompt: String) {
        messages.append(ChatMessage(role: .user, text: prompt, suggestedActions: [], isError: false))
        fetchReply(for: prompt)
    }

    @MainActor
    func handleSuggestedAction(_ action: AssistantSuggestedAction) {
        switch action.route {
        case "home":
            router.replace(with: .home)
        case "chefHome":
            router.replace(with: .chefHome)
        case "orders":
            router.replace(with: .home)
        case "cart":
            router.navigate(to: .cart)
        case "profile":
            router.replace(with: .home)
        case "manageShop":
            router.navigate(to: .manageShop)
        case "manageProfile":
            router.navigate(to: .manageProfile)
        case "addDish":
            router.navigate(to: .addDish)
        case "search":
            router.navigate(to: .search)
        default:
            break
        }
    }

    @MainActor
    private func fetchReply(for text: String) {
        isLoading = true
        Task {
            do {
                let response = try await assistantService.sendMessage(
                    message: text,
                    role: userRole,
                    context: context
                )
                let actions = response.suggestedActions ?? []
                messages.append(ChatMessage(
                    role: .assistant,
                    text: response.displayText,
                    suggestedActions: actions,
                    isError: false
                ))
            } catch {
                #if DEBUG
                print("[Assistant] fetchReply error: \(error)")
                #endif
                messages.append(ChatMessage(
                    role: .assistant,
                    text: "Sorry, I couldn't answer that right now. Please try again.",
                    suggestedActions: [],
                    isError: true
                ))
            }
            isLoading = false
        }
    }

    private func addWelcomeMessage() {
        let welcomeText = userRole == "provider"
            ? "Hi! I'm your Cooked Local assistant. I can help you manage your shop, dishes, and orders. What would you like to do?"
            : "Hi! I'm your Cooked Local assistant. I can help you find food, track orders, and answer questions. What are you looking for?"
        messages.append(ChatMessage(role: .assistant, text: welcomeText, suggestedActions: [], isError: false))
    }
}
