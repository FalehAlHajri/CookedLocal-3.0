//
//  NotificationsView.swift
//  Cooked Local
//

import SwiftUI

struct NotificationsView: View {
    @StateObject var viewModel: NotificationViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            if viewModel.isLoading && viewModel.notifications.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else if viewModel.notifications.isEmpty {
                emptyStateView
            } else {
                notificationList
            }
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Button(action: { viewModel.goBack() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.neutral900)
                    .frame(width: 44, height: 44)
                    .background(Color.neutral100.opacity(0.5))
                    .clipShape(Circle())
            }

            Text("Notifications")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    // MARK: - Notification List
    private var notificationList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.notifications) { notification in
                    notificationRow(notification)
                    Divider()
                        .padding(.horizontal, DesignTokens.Spacing.md)
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Notification Row
    private func notificationRow(_ notification: APINotification) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Circle()
                .fill(Color.brandOrange.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "bell.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.brandOrange)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title ?? "Notification")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.neutral900)

                if let description = notification.description {
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.neutral600)
                        .lineLimit(2)
                }

                if let published = notification.published {
                    Text(published)
                        .font(.system(size: 12))
                        .foregroundColor(.neutral600)
                }
            }

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Spacer()

            Image("noNotificationImage")
                .resizable()
                .scaledToFit()
                .frame(height: 200)

            Text("No Notification Yet")
                .font(.anton(DesignTokens.FontSize.headline))
                .foregroundColor(.neutral900)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
