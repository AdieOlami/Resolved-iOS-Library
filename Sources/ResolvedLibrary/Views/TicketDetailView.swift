//
//  TicketDetailView.swift
//  ResolvedLibrary
//
//  Created by Olami on 2025-07-13.
//

@_exported import Resolved
import SwiftUI

// MARK: - Ticket Detail View

struct TicketDetailView: View {
    let ticketId: String
    let configuration: HelpCenterConfiguration
    @ObservedObject var sdkManager: ResolvedSDKManager
    @Binding var activeTab: String
    @Binding var newCommentText: String
    @Binding var isSubmittingComment: Bool
    let onSubmitComment: () async -> Void

    var body: some View {
        VStack(spacing: 0) {
            if let ticket = sdkManager.selectedTicket {
                // Header
                VStack(spacing: 0) {
                    ticketHeader(ticket: ticket)
                    tabsView
                }

                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if activeTab == "description" {
                            descriptionContent(ticket: ticket)
                        } else {
                            conversationContent(ticket: ticket)
                        }
                    }
                    .padding(.bottom, activeTab == "conversation" ? 120 : 32)
                }
                .refreshable {
                    await refreshTicketDetail()
                }

                // Message input (only for conversation tab)
                if activeTab == "conversation" {
                    messageInputView
                }
            } else if sdkManager.ticketError != nil {
                ErrorView(
                    message: sdkManager.ticketError ?? "Failed to load ticket",
                    onRetry: {
                        Task {
                            await sdkManager.loadTicket(id: ticketId)
                        }
                    }
                )
                .padding(32)
            } else {
                LoadingView(message: "Loading ticket...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(32)
            }
        }
        .background(configuration.theme.backgroundColor)
    }

    // MARK: - Ticket Header
    @ViewBuilder
    private func ticketHeader(ticket: Ticket) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("#\(ticket.refId)")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(configuration.theme.textColor)

                    Text(ticket.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(configuration.theme.secondaryColor)
                        .lineLimit(nil)
                }

                Spacer()

                VStack(spacing: 8) {
                    StatusBadge(status: ticket.status, configuration: configuration)
                    PriorityBadge(priority: ticket.priority, configuration: configuration)
                    CategoryBadge(category: ticket.category, configuration: configuration)

                    // Close ticket button
                    if ticket.status != .closed {
                        CloseTicketButton(
                            ticketId: ticket.id,
                            sdkManager: sdkManager,
                            configuration: configuration
                        )
                    }
                }
            }
        }
        .padding(32)
        .background(headerBackgroundColor)
        .overlay(
            Rectangle()
                .fill(configuration.theme.borderColor.opacity(0.3))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    // MARK: - Tabs View
    private var tabsView: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "Description",
                isActive: activeTab == "description",
                configuration: configuration
            ) {
                activeTab = "description"
            }

            TabButton(
                title: "Conversation",
                isActive: activeTab == "conversation",
                configuration: configuration
            ) {
                activeTab = "conversation"
            }

            Spacer()
        }
        .background(tabsBackgroundColor)
        .overlay(
            Rectangle()
                .fill(configuration.theme.borderColor.opacity(0.3))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    // MARK: - Description Content
    @ViewBuilder
    private func descriptionContent(ticket: Ticket) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(ticket.description)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(configuration.theme.textColor)
                .lineLimit(nil)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(32)
    }

    // MARK: - Conversation Content
    @ViewBuilder
    private func conversationContent(ticket: Ticket) -> some View {
        LazyVStack(spacing: 20) {
            if let comments = ticket.comments, !comments.isEmpty {
                ForEach(comments, id: \.id) { comment in
                    MessageBubbleView(
                        comment: comment,
                        configuration: configuration,
                        isFromCustomer: comment.userId == ticket.customerId
                    )
                }
            } else {
                EmptyStateView(
                    title: "No messages yet",
                    message: "Start the conversation by sending your first message!",
                    configuration: configuration
                )
                .padding(40)
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 32)
    }

    // MARK: - Message Input View
    private var messageInputView: some View {
        VStack(spacing: 16) {
            Divider()
                .background(configuration.theme.borderColor)

            VStack(spacing: 12) {
                // Text input
                ZStack(alignment: .topLeading) {
                    if newCommentText.isEmpty {
                        Text("Type your message here...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(configuration.theme.secondaryColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }

                    TextEditor(text: $newCommentText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(configuration.theme.textColor)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(minHeight: 60, maxHeight: 120)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(messageInputBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(configuration.theme.borderColor.opacity(0.3), lineWidth: 1)
                        )
                )

                // Actions
                HStack {
                    // Tool buttons
                    HStack(spacing: 8) {
                        ToolButton(icon: "paperclip", configuration: configuration) {
                            // Handle attachment
                        }

                        ToolButton(icon: "photo", configuration: configuration) {
                            // Handle image
                        }

                        ToolButton(icon: "face.smiling", configuration: configuration) {
                            // Handle emoji
                        }
                    }

                    Spacer()

                    // Send button
                    Button {
                        Task {
                            await onSubmitComment()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if isSubmittingComment {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Text("Send")
                                    .font(.system(size: 14, weight: .semibold))

                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(sendButtonBackgroundColor)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(
                        isSubmittingComment
                            || newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
                                .isEmpty
                    )
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 20)
        }
        .background(messageInputContainerBackgroundColor)
    }

    @MainActor
    private func refreshTicketDetail() async {
        // Refresh the current ticket details
        await sdkManager.loadTicket(id: ticketId)

        // Wait for ticket to load
        while sdkManager.selectedTicket == nil && sdkManager.ticketError == nil {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    // MARK: - Computed Properties
    private var headerBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.3)
            : Color(.systemGray6).opacity(0.5)
    }

    private var tabsBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray6).opacity(0.3)
            : Color.white.opacity(0.8)
    }

    private var messageInputBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.3)
            : Color.white.opacity(0.9)
    }

    private var messageInputContainerBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray6).opacity(0.9)
            : Color.white.opacity(0.95)
    }

    private var sendButtonBackgroundColor: Color {
        let isEmpty = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if isEmpty || isSubmittingComment {
            return Color(.systemGray4)
        }
        return configuration.theme.primaryColor
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let isActive: Bool
    let configuration: HelpCenterConfiguration
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(
                        isActive
                            ? configuration.theme.primaryColor : configuration.theme.secondaryColor)

                if isActive {
                    Rectangle()
                        .fill(configuration.theme.primaryColor)
                        .frame(height: 2)
                        .animation(.easeInOut(duration: 0.2), value: isActive)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Category Badge
struct CategoryBadge: View {
    let category: String
    let configuration: HelpCenterConfiguration

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(configuration.theme.secondaryColor)
                .frame(width: 4, height: 4)

            Text(category.capitalized)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(configuration.theme.textColor)
                .textCase(.uppercase)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(configuration.theme.borderColor.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private var backgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.3)
            : Color(.systemGray6).opacity(0.7)
    }
}

// MARK: - Message Bubble View
struct MessageBubbleView: View {
    let comment: TicketComment
    let configuration: HelpCenterConfiguration
    let isFromCustomer: Bool

    var body: some View {
        HStack {
            if isFromCustomer {
                Spacer()
            }

            VStack(alignment: isFromCustomer ? .trailing : .leading, spacing: 8) {
                // Message bubble
                HStack {
                    if !isFromCustomer {
                        AvatarView(
                            name: comment.user?.name ?? "Support",
                            isCustomer: false,
                            configuration: configuration
                        )
                    }

                    VStack(alignment: isFromCustomer ? .trailing : .leading, spacing: 4) {
                        Text(comment.content)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(
                                isFromCustomer ? .white : configuration.theme.textColor
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(bubbleBackgroundColor)
                            )
                            .frame(maxWidth: 280, alignment: isFromCustomer ? .trailing : .leading)

                        Text(formatDate(comment.createdAt))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(configuration.theme.secondaryColor)
                    }

                    if isFromCustomer {
                        AvatarView(
                            name: "You",
                            isCustomer: true,
                            configuration: configuration
                        )
                    }
                }
            }

            if !isFromCustomer {
                Spacer()
            }
        }
    }

    private var bubbleBackgroundColor: Color {
        if isFromCustomer {
            return configuration.theme.primaryColor
        } else {
            return configuration.theme.mode == .dark
                ? Color(.systemGray5).opacity(0.6)
                : Color.white.opacity(0.8)
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: dateString) else {
            return dateString
        }

        let displayFormatter = DateFormatter()
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}

// MARK: - Avatar View
struct AvatarView: View {
    let name: String
    let isCustomer: Bool
    let configuration: HelpCenterConfiguration

    var body: some View {
        ZStack {
            Circle()
                .fill(avatarBackgroundColor)
                .frame(width: 40, height: 40)

            Text(String(name.prefix(1)).uppercased())
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .overlay(
            Circle()
                .stroke(configuration.theme.borderColor.opacity(0.2), lineWidth: 1)
        )
    }

    private var avatarBackgroundColor: Color {
        isCustomer
            ? configuration.theme.primaryColor
            : Color(.systemGray4)
    }
}

// MARK: - Tool Button
struct ToolButton: View {
    let icon: String
    let configuration: HelpCenterConfiguration
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(configuration.theme.secondaryColor)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(toolButtonBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(configuration.theme.borderColor.opacity(0.2), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var toolButtonBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.3)
            : Color.white.opacity(0.8)
    }
}

// MARK: - Close Ticket Button

struct CloseTicketButton: View {
    let ticketId: String
    @ObservedObject var sdkManager: ResolvedSDKManager
    let configuration: HelpCenterConfiguration

    @State private var isClosing = false
    @State private var showConfirmation = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        Button(action: {
            showConfirmation = true
        }) {
            HStack(spacing: 4) {
                if isClosing {
                    ProgressView()
                        .scaleEffect(0.6)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                }

                Text("Close")
                    .font(.system(size: 10, weight: .semibold))
                    .textCase(.uppercase)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isClosing ? Color(.systemGray4) : Color(.systemRed))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isClosing)
        .alert("Close Ticket", isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Close Ticket", role: .destructive) {
                closeTicket()
            }
        } message: {
            Text("Are you sure you want to close this ticket? This action cannot be undone.")
        }
        .alert("Error Closing Ticket", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
            Button("Try Again") {
                closeTicket()
            }
        } message: {
            Text(errorMessage)
        }
    }

    private func closeTicket() {
        isClosing = true
        
        Task {
            do {
                _ = try await sdkManager.closeTicket(id: ticketId)
                await MainActor.run {
                    isClosing = false
                }
            } catch {
                await MainActor.run {
                    isClosing = false
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
}
