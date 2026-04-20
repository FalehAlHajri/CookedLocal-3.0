//
//  MenuService.swift
//  Cooked Local
//

import Foundation

final class MenuService {
    private let network = NetworkManager.shared

    // MARK: - Fetch Menus (paginated, with optional filters)

    func fetchMenus(
        page: Int = 1,
        limit: Int = 20,
        category: String? = nil,
        title: String? = nil,
        shopId: String? = nil
    ) async throws -> [APIMenuItem] {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        if let category = category, !category.isEmpty {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        if let title = title, !title.isEmpty {
            queryItems.append(URLQueryItem(name: "title", value: title))
        }
        if let shopId = shopId, !shopId.isEmpty {
            queryItems.append(URLQueryItem(name: "shop", value: shopId))
        }
        return try await network.requestPaginated(path: "menu/all", queryItems: queryItems)
    }

    // MARK: - Fetch Search Suggestions

    func fetchSuggestions(query: String) async throws -> [APIMenuSuggestion] {
        let queryItems = [URLQueryItem(name: "q", value: query)]
        return try await network.requestPaginated(path: "menu/suggestions", queryItems: queryItems)
    }

    // MARK: - Fetch Single Menu

    func fetchMenuDetail(id: String) async throws -> APIMenuItemDetail {
        try await network.request(path: "menu/find/\(id)")
    }

    // MARK: - Create Menu (multipart)

    func createMenu(
        title: String,
        description: String,
        categoryId: String,
        sizePrices: [MenuSizePriceInput],
        deliveryTime: String,
        image: Data?
    ) async throws {
        // Build menu_size_prices JSON
        let sizePricesArray = sizePrices.map { sp -> [String: Any] in
            return [
                "size": sp.size.lowercased(),
                "price": sp.price,
                "available_quantity": sp.totalQuantity
            ]
        }
        let sizePricesData = try JSONSerialization.data(withJSONObject: sizePricesArray)
        let sizePricesString = String(data: sizePricesData, encoding: .utf8) ?? "[]"

        let fields: [String: String] = [
            "title": title,
            "description": description,
            "category": categoryId,
            "delivery_time": deliveryTime,
            "menu_size_prices": sizePricesString
        ]
        try await network.requestMultipartVoid(
            path: "menu/create",
            method: "POST",
            fields: fields,
            fileData: image
        )
    }

    // MARK: - Update Menu (multipart)

    func updateMenu(
        id: String,
        title: String? = nil,
        description: String? = nil,
        categoryId: String? = nil,
        normalPrice: Double? = nil,
        deliveryTime: String? = nil,
        image: Data? = nil
    ) async throws {
        var fields: [String: String] = [:]
        if let title = title { fields["title"] = title }
        if let description = description { fields["description"] = description }
        if let categoryId = categoryId { fields["category"] = categoryId }
        if let normalPrice = normalPrice { fields["normal_price"] = String(normalPrice) }
        if let deliveryTime = deliveryTime { fields["delivery_time"] = deliveryTime }

        try await network.requestMultipartVoid(
            path: "menu/update/\(id)",
            method: "PATCH",
            fields: fields,
            fileData: image
        )
    }

    // MARK: - Delete Menu

    func deleteMenu(id: String) async throws {
        try await network.requestVoid(path: "menu/delete/\(id)", method: "DELETE")
    }
}

// MARK: - Input Models

struct MenuSizePriceInput {
    let size: String
    let price: Double
    let totalQuantity: Int
}
