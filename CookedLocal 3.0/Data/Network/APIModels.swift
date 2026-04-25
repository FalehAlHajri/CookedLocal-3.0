//
//  APIModels.swift
//  Cooked Local
//

import Foundation

// MARK: - Auth Request Models

struct RegisterCustomerRequest: Encodable {
    let name: String
    let email: String
    let password: String
    let role: String
}

struct RegisterChefRequest: Encodable {
    let shop_name: String
    let email: String
    let password: String
    let role: String
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct OTPVerifyRequest: Encodable {
    let otp: String
}

struct ResendOTPRequest: Encodable {
    let email: String
}

struct ForgotPasswordRequest: Encodable {
    let email: String
}

struct ForgotOTPVerifyRequest: Encodable {
    let otp: String
}

struct ResetPasswordRequest: Encodable {
    let newPassword: String
    let confirmPassword: String
}

struct ChangePasswordRequest: Encodable {
    let oldPassword: String
    let newPassword: String
    let confirmPassword: String
}

// MARK: - Auth Response Models

struct APIAuthUser: Decodable {
    let id: String?
    let name: String?
    let email: String
    let role: String
    let status: String?
    let shop: APIShopDetails?
}

struct APIAuthResponse: Decodable {
    let results: APIAuthUser
    let token: String
}

struct APIForgotPasswordResponse: Decodable {
    let token: String
}

// Backward-compatible alias
typealias APILoginData = APIAuthResponse

// MARK: - Category Model

struct APICategory: Decodable, Identifiable {
    let id: String
    let name: String
    let thumbnail: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case thumbnail
    }
}

// MARK: - Menu / Food Item Models

struct APIMenuShopInfo: Decodable {
    let id: String
    let email: String?
    let shop: APIShopDetails?
    let profile_url: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
        case shop
        case profile_url
    }
}

struct APIShopDetails: Decodable {
    let shop_name: String?
    let shop_banner: String?
    let bio: String?
    let shop_description: String?
    let qualification: String?
    let location: String?
    let phone_number: String?
    let facebook_url: String?
    let instagram_url: String?
    let whatsapp_number: String?
}

struct APIMenuSizePrice: Decodable, Hashable {
    let id: String
    let size: String
    let price: Double
    let availableQuantity: Int
    let totalQuantity: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case size
        case price
        case availableQuantity = "available_quantity"
        case totalQuantity = "total_quantity"
    }
}

struct APIMenuSuggestion: Decodable, Identifiable {
    let id: String
    let title: String
    let shop_name: String?

    func toSearchSuggestion() -> SearchSuggestion {
        SearchSuggestion(id: id, text: title, shopName: shop_name)
    }
}

struct APIMenuItem: Decodable, Identifiable {
    let id: String
    let shop: APIMenuShopInfo?
    let thumbnail: String?
    let category: APICategory?
    let normalPrice: Double?
    let title: String
    let description: String?
    let avgRating: Double?
    let totalReviews: Int?
    let isAvailable: Bool?
    let deliveryTime: String?
    let menuSizePrices: [APIMenuSizePrice]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case shop
        case thumbnail
        case category
        case normalPrice = "normal_price"
        case title
        case description
        case avgRating = "avg_rating"
        case totalReviews = "total_reviews"
        case isAvailable = "is_available"
        case deliveryTime = "delivery_time"
        case menuSizePrices = "menu_size_prices"
    }
}

// Alias for detail - same structure
typealias APIMenuItemDetail = APIMenuItem

// MARK: - Provider / Chef Models

struct APIProviderShop: Decodable {
    let shop_name: String?
    let shop_banner: String?
    let bio: String?
    let location: String?
    let qualification: String?
}

struct APISocialInfo: Decodable {
    let facebook_url: String?
    let instagram_url: String?
    let whatsapp_number: String?
}

struct APIProvider: Decodable, Identifiable {
    let id: String
    let email: String?
    let role: String?
    let shop: APIProviderShop?
    let profile_url: String?
    let social_info: APISocialInfo?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
        case role
        case shop
        case profile_url
        case social_info
    }
}

// MARK: - User Profile Models

struct APIUserProfile: Decodable {
    let id: String
    let name: String?
    let email: String?
    let role: String?
    let profile_url: String?
    let phone_number: String?
    let shop: APIShopDetails?
    let social_info: APISocialInfo?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case role
        case profile_url
        case phone_number
        case shop
        case social_info
    }
}

// MARK: - Order Models

struct APIOrderMenuInfo: Decodable {
    let id: String
    let title: String?
    let thumbnail: String?
    let normalPrice: Double?
    let avgRating: Double?
    let totalReviews: Int?
    let deliveryTime: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case thumbnail
        case normalPrice = "normal_price"
        case avgRating = "avg_rating"
        case totalReviews = "total_reviews"
        case deliveryTime = "delivery_time"
    }
}

struct APIOrderItem: Decodable, Identifiable {
    let id: String
    let menu: APIOrderMenuInfo?
    let size: String?
    let totalQuantity: Int?
    let orderedAt: String?
    let deliveryStatus: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case menu
        case size
        case totalQuantity = "total_quantity"
        case orderedAt = "ordered_at"
        case deliveryStatus = "delivery_status"
    }
}

struct APIOrder: Decodable, Identifiable {
    let id: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
    }
}

// Order creation request
struct MenuOrderItemRequest: Encodable {
    let menu: String
    let size: String
    let total_quantity: Int
}

struct PaymentInfoRequest: Encodable {
    let customer_name: String
    let customer_phone: String
    let customer_address: String
}

struct CreateOrderRequest: Encodable {
    let total_price: Double
    let menu_list: [MenuOrderItemRequest]
    let address: String
    let payment_method: String
    let note: String?
    let payment_info: PaymentInfoRequest?
    let transaction_id: String?
}

struct AddReviewRequest: Encodable {
    let rating: Int
    let comment: String
}

struct UpdateDeliveryStatusRequest: Encodable {
    let order_ids: [String]
    let status: String
}

// MARK: - Checkout Session Models

struct CreateCheckoutSessionRequest: Encodable {
    let menu_list: [MenuOrderItemRequest]
    let address: String
    let note: String?
    let success_url: String
    let cancel_url: String
}

struct APICheckoutSession: Decodable {
    let id: String
    let url: String
    let orderIds: [String]?
    let amount: Double?
}

struct APICheckoutSessionStatus: Decodable {
    let status: String?
    let payment_status: String?
    let orderIds: [String]?
    let amount: Double?
}

// MARK: - Notification Models

struct APINotificationSender: Decodable {
    let id: String
    let name: String?
    let profileUrl: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case profileUrl = "profile_url"
    }
}

struct APINotification: Decodable, Identifiable {
    let id: String
    let title: String?
    let description: String?
    let isRead: Bool?
    let createdAt: String?
    let published: String?
    let sender: APINotificationSender?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case isRead = "is_read"
        case createdAt = "created_at"
        case published
        case sender
    }
}

// MARK: - Info Page Models (About, Terms, Privacy)

struct APIInfoPage: Decodable, Identifiable {
    let id: String
    let content: String?
    let description: String?
    let published: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case content
        case description
        case published
    }
}

// MARK: - Dashboard Models

struct APIProviderDashboard: Decodable {
    let pendingOrders: Int?
    let deliveredOrders: Int?
    let cancelledOrders: Int?
    let totalMenu: Int?
    let totalEarning: Double?

    enum CodingKeys: String, CodingKey {
        case pendingOrders = "pending_orders"
        case deliveredOrders = "delivered_orders"
        case cancelledOrders = "cancelled_orders"
        case totalMenu = "total_menu"
        case totalEarning = "total_earning"
    }
}

// MARK: - Assistant Models

struct AssistantContext: Encodable {
    let userId: String?
    let currentScreen: String
    let cartItems: [AssistantCartItem]?
    let availableMenus: [AssistantMenuItem]?
    let recentOrders: [AssistantOrderItem]?
}

struct AssistantCartItem: Encodable {
    let menuId: String
    let name: String
    let size: String
    let quantity: Int
    let price: Double
}

struct AssistantMenuItem: Encodable {
    let menuId: String
    let title: String
    let price: Double
    let category: String?
}

struct AssistantOrderItem: Encodable {
    let orderId: String
    let status: String
    let totalPrice: Double
    let orderedAt: String
}

struct AssistantChatRequest: Encodable {
    let message: String
    let role: String
    let context: AssistantContext
}

struct AssistantSuggestedAction: Decodable, Identifiable {
    let id = UUID()
    let label: String
    let route: String

    enum CodingKeys: String, CodingKey {
        case label
        case route
    }
}

struct AssistantChatResponse: Decodable {
    let reply: String?
    let message: String?
    let suggestedActions: [AssistantSuggestedAction]?

    enum CodingKeys: String, CodingKey {
        case reply
        case message
        case suggestedActions
    }

    var displayText: String {
        reply ?? message ?? "I'm not sure how to help with that."
    }
}

// MARK: - URL Helpers

private let baseAPIDomain = "https://api.cookedlocal.net"

private func resolveImageURL(_ urlString: String?) -> String? {
    guard let urlString = urlString, !urlString.isEmpty else { return nil }
    if urlString.hasPrefix("http") {
        return urlString
    }
    let path = urlString.hasPrefix("/") ? urlString : "/\(urlString)"
    return "\(baseAPIDomain)\(path)"
}

// MARK: - Mappers

extension APICategory {
    func toFoodCategory() -> FoodCategory {
        FoodCategory(
            id: id,
            name: name,
            icon: "🍽️",
            imageURL: resolveImageURL(thumbnail)
        )
    }
}

extension APIMenuItem {
    func toFoodItem() -> FoodItem {
        FoodItem(
            id: id,
            name: title,
            imageName: "CakeImage",
            deliveryTime: deliveryTime ?? "30-50 mins",
            rating: avgRating ?? 4.5,
            reviewCount: totalReviews ?? 0,
            price: normalPrice ?? 0,
            currency: "£",
            description: description ?? "",
            shopName: shop?.shop?.shop_name ?? "",
            shopImageName: "chefImage",
            imageURL: resolveImageURL(thumbnail),
            shopId: shop?.id ?? "",
            categoryId: category?.id,
            sizePrices: menuSizePrices?.map { sp in
                SizePrice(
                    size: sp.size,
                    price: sp.price,
                    availableQuantity: sp.availableQuantity,
                    totalQuantity: sp.totalQuantity
                )
            },
            isAvailable: isAvailable ?? true,
            shopProfileURL: resolveImageURL(shop?.profile_url)
        )
    }
}

extension APIProvider {
    func toChef() -> Chef {
        Chef(
            id: id,
            name: shop?.shop_name ?? email ?? "Chef",
            bannerImageName: "bgShef",
            profileImageName: "chefImage",
            rating: 4.5,
            reviewCount: 0,
            hasFacebook: social_info?.facebook_url != nil,
            hasInstagram: social_info?.instagram_url != nil,
            hasWhatsApp: social_info?.whatsapp_number != nil,
            imageURL: resolveImageURL(profile_url),
            bannerURL: resolveImageURL(shop?.shop_banner),
            bio: shop?.bio,
            shopId: id,
            socialInfo: social_info.map {
                ChefSocialInfo(
                    facebookUrl: $0.facebook_url,
                    instagramUrl: $0.instagram_url,
                    whatsappNumber: $0.whatsapp_number
                )
            },
            location: shop?.location,
            qualification: shop?.qualification
        )
    }
}
