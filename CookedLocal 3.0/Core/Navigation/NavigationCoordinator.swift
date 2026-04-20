//
//  NavigationCoordinator.swift
//  Cooked Local
//

import SwiftUI
import Combine

struct NavigationCoordinator: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var router: Router
    @ObservedObject private var session = SessionManager.shared

    var body: some View {
        NavigationStack(path: $router.path) {
            SplashView(viewModel: container.makeSplashViewModel())
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
        .onReceive(session.$isAuthenticated) { isAuthenticated in
            if !isAuthenticated && !router.path.isEmpty {
                Task { @MainActor in
                    router.popToRoot()
                    router.navigate(to: .onboarding)
                }
            }
        }
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .splash:
            SplashView(viewModel: container.makeSplashViewModel())

        case .onboarding:
            OnboardingView(viewModel: container.makeOnboardingViewModel())

        case .selectRole:
            SelectRoleView(viewModel: container.makeSelectRoleViewModel())

        case .signUp(let role):
            SignUpView(viewModel: container.makeSignUpViewModel(role: role))

        case .signUpDetails(let role):
            SignUpDetailsView(viewModel: container.makeSignUpDetailsViewModel(role: role))

        case .signIn(let role):
            SignInDetailsView(viewModel: container.makeSignInDetailsViewModel(role: role))

        case .resetPassword:
            ResetView(viewModel: container.makeResetViewModel())

        case .otp(let emailOrPhone):
            OTPView(viewModel: container.makeOTPViewModel(emailOrPhone: emailOrPhone, context: .passwordReset(email: emailOrPhone)))

        case .registrationOTP(let email):
            OTPView(viewModel: container.makeOTPViewModel(emailOrPhone: email, context: .registration(email: email)))

        case .newPassword:
            ResetPasswordView(viewModel: container.makeResetPasswordViewModel())

        case .success(let message, let subtitle, let buttonTitle, let navigateToHome):
            SuccessMessageView(
                message: message,
                subtitle: subtitle,
                buttonTitle: buttonTitle,
                navigateToHome: navigateToHome
            )

        case .home:
            HomeView(viewModel: container.makeHomeViewModel())

        case .chefHome:
            ChefHomeView(viewModel: container.makeChefHomeViewModel())

        case .search:
            SearchView(viewModel: container.makeSearchViewModel())

        case .cart:
            CartView(viewModel: container.makeCartViewModel())

        case .confirmOrder:
            ConfirmOrderView(viewModel: container.makeConfirmOrderViewModel())

        case .payment:
            PaymentView(viewModel: container.makePaymentViewModel())

        case .cashOnDelivery:
            CashOnDeliveryView(viewModel: container.makeCashOnDeliveryViewModel())

        case .shopDetail(let chef):
            ShopDetailView(viewModel: container.makeShopDetailViewModel(chef: chef))

        case .foodDetail(let item, let isFromOrder, let isFromChef):
            FoodDetailView(viewModel: container.makeFoodDetailViewModel(item: item, isFromOrder: isFromOrder, isFromChef: isFromChef))

        case .review(let item):
            ReviewView(viewModel: container.makeReviewViewModel(item: item))

        case .notifications:
            NotificationsView(viewModel: container.makeNotificationViewModel())

        case .manageProfile:
            ManageProfileView(viewModel: ManageProfileViewModel(router: container.router, userService: container.userService))

        case .manageShop:
            ManageShopView(viewModel: container.makeManageShopViewModel())

        case .paymentMethods:
            PaymentMethodsView()

        case .changePassword:
            ChangePasswordView(viewModel: container.makeChangePasswordViewModel())

        case .privacyPolicy:
            InfoPageView(viewModel: container.makeInfoPageViewModel(title: "Privacy Policy", pageType: .privacy))

        case .termsAndConditions:
            InfoPageView(viewModel: container.makeInfoPageViewModel(title: "Terms & Conditions", pageType: .terms))

        case .aboutUs:
            InfoPageView(viewModel: container.makeInfoPageViewModel(title: "About us", pageType: .about))

        case .editDish(let item):
            EditDishView(viewModel: container.makeEditDishViewModel(item: item))

        case .addDish:
            AddDishView(viewModel: container.makeAddDishViewModel())
        }
    }
}

#Preview {
    NavigationCoordinator()
        .environmentObject(DependencyContainer())
}
