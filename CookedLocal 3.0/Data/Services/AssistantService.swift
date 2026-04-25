//
//  AssistantService.swift
//  Cooked Local
//

import Foundation

final class AssistantService {
    private let network = NetworkManager.shared

    func sendMessage(
        message: String,
        role: String,
        context: AssistantContext
    ) async throws -> AssistantChatResponse {
        let body = AssistantChatRequest(message: message, role: role, context: context)
        return try await network.request(path: "assistant/chat", method: "POST", body: body)
    }
}
