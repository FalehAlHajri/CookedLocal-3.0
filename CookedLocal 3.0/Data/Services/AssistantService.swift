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
        #if DEBUG
        print("[AssistantService] POST assistant/chat — role: \(role), message: \(message)")
        #endif
        let response: AssistantChatResponse = try await network.request(path: "assistant/chat", method: "POST", body: body)
        #if DEBUG
        print("[AssistantService] response reply: \(response.reply ?? "nil"), message: \(response.message ?? "nil")")
        #endif
        return response
    }
}
