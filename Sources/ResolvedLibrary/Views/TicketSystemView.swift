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
    @Binding var routes: NavigationPath
    let onBack: () -> Void
    
    @StateObject private var sdkManager = ResolvedSDKManager()
    @State private var searchQuery = ""
    @State private var activeTab = "conversation"
    @State private var newCommentText = ""
    @State private var isSubmittingComment = false
    @Environment(\.colorScheme) private var colorScheme
    
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
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Content
            ScrollView {
                LazyVStack(spacing: 0) {
                    if sdkManager.isLoadingTickets {
                        loadingTicketsView
                    } else if let error = sdkManager.ticketError {
                        ErrorView(message: error, onRetry: {
                            Task {
                                await sdkManager.loadTickets()
                            }
                        })
                        .padding(16)
                    } else if filteredTickets.isEmpty {
                        emptyTicketsView
                    } else {
                        ticketsListView
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .refreshable {
                await refreshTickets()
            }
        }
        .background(configuration.theme.effectiveBackgroundColor(for: colorScheme))
        .preferredColorScheme(configuration.theme.preferredColorScheme)
        .navigationBarHidden(true)
        .navigationDestination(for: String.self) { ticketId in
            TicketDetailView(
                ticketId: ticketId,
                configuration: configuration,
                sdkManager: sdkManager,
                activeTab: $activeTab,
                newCommentText: $newCommentText,
                isSubmittingComment: $isSubmittingComment,
                onSubmitComment: submitComment
            )
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        routes.removeLast()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(configuration.theme.primaryColor)
                    }
                }
            }
        }
        .task {
            await setupSDK()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 0) {
            // Top section with title and stats
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Support Tickets")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(configuration.theme.textColor)
                    
                    if !sdkManager.tickets.isEmpty {
                        Text("\(sdkManager.tickets.count) Ticket\(sdkManager.tickets.count == 1 ? "" : "s")")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(configuration.theme.secondaryColor)
                    }
                }
                
                Spacer()
                
                // Back button
                Button(action: onBack) {
                    ZStack {
                        Circle()
                            .fill(configuration.theme.primaryColor.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(configuration.theme.primaryColor)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Search Bar
            searchBarView
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            
            // Status Overview Cards
            if !sdkManager.tickets.isEmpty {
                statusOverviewView
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            
            Divider()
                .background(configuration.theme.borderColor.opacity(0.3))
        }
        .background(headerBackgroundColor)
    }
    
    private var searchBarView: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(configuration.theme.primaryColor.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(configuration.theme.primaryColor)
            }
            
            TextField("Search tickets...", text: $searchQuery)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(configuration.theme.textColor)
            
            if !searchQuery.isEmpty {
                Button(action: {
                    searchQuery = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(configuration.theme.secondaryColor)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(searchBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(configuration.theme.borderColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var statusOverviewView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ticketStatusCounts, id: \.status) { statusCount in
                    StatusOverviewCard(
                        status: statusCount.status,
                        count: statusCount.count,
                        configuration: configuration
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Content Views
    private var loadingTicketsView: some View {
        LazyVStack(spacing: 16) {
            ForEach(0..<5, id: \.self) { _ in
                SkeletonTicketCardView(configuration: configuration)
            }
        }
        .padding(.top, 20)
    }
    
    private var emptyTicketsView: some View {
        EmptyStateView(
            title: searchQuery.isEmpty ? "No tickets yet" : "No tickets found",
            message: searchQuery.isEmpty
                ? "You haven't created any tickets yet. Create your first ticket to get started!"
                : "No tickets match your search criteria. Try adjusting your search terms.",
            configuration: configuration
        )
        .padding(40)
    }
    
    private var ticketsListView: some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredTickets, id: \.id) { ticket in
                TicketCardView(
                    ticket: ticket,
                    configuration: configuration,
                    onSelect: {
                        Task {
                            await MainActor.run {
                                routes.append(ticket.id)
                            }
                            await sdkManager.loadTicket(id: ticket.id)
                        }
                    }
                )
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Helper Methods
    private func setupSDK() async {
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
        if sdkManager.organization == nil {
            await sdkManager.initialize(with: config)
        }
        await sdkManager.loadTickets()
    }
    
    private func submitComment() async {
        guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let ticketId = sdkManager.selectedTicket?.id else { return }
        
        await MainActor.run {
            isSubmittingComment = true
        }
        
        do {
            _ = try await sdkManager.addComment(
                to: ticketId,
                content: newCommentText,
                senderId: userId
            )
            
            await MainActor.run {
                newCommentText = ""
                isSubmittingComment = false
            }
            
            await sdkManager.loadTicket(id: ticketId)
        } catch {
            await MainActor.run {
                isSubmittingComment = false
            }
        }
    }
    
    private func refreshTickets() async {
        await sdkManager.loadTickets()
        
        while sdkManager.isLoadingTickets {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }
    
    // MARK: - Computed Properties
    
    private var headerBackgroundColor: Color {
        configuration.theme.effectiveBackgroundColor(for: colorScheme)
    }
    
    private var searchBackgroundColor: Color {
        configuration.theme.adaptiveInputBackground(for: colorScheme)
    }
    
    private var ticketStatusCounts: [(status: String, count: Int)] {
        let tickets = sdkManager.tickets
        return [
            ("Open", tickets.filter { $0.status == .open || $0.status == .new }.count),
            ("In Progress", tickets.filter { $0.status == .inProgress }.count),
            ("On Hold", tickets.filter { $0.status == .onHold }.count),
            ("Resolved", tickets.filter { $0.status == .resolved || $0.status == .closed }.count)
        ].filter { $0.count > 0 }
    }
}

// MARK: - Status Overview Card
struct StatusOverviewCard: View {
    let status: String
    let count: Int
    let configuration: HelpCenterConfiguration
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
                
                Text("\(count)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(configuration.theme.textColor)
            }
            
            Text(status)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(configuration.theme.secondaryColor)
                .textCase(.uppercase)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(statusColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var statusColor: Color {
        switch status {
        case "Open": return .blue
        case "In Progress": return .orange
        case "On Hold": return .gray
        case "Resolved": return .green
        default: return .blue
        }
    }
    
    private var cardBackgroundColor: Color {
        configuration.theme.adaptiveCardBackground(for: colorScheme).opacity(0.8)
    }
}

// MARK: - TicketCardView

struct TicketCardView: View {
    let ticket: Ticket
    let configuration: HelpCenterConfiguration
    let onSelect: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 0) {
                // Header with ref ID and badges
                HStack {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(iconBackgroundGradient)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .shadow(color: configuration.theme.primaryColor.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("#\(ticket.refId)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(configuration.theme.textColor)
                            
                            Text(formatDate(ticket.createdAt))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(configuration.theme.secondaryColor)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        StatusBadge(status: ticket.status, configuration: configuration)
                        PriorityIndicator(priority: TicketPriority(rawValue: ticket.priority.rawValue) ?? .low, configuration: configuration)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Title and description
                VStack(alignment: .leading, spacing: 12) {
                    Text(ticket.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(configuration.theme.textColor)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    if !ticket.description.isEmpty {
                        Text(ticket.description)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(configuration.theme.secondaryColor)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(cardBorderColor, lineWidth: 1)
                    )
                    .shadow(color: shadowColor, radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [configuration.theme.primaryColor, configuration.theme.primaryColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var cardBackgroundColor: Color {
        configuration.theme.adaptiveCardBackground(for: colorScheme)
    }
    
    private var cardBorderColor: Color {
        configuration.theme.effectiveBorderColor(for: colorScheme).opacity(0.1)
    }
    
    private var shadowColor: Color {
        configuration.theme.adaptiveShadowColor(for: colorScheme)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}

// MARK: - StatusBadge

struct StatusBadge: View {
    let status: TicketStatus
    let configuration: HelpCenterConfiguration
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(statusText)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(statusColor)
                .textCase(.uppercase)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(statusColor.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(statusColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var statusText: String {
        switch status {
        case .new: return "New"
        case .open: return "Open"
        case .inProgress: return "In Progress"
        case .onHold: return "On Hold"
        case .resolved: return "Resolved"
        case .closed: return "Closed"
        @unknown default: return "Unknown"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .new, .open: return .blue
        case .inProgress: return .orange
        case .resolved, .closed: return .green
        case .onHold: return .gray
        @unknown default: return .gray
        }
    }
}

// MARK: - PriorityIndicator

struct PriorityIndicator: View {
    let priority: TicketPriority
    let configuration: HelpCenterConfiguration
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<priorityLevel, id: \.self) { _ in
                Circle()
                    .fill(priorityColor)
                    .frame(width: 6, height: 6)
            }
            
            ForEach(priorityLevel..<4, id: \.self) { _ in
                Circle()
                    .fill(priorityColor.opacity(0.2))
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(priorityColor.opacity(0.1))
        )
    }
    
    private var priorityLevel: Int {
        switch priority {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        case .urgent: return 4
        @unknown default: return 1
        }
    }
    
    private var priorityColor: Color {
        switch priority {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .urgent: return .red
        @unknown default: return .blue
        }
    }
}

// MARK: - Skeleton Ticket Card View
struct SkeletonTicketCardView: View {
    let configuration: HelpCenterConfiguration
    @State private var animationOffset: CGFloat = -200
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 12) {
                    SkeletonCircle(size: 44)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        SkeletonLine(width: 80, height: 16)
                        SkeletonLine(width: 120, height: 12)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    SkeletonLine(width: 60, height: 20)
                    SkeletonLine(width: 40, height: 16)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                SkeletonLine(width: nil, height: 18)
                SkeletonLine(width: 200, height: 14)
                SkeletonLine(width: 150, height: 14)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(skeletonBackgroundColor)
        )
    }
    
    private var skeletonBackgroundColor: Color {
        configuration.theme.adaptiveCardBackground(for: colorScheme)
    }
}

// MARK: - SkeletonLine

struct SkeletonLine: View {
    let width: CGFloat?
    let height: CGFloat
    @State private var animationOffset: CGFloat = -200
    
    var body: some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(
                LinearGradient(
                    colors: [
                        Color(.systemGray4).opacity(0.3),
                        Color(.systemGray3).opacity(0.5),
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
                        Color.white.opacity(0.4),
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

struct SkeletonCircle: View {
    let size: CGFloat
    @State private var animationOffset: CGFloat = -200
    
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        Color(.systemGray4).opacity(0.3),
                        Color(.systemGray3).opacity(0.5),
                        Color(.systemGray4).opacity(0.3)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: size, height: size)
            .clipped()
            .overlay(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.4),
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

// MARK: - PriorityBadge

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

//    private var dotColor: Color {
//        switch priority {
//        case "LOW": return .green
//        case "MEDIUM": return .yellow
//        case "HIGH": return .orange
//        case "URGENT": return .red
//        default:
//            return .blue
//        }
//    }
    
    private var backgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.3)
            : Color(.systemGray6).opacity(0.7)
    }
}

