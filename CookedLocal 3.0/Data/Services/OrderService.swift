//
//  OrderService.swift
//  Cooked Local
//

import Foundation

// MARK: - Domain types used by OrderService callers

struct MenuOrderItem {
    let menuId: String
    let size: String
    let totalQuantity: Int
}

struct PaymentInfo {
    let customerName: String
    let customerPhone: String
    let customerAddress: String
}

// MARK: - OrderService

final class OrderService {
    private let network = NetworkManager.shared

    // MARK: - Create Order

    func createOrder(
        totalPrice: Double,
        menuList: [MenuOrderItem],
        address: String,
        paymentMethod: String,
        note: String? = nil,
        paymentInfo: PaymentInfo? = nil,
        transactionId: String? = nil
    ) async throws -> [APIOrder] {
        let requestBody = CreateOrderRequest(
            total_price: totalPrice,
            menu_list: menuList.map {
                MenuOrderItemRequest(menu: $0.menuId, size: $0.size, total_quantity: $0.totalQuantity)
            },
            address: address,
            payment_method: paymentMethod,
            note: note,
            payment_info: paymentInfo.map {
                PaymentInfoRequest(
                    customer_name: $0.customerName,
                    customer_phone: $0.customerPhone,
                    customer_address: $0.customerAddress
                )
            },
            transaction_id: transactionId
        )
        return try await network.request(path: "order/create", method: "POST", body: requestBody)
    }

    // MARK: - Customer Orders

    func fetchMyOrders(status: String? = nil, page: Int = 1, limit: Int = 10) async throws -> [APIOrderItem] {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        if let status = status {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }
        return try await network.requestPaginated(
            path: "order/my-order-menus",
            queryItems: queryItems
        )
    }

    // MARK: - Chef Shop Orders

    func fetchShopOrders(status: String? = nil, page: Int = 1, limit: Int = 10) async throws -> [APIOrderItem] {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        if let status = status {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }
        return try await network.requestPaginated(
            path: "order/shop-order-menus",
            queryItems: queryItems
        )
    }

    // MARK: - Add Review (menuId goes in URL path, not body)

    func addReview(menuId: String, rating: Int, comment: String) async throws {
        let body = AddReviewRequest(rating: rating, comment: comment)
        try await network.requestVoid(path: "order/add/review/\(menuId)", method: "POST", body: body)
    }

    // MARK: - Update Delivery Status (chef only)

    func updateDeliveryStatus(orderIds: [String], status: String) async throws {
        let body = UpdateDeliveryStatusRequest(order_ids: orderIds, status: status)
        try await network.requestVoid(path: "order/update/delivery-status", method: "PATCH", body: body)
    }
}
