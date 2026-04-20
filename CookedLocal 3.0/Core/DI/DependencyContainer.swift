//
//  DependencyContainer.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class DependencyContainer: ObservableObject {
    // MARK: - Shared Services
    let validationService: ValidationService
    let authService: AuthService
    let cartManager: CartManager
    let menuService: MenuService
    let categoryService: CategoryService
    let orderService: OrderService
    let notificationService: NotificationService
    let userService: UserService
    let commonService: CommonService

    // MARK: - Router
    let router: Router

    // MARK: - Initialization
    @MainActor
    init() {
        self.validationService = ValidationService()
        self.authService = AuthService()
        self.cartManager = CartManager()
        self.menuService = MenuService()
        self.categoryService = CategoryService()
        self.orderService = OrderService()
        self.notificationService = NotificationService()
        self.userService = UserService()
        self.commonService = CommonService()
        self.router = Router()
    }

    // MARK: - ViewModel Factories

    @MainActor
    func makeSplashViewModel() -> SplashViewModel {
        SplashViewModel(router: router)
    }

    @MainActor
    func makeOnboardingViewModel() -> OnboardingViewModel {
        OnboardingViewModel(router: router)
    }

    @MainActor
    func makeSelectRoleViewModel() -> SelectRoleViewModel {
        SelectRoleViewModel(router: router)
    }

    @MainActor
    func makeSignUpViewModel(role: UserRole) -> SignUpViewModel {
        SignUpViewModel(
            role: role,
            router: router,
            validationService: validationService
        )
    }

    @MainActor
    func makeSignUpDetailsViewModel(role: UserRole) -> SignUpDetailsViewModel {
        SignUpDetailsViewModel(
            role: role,
            router: router,
            authService: authService,
            validationService: validationService
        )
    }

    @MainActor
    func makeSignInDetailsViewModel(role: UserRole = .customer) -> SignInDetailsViewModel {
        SignInDetailsViewModel(
            role: role,
            router: router,
            authService: authService,
            validationService: validationService
        )
    }

    @MainActor
    func makeResetViewModel() -> ResetViewModel {
        ResetViewModel(
            router: router,
            authService: authService,
            validationService: validationService
        )
    }

    @MainActor
    func makeOTPViewModel(emailOrPhone: String, context: OTPContext = .passwordReset(email: "")) -> OTPViewModel {
        OTPViewModel(
            emailOrPhone: emailOrPhone,
            router: router,
            authService: authService,
            context: context
        )
    }

    @MainActor
    func makeResetPasswordViewModel() -> ResetPasswordViewModel {
        ResetPasswordViewModel(
            router: router,
            authService: authService,
            validationService: validationService
        )
    }

    @MainActor
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            router: router,
            cartManager: cartManager,
            menuService: menuService,
            categoryService: categoryService,
            userService: userService
        )
    }

    @MainActor
    func makeChefHomeViewModel() -> ChefHomeViewModel {
        ChefHomeViewModel(
            router: router,
            cartManager: cartManager,
            menuService: menuService,
            categoryService: categoryService,
            userService: userService
        )
    }

    @MainActor
    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(router: router, cartManager: cartManager, menuService: menuService, categoryService: categoryService)
    }

    @MainActor
    func makeCartViewModel() -> CartViewModel {
        CartViewModel(router: router, cartManager: cartManager)
    }

    @MainActor
    func makeConfirmOrderViewModel() -> ConfirmOrderViewModel {
        ConfirmOrderViewModel(router: router, cartManager: cartManager)
    }

    @MainActor
    func makePaymentViewModel() -> PaymentViewModel {
        PaymentViewModel(router: router, cartManager: cartManager, orderService: orderService)
    }

    @MainActor
    func makeCashOnDeliveryViewModel() -> CashOnDeliveryViewModel {
        CashOnDeliveryViewModel(router: router, cartManager: cartManager, orderService: orderService)
    }

    @MainActor
    func makeShopDetailViewModel(chef: Chef) -> ShopDetailViewModel {
        ShopDetailViewModel(chef: chef, router: router, cartManager: cartManager, menuService: menuService, categoryService: categoryService)
    }

    @MainActor
    func makeFoodDetailViewModel(item: FoodItem, isFromOrder: Bool = false, isFromChef: Bool = false) -> FoodDetailViewModel {
        FoodDetailViewModel(foodItem: item, router: router, cartManager: cartManager, isFromOrder: isFromOrder, isFromChef: isFromChef)
    }

    @MainActor
    func makeReviewViewModel(item: FoodItem) -> ReviewViewModel {
        ReviewViewModel(foodItem: item, router: router, orderService: orderService)
    }

    @MainActor
    func makeNotificationViewModel() -> NotificationViewModel {
        NotificationViewModel(router: router, notificationService: notificationService)
    }

    @MainActor
    func makeEditDishViewModel(item: FoodItem) -> EditDishViewModel {
        EditDishViewModel(foodItem: item, router: router, menuService: menuService, categoryService: categoryService)
    }

    @MainActor
    func makeAddDishViewModel() -> AddDishViewModel {
        AddDishViewModel(router: router, menuService: menuService, categoryService: categoryService)
    }

    @MainActor
    func makeChangePasswordViewModel() -> ChangePasswordViewModel {
        ChangePasswordViewModel(router: router, userService: userService)
    }

    @MainActor
    func makeManageShopViewModel() -> ManageShopViewModel {
        ManageShopViewModel(router: router, userService: userService)
    }

    @MainActor
    func makeInfoPageViewModel(title: String, pageType: InfoPageType) -> InfoPageViewModel {
        InfoPageViewModel(title: title, pageType: pageType, router: router, commonService: commonService)
    }
}
