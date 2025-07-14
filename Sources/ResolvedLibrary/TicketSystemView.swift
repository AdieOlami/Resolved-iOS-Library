//
//  TicketSystemView.swift
//  ResolvedLibrary
//
//  Created by Olami on 2025-07-13.
//

import SwiftUI
@_exported import Resolved

// MARK: - Ticket System View
struct TicketSystemView: View {
    let configuration: HelpCenterConfiguration
    let userId: String
    let onBack: () -> Void
    
    @StateObject private var sdkManager = ResolvedSDKManager()
    @State private var selectedTicketId: String?
    @State private var searchQuery = ""
    @State private var activeTab = "conversation"
    @State private var newCommentText = ""
    @State private var isSubmittingComment = false
    
    private var filteredTickets: [Ticket] {
        if searchQuery.isEmpty {
            return sdkManager.tickets
        } else {
            return sdkManager.tickets.filter { ticket in
                ticket.title.localizedCaseInsensitiveContains(searchQuery) ||
                ticket.description.localizedCaseInsensitiveContains(searchQuery) ||
                ticket.refId.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(spacing: 0) {
                // Sidebar Header
                sidebarHeader
                
                // Tickets List
                ScrollView {
                    LazyVStack(spacing: 8) {
                        if sdkManager.isLoadingTickets {
                            ForEach(0..<3, id: \.self) { _ in
                                SkeletonTicketView(configuration: configuration)
                            }
                        } else if let error = sdkManager.ticketError {
                            ErrorView(message: error, onRetry: {
                                sdkManager.loadTickets()
                            })
                            .padding(16)
                        } else if filteredTickets.isEmpty {
                            EmptyStateView(
                                title: searchQuery.isEmpty ? "No tickets yet" : "No tickets found",
                                message: searchQuery.isEmpty
                                    ? "You haven't created any tickets yet. Create your first ticket to get started!"
                                    : "No tickets match your search criteria. Try adjusting your search terms.",
                                configuration: configuration
                            )
                            .padding(40)
                        } else {
                            ForEach(filteredTickets, id: \.id) { ticket in
                                TicketItemView(
                                    ticket: ticket,
                                    configuration: configuration,
                                    isSelected: selectedTicketId == ticket.id,
                                    onSelect: {
                                        selectedTicketId = ticket.id
                                        sdkManager.loadTicket(id: ticket.id)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .frame(width: 400)
            .background(sidebarBackgroundColor)
            .overlay(
                Rectangle()
                    .fill(configuration.theme.borderColor.opacity(0.3))
                    .frame(width: 1),
                alignment: .trailing
            )
            
            // Main Content
            Group {
                if let selectedTicketId = selectedTicketId {
                    TicketDetailView(
                        ticketId: selectedTicketId,
                        configuration: configuration,
                        sdkManager: sdkManager,
                        activeTab: $activeTab,
                        newCommentText: $newCommentText,
                        isSubmittingComment: $isSubmittingComment,
                        onSubmitComment: submitComment
                    )
                } else {
                    emptyMainContent
                }
            }
            .frame(maxWidth: .infinity)
            .background(configuration.theme.backgroundColor)
        }
        .onAppear {
            var config = configuration
            config = HelpCenterConfiguration(
                apiKey: configuration.apiKey,
                baseURL: configuration.baseURL,
                customerId: userId,
                customerEmail: configuration.customerEmail,
                customerName: configuration.customerName,
                customerMetadata: configuration.customerMetadata,
                includeKnowledgeBase: configuration.includeKnowledgeBase,
                includeTickets: configuration.includeTickets,
                includeCreateTicket: configuration.includeCreateTicket,
                includeFAQs: configuration.includeFAQs,
                theme: configuration.theme,
                timeoutInterval: configuration.timeoutInterval,
                shouldRetry: configuration.shouldRetry,
                maxRetries: configuration.maxRetries,
                enableOfflineQueue: configuration.enableOfflineQueue,
                loggingEnabled: configuration.loggingEnabled
            )
            sdkManager.initialize(with: config)
        }
    }
    
    // MARK: - Sidebar Header
    private var sidebarHeader: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Support Tickets")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(configuration.theme.textColor)
                
                Spacer()
            }
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(configuration.theme.secondaryColor)
                    .font(.system(size: 16))
                
                TextField("Search tickets...", text: $searchQuery)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(configuration.theme.textColor)
                
                if !searchQuery.isEmpty {
                    Button(action: {
                        searchQuery = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(configuration.theme.secondaryColor)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(searchBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(configuration.theme.borderColor.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .padding(20)
        .background(sidebarHeaderBackgroundColor)
        .overlay(
            Rectangle()
                .fill(configuration.theme.borderColor.opacity(0.3))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Empty Main Content
    private var emptyMainContent: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray5).opacity(0.8))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 32))
                    .foregroundColor(configuration.theme.secondaryColor)
            }
            
            VStack(spacing: 8) {
                Text("Select a ticket")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(configuration.theme.textColor)
                
                Text("Choose a ticket from the list to view its details and continue the conversation.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(configuration.theme.secondaryColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(configuration.theme.backgroundColor)
    }
    
    // MARK: - Helper Methods
    private func submitComment() {
        guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let ticketId = selectedTicketId else { return }
        
        isSubmittingComment = true
        
        Task {
            do {
                _ = try await sdkManager.addComment(
                    to: ticketId,
                    content: newCommentText,
                    senderId: userId
                )
                
                await MainActor.run {
                    newCommentText = ""
                    isSubmittingComment = false
                    // Reload the ticket to get updated comments
                    sdkManager.loadTicket(id: ticketId)
                }
            } catch {
                await MainActor.run {
                    isSubmittingComment = false
                    // Handle error (you might want to show an alert)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var sidebarBackgroundColor: Color {
        configuration.theme.mode == .dark 
            ? Color(.systemGray6).opacity(0.3) 
            : Color.white.opacity(0.7)
    }
    
    private var sidebarHeaderBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.3)
            : Color(.systemGray6).opacity(0.5)
    }
    
    private var searchBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.3)
            : Color.white.opacity(0.9)
    }
}

// MARK: - Ticket Item View
struct TicketItemView: View {
    let ticket: Ticket
    let configuration: HelpCenterConfiguration
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with ID and badges
                HStack {
                    Text("#\(ticket.refId)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(configuration.theme.textColor)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        StatusBadge(status: ticket.status, configuration: configuration)
                        PriorityBadge(priority: ticket.priority, configuration: configuration)
                    }
                }
                
                // Title
                Text(ticket.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(configuration.theme.secondaryColor)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                Spacer()
            }
            .padding(16)
            .frame(minHeight: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ticketBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(ticketBorderColor, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var ticketBackgroundColor: Color {
        if isSelected {
            return configuration.theme.primaryColor.opacity(0.1)
        }
        return configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.2)
            : Color.white.opacity(0.6)
    }
    
    private var ticketBorderColor: Color {
        isSelected 
            ? configuration.theme.primaryColor.opacity(0.4)
            : Color.clear
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: TicketStatus
    let configuration: HelpCenterConfiguration
    
    var body: some View {
        Text(status.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(textColor)
            .textCase(.uppercase)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: 1)
                    )
            )
    }
    
    private var colors: (text: Color, background: Color, border: Color) {
        switch status {
        case .new, .open:
            return (.blue, .blue.opacity(0.1), .blue.opacity(0.3))
        case .inProgress:
            return (.orange, .orange.opacity(0.1), .orange.opacity(0.3))
        case .resolved, .closed:
            return (.green, .green.opacity(0.1), .green.opacity(0.3))
        case .onHold:
            return (.gray, .gray.opacity(0.1), .gray.opacity(0.3))
        @unknown default:
            return (.gray, .gray.opacity(0.1), .gray.opacity(0.3))
        }
    }
    
    private var textColor: Color { colors.text }
    private var backgroundColor: Color { colors.background }
    private var borderColor: Color { colors.border }
}

// MARK: - Priority Badge
struct PriorityBadge: View {
    let priority: TicketPriority
    let configuration: HelpCenterConfiguration
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(dotColor)
                .frame(width: 6, height: 6)
            
            Text(priority.rawValue.capitalized)
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
    
    private var dotColor: Color {
        switch priority {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .urgent: return .red
        @unknown default:
            return .blue
        }
    }
    
    private var backgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.3)
            : Color(.systemGray6).opacity(0.7)
    }
}

// MARK: - Skeleton Ticket View
struct SkeletonTicketView: View {
    let configuration: HelpCenterConfiguration
    @State private var animationOffset: CGFloat = -200
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SkeletonLine(width: 80, height: 16)
                Spacer()
                SkeletonLine(width: 60, height: 12)
            }
            
            SkeletonLine(width: nil, height: 14)
            SkeletonLine(width: 120, height: 14)
        }
        .padding(16)
        .frame(minHeight: 100)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(skeletonBackgroundColor)
        )
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                animationOffset = 200
            }
        }
    }
    
    private var skeletonBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.2)
            : Color.white.opacity(0.6)
    }
}

// MARK: - Skeleton Line
struct SkeletonLine: View {
    let width: CGFloat?
    let height: CGFloat
    @State private var animationOffset: CGFloat = -200
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(
                LinearGradient(
                    colors: [
                        Color(.systemGray4).opacity(0.3),
                        Color(.systemGray3).opacity(0.2),
                        Color(.systemGray4).opacity(0.3)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: height)
            .clipped()
            .overlay(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.3),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: animationOffset)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    animationOffset = 200
                }
            }
    }
}
