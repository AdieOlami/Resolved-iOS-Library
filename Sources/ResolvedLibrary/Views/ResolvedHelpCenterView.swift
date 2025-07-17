//
//  ResolvedHelpCenterView.swift
//  ResolvedLibrary
//
//  Created by Olami on 2025-07-13.
//

import SwiftUI
@_exported import Resolved

// MARK: - Main Help Center View
public struct ResolvedHelpCenterView: View {
    // Configuration
    public let configuration: HelpCenterConfiguration
    
    // Internal state
    @State private var routes = NavigationPath()
    
    @State private var searchQuery: String = ""
    @State private var isSearching: Bool = false
    @State private var openFAQIndex: Int? = 0
    
    // SDK instance
    @StateObject private var sdkManager = ResolvedSDKManager()
    
    public init(configuration: HelpCenterConfiguration) {
        self.configuration = configuration
    }
    
    public var body: some View {
        NavigationStack(path: $routes) {
            ZStack {
                // Background
                configuration.theme.backgroundColor
                    .ignoresSafeArea()
                
                if let organization = sdkManager.organization {
                    if organization.capabilities.contains("use_sdk") {
                        // Normal help center content
                        VStack(spacing: 0) {
                            // Main content
                            ScrollView {
                                homeView
                            }
                        }
                    } else {
                        // Service Unavailable with Pull-to-Refresh
                        serviceUnavailableView
                    }
                } else if sdkManager.isLoadingOrganization {
                    // Loading organization capabilities
                    LoadingView(message: "Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Error loading organization or no organization data
                    ScrollView {
                        VStack(spacing: 20) {
                            serviceUnavailableContent
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    }
                    .refreshable {
                        await refreshOrganizationCapabilities()
                    }
                }
            }
            .navigationDestination(for: ViewType.self) { dest in
                switch dest {
                case .knowledgeBase:
                    KnowledgeBaseView(
                        configuration: configuration,
                        routes: $routes,
                        onBack: {
                            routes = NavigationPath()
                        }
                    )
                case .tickets:
                    TicketSystemView(
                        configuration: configuration,
                        userId: configuration.customerId ?? "",
                        routes: $routes,
                        onBack: {
                            routes = NavigationPath()
                        }
                    )
                case .createTicket:
                    CreateTicketView(
                        configuration: configuration,
                        userId: configuration.customerId ?? "",
                        onBack: {
                            routes = NavigationPath()
                        }
                    )
                }
            }
        }
        .task {
            await setupSDK()
        }
    }
    
    // MARK: - Home View
    private var homeView: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Hero Section
                HeroSectionView(
                    configuration: configuration,
                    searchQuery: $searchQuery,
                    isSearching: $isSearching,
                    onSearch: handleSearch
                )
                
                // Action Cards
//                if shouldShowActionCards {
                    ActionCardsView(
                        configuration: configuration,
                        onNavigate: { view in
                            routes.append(view)
                        }
                    )
//                }
                
                // FAQ Section
                if configuration.includeFAQs && sdkManager.organization?.capabilities.contains("use_faq") == true {
                    FAQSectionView(
                        configuration: configuration,
                        searchQuery: searchQuery,
                        isSearching: isSearching,
                        openFAQIndex: $openFAQIndex,
                        sdkManager: sdkManager
                    )
                }
            }
            .padding(.horizontal)
        }
        .refreshable {
            await refreshMainContent()
        }
    }
    
    private var serviceUnavailableView: some View {
        ScrollView {
            VStack(spacing: 20) {
                serviceUnavailableContent
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: UIScreen.main.bounds.height - 200) // Ensure enough height for pull-to-refresh
            .padding()
        }
        .refreshable {
            await refreshOrganizationCapabilities()
        }
    }
    
    private var serviceUnavailableContent: some View {
        VStack(spacing: 24) {
            // Error Icon
            ZStack {
                Circle()
                    .fill(errorIconBackgroundColor)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.red)
            }
            
            // Error Content
            VStack(spacing: 16) {
                Text("Service Unavailable")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(configuration.theme.textColor)
                    .multilineTextAlignment(.center)
                
                Text("The help center is temporarily unavailable. Please try again later or contact support directly.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(configuration.theme.secondaryColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                // Organization status info (if available)
                if let organization = sdkManager.organization {
                    VStack(spacing: 8) {
                        Text("Account Status: \(organization.status)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(configuration.theme.secondaryColor)
                        
                        Text("Plan: \(organization.planName)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(configuration.theme.secondaryColor)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(statusBackgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(configuration.theme.borderColor.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                
                // Error message (if any)
                if let error = sdkManager.organizationError {
                    Text("Error: \(error)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
                
                // Retry Button
                Button(action: {
                    Task {
                        await refreshOrganizationCapabilities()
                    }
                }) {
                    HStack(spacing: 8) {
                        if sdkManager.isLoadingOrganization {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        
                        Text(sdkManager.isLoadingOrganization ? "Checking..." : "Try Again")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(configuration.theme.primaryColor)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(sdkManager.isLoadingOrganization)
                
                // Pull to refresh hint
                VStack(spacing: 4) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 12))
                        .foregroundColor(configuration.theme.secondaryColor.opacity(0.6))
                    
                    Text("Pull down to refresh")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(configuration.theme.secondaryColor.opacity(0.6))
                }
                .padding(.top, 16)
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(unavailableBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(configuration.theme.borderColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var shouldShowActionCards: Bool {
        let hasKB = sdkManager.organization?.capabilities.contains("use_knowledgebase") == true
        let hasTickets = sdkManager.organization?.capabilities.contains("use_tickets") == true
        let hasCreate = sdkManager.organization?.capabilities.contains("use_tickets") == true
        
        return hasKB || hasTickets || hasCreate
    }
    
    // MARK: - Refresh Organization Capabilities
    @MainActor
    private func refreshOrganizationCapabilities() async {
        // Clear any existing error
        sdkManager.clearErrors()
        
        // Reload organization data
        await sdkManager.loadOrganization()
        
        // Wait for the operation to complete
        while sdkManager.isLoadingOrganization {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        }
        
        // Provide haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    // MARK: - Helper Methods
    
    private func setupSDK() async {
        await sdkManager.initialize(with: configuration)
    }
    
    private func handleSearch() async {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await MainActor.run {
                isSearching = false
            }
            return
        }
        
        await MainActor.run {
            isSearching = true
        }
        
        await sdkManager.searchFAQs(query: searchQuery)
    }
    
    private func refreshMainContent() async {
        // Refresh organization capabilities
        await sdkManager.loadOrganization()
        
        // Refresh FAQs
        if configuration.includeFAQs {
            await sdkManager.loadFAQs()
        }
        
        // Wait for completion
        while sdkManager.isLoadingFAQs || sdkManager.isLoadingOrganization {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        }
    }
    
    // MARK: - Computed Properties for Service Unavailable
    private var errorIconBackgroundColor: Color {
        configuration.theme.mode == .dark
        ? Color.red.opacity(0.2)
        : Color.red.opacity(0.1)
    }
    
    private var unavailableBackgroundColor: Color {
        configuration.theme.mode == .dark
        ? Color(.systemGray6).opacity(0.3)
        : Color.white.opacity(0.8)
    }
    
    private var statusBackgroundColor: Color {
        configuration.theme.mode == .dark
        ? Color(.systemGray5).opacity(0.3)
        : Color(.systemGray6).opacity(0.5)
    }
}

// MARK: - Hero Section

struct HeroSectionView: View {
    let configuration: HelpCenterConfiguration
    @Binding var searchQuery: String
    @Binding var isSearching: Bool
    let onSearch: () async -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Help Center")
                    .font(.system(size: 42, weight: .black, design: .default))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Find answers, get support, and discover everything you need to succeed with our platform")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 16, weight: .medium))
                
                TextField("Search for help topics, articles, or troubleshooting guides...", text: $searchQuery)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .onSubmit {
                        Task {
                            await onSearch()
                        }
                    }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .padding(48)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(configuration.theme.primaryColor)
        )
        .padding(.horizontal)
    }
}

// MARK: - ActionCardsView

struct ActionCardsView: View {
    let configuration: HelpCenterConfiguration
    let onNavigate: (ViewType) -> Void
    @StateObject private var sdkManager = ResolvedSDKManager()
    
    var body: some View {
        VStack(spacing: 20) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("How can we help?")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(configuration.theme.textColor)
                    
                    Text("Choose from the options below to get the help you need")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(configuration.theme.secondaryColor)
                }
                
                Spacer()
            }
            
            // Action Cards - Vertical Stack for Portrait
            VStack(spacing: 16) {
                // Knowledge Base Card
                ActionCard(
                    icon: "lightbulb.fill",
                    title: "Knowledge Base",
                    description: "Explore our comprehensive collection of guides, tutorials, and documentation to find instant answers.",
                    iconColor: .orange,
                    configuration: configuration
                ) {
                    onNavigate(.knowledgeBase)
                }
                
                // Create Ticket Card
                ActionCard(
                    icon: "paperplane.fill",
                    title: "Get Support",
                    description: "Need personalized assistance? Submit a support ticket and our expert team will help you promptly.",
                    iconColor: .blue,
                    configuration: configuration
                ) {
                    onNavigate(.createTicket)
                }
                
                // Your Tickets Card
                ActionCard(
                    icon: "ticket.fill",
                    title: "Your Tickets",
                    description: "Track the progress of your support requests and communicate with our support team.",
                    iconColor: .green,
                    configuration: configuration
                ) {
                    onNavigate(.tickets)
                }
            }
        }
    }
}

// MARK: - Enhanced Action Card
struct ActionCard: View {
    let icon: String
    let title: String
    let description: String
    let iconColor: Color
    let configuration: HelpCenterConfiguration
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Icon with gradient background
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(iconBackgroundGradient)
                        .frame(width: 64, height: 64)
                        .shadow(color: iconColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(configuration.theme.textColor)
                        .multilineTextAlignment(.leading)
                    
                    Text(description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(configuration.theme.secondaryColor)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                }
                
                Spacer()
                
                // Arrow indicator
                ZStack {
                    Circle()
                        .fill(configuration.theme.primaryColor.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(configuration.theme.primaryColor)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(cardBorderColor, lineWidth: 1)
                    )
                    .shadow(color: shadowColor, radius: isPressed ? 4 : 8, x: 0, y: isPressed ? 2 : 4)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, perform: {}, onPressingChanged: { pressing in
            isPressed = pressing
        })
    }
    
    private var iconBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [iconColor, iconColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var cardBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray6).opacity(0.3)
            : Color.white
    }
    
    private var cardBorderColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray4).opacity(0.2)
            : Color(.systemGray4).opacity(0.1)
    }
    
    private var shadowColor: Color {
        configuration.theme.mode == .dark
            ? Color.black.opacity(0.3)
            : Color.black.opacity(0.1)
    }
}

// MARK: - Alternative Compact Action Cards (if you prefer a more compact layout)
struct CompactActionCardsView: View {
    let configuration: HelpCenterConfiguration
    let onNavigate: (ViewType) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Section Header
            HStack {
                Text("Quick Actions")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(configuration.theme.textColor)
                
                Spacer()
            }
            
            // Compact Cards in 2x2 Grid for Portrait
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                
                CompactActionCard(
                    icon: "lightbulb.fill",
                    title: "Knowledge Base",
                    iconColor: .orange,
                    configuration: configuration
                ) {
                    onNavigate(.knowledgeBase)
                }
                
                CompactActionCard(
                    icon: "paperplane.fill",
                    title: "Get Support",
                    iconColor: .blue,
                    configuration: configuration
                ) {
                    onNavigate(.createTicket)
                }
                
                CompactActionCard(
                    icon: "ticket.fill",
                    title: "Your Tickets",
                    iconColor: .green,
                    configuration: configuration
                ) {
                    onNavigate(.tickets)
                }
                
                CompactActionCard(
                    icon: "questionmark.circle.fill",
                    title: "FAQ",
                    iconColor: .purple,
                    configuration: configuration
                ) {
                    // Handle FAQ navigation
                }
            }
        }
    }
}

// MARK: - Compact Action Card
struct CompactActionCard: View {
    let icon: String
    let title: String
    let iconColor: Color
    let configuration: HelpCenterConfiguration
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconBackgroundGradient)
                        .frame(width: 56, height: 56)
                        .shadow(color: iconColor.opacity(0.3), radius: 6, x: 0, y: 3)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                
                // Title
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(configuration.theme.textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(cardBorderColor, lineWidth: 1)
                    )
                    .shadow(color: shadowColor, radius: isPressed ? 4 : 8, x: 0, y: isPressed ? 2 : 4)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, perform: {}, onPressingChanged: { pressing in
            isPressed = pressing
        })
    }
    
    private var iconBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [iconColor, iconColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var cardBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray6).opacity(0.3)
            : Color.white
    }
    
    private var cardBorderColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray4).opacity(0.2)
            : Color(.systemGray4).opacity(0.1)
    }
    
    private var shadowColor: Color {
        configuration.theme.mode == .dark
            ? Color.black.opacity(0.3)
            : Color.black.opacity(0.1)
    }
}

//// MARK: - FAQ Section
//struct FAQSectionView: View {
//    let configuration: HelpCenterConfiguration
//    let searchQuery: String
//    let isSearching: Bool
//    @Binding var openFAQIndex: Int?
//    @ObservedObject var sdkManager: ResolvedSDKManager
//    
//    var body: some View {
//        VStack(spacing: 24) {
//            Text(isSearching ? "Search Results for \"\(searchQuery)\"" : "Frequently Asked Questions")
//                .font(.system(size: 32, weight: .black))
//                .foregroundColor(configuration.theme.textColor)
//                .multilineTextAlignment(.center)
//            
//            VStack(spacing: 0) {
//                if sdkManager.isLoadingFAQs {
//                    LoadingView(message: "Loading frequently asked questions...")
//                        .padding(48)
//                } else if let faqs = displayFAQs, !faqs.isEmpty {
//                    ForEach(Array(faqs.enumerated()), id: \.element.id) { index, faq in
//                        FAQItemView(
//                            faq: faq,
//                            isOpen: openFAQIndex == index,
//                            isLast: index == faqs.count - 1,
//                            configuration: configuration,
//                            onToggle: {
//                                openFAQIndex = openFAQIndex == index ? nil : index
//                            }
//                        )
//                    }
//                } else {
//                    EmptyStateView(
//                        title: isSearching ? "No results found" : "No FAQs available",
//                        message: isSearching
//                        ? "No results found for \"\(searchQuery)\". Try adjusting your search terms or browse our knowledge base."
//                        : "No frequently asked questions are available at the moment. Check back later or contact support for assistance.",
//                        configuration: configuration
//                    )
//                    .padding(48)
//                }
//            }
//            .background(
//                RoundedRectangle(cornerRadius: 24)
//                    .fill(faqBackgroundColor)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 24)
//                            .stroke(faqBorderColor, lineWidth: 1)
//                    )
//            )
//        }
//        .padding(.horizontal)
//    }
//    
//    private var displayFAQs: [FAQ]? {
//        return isSearching ? sdkManager.searchedFAQs : sdkManager.faqs
//    }
//    
//    private var faqBackgroundColor: Color {
//        if configuration.theme.mode == .dark {
//            return Color(.systemGray6).opacity(0.3)
//        } else {
//            return Color.white.opacity(0.7)
//        }
//    }
//    
//    private var faqBorderColor: Color {
//        if configuration.theme.mode == .dark {
//            return Color(.systemGray4).opacity(0.3)
//        } else {
//            return Color(.systemGray4).opacity(0.4)
//        }
//    }
//}
//
//// MARK: - FAQ Item
//struct FAQItemView: View {
//    let faq: FAQ
//    let isOpen: Bool
//    let isLast: Bool
//    let configuration: HelpCenterConfiguration
//    let onToggle: () -> Void
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            Button(action: onToggle) {
//                HStack {
//                    Text(faq.question)
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundColor(configuration.theme.textColor)
//                        .multilineTextAlignment(.leading)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    
//                    Spacer()
//                    
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 12)
//                            .fill(iconBackgroundColor)
//                            .frame(width: 32, height: 32)
//                        
//                        Image(systemName: isOpen ? "minus" : "plus")
//                            .font(.system(size: 16, weight: .semibold))
//                            .foregroundColor(configuration.theme.primaryColor)
//                            .rotationEffect(.degrees(isOpen ? 0 : 0))
//                            .animation(.easeInOut(duration: 0.2), value: isOpen)
//                    }
//                }
//                .padding(.horizontal, 24)
//                .padding(.vertical, 20)
//                .background(isOpen ? questionBackgroundColor : Color.clear)
//            }
//            .buttonStyle(PlainButtonStyle())
//            
//            if isOpen {
//                Text(faq.answer)
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(configuration.theme.secondaryColor)
//                    .lineLimit(nil)
//                    .multilineTextAlignment(.leading)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.horizontal, 24)
//                    .padding(.bottom, 20)
//                    .background(answerBackgroundColor)
//                    .transition(.opacity.combined(with: .move(edge: .top)))
//                    .animation(.easeInOut(duration: 0.3), value: isOpen)
//            }
//            
//            if !isLast {
//                Divider()
//                    .background(dividerColor)
//            }
//        }
//    }
//    
//    private var iconBackgroundColor: Color {
//        configuration.theme.primaryColor.opacity(0.15)
//    }
//    
//    private var questionBackgroundColor: Color {
//        configuration.theme.primaryColor.opacity(0.05)
//    }
//    
//    private var answerBackgroundColor: Color {
//        if configuration.theme.mode == .dark {
//            return Color(.systemGray6).opacity(0.2)
//        } else {
//            return Color(.systemGray6).opacity(0.3)
//        }
//    }
//    
//    private var dividerColor: Color {
//        if configuration.theme.mode == .dark {
//            return Color(.systemGray4).opacity(0.3)
//        } else {
//            return Color(.systemGray4).opacity(0.4)
//        }
//    }
//}

struct FAQSectionView: View {
    let configuration: HelpCenterConfiguration
    let searchQuery: String
    let isSearching: Bool
    @Binding var openFAQIndex: Int?
    @ObservedObject var sdkManager: ResolvedSDKManager
    
    var body: some View {
        VStack(spacing: 24) {
            // Section Header
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isSearching ? "Search Results" : "Frequently Asked Questions")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(configuration.theme.textColor)
                        
                        if isSearching {
                            Text("Results for \"\(searchQuery)\"")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(configuration.theme.secondaryColor)
                        } else {
                            Text("Find quick answers to common questions")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(configuration.theme.secondaryColor)
                        }
                    }
                    
                    Spacer()
                    
                    if !isSearching && displayFAQs?.isEmpty == false {
                        Text("\(displayFAQs?.count ?? 0)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(configuration.theme.primaryColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(configuration.theme.primaryColor.opacity(0.1))
                            )
                    }
                }
            }
            
            // FAQ Content
            VStack(spacing: 0) {
                if sdkManager.isLoadingFAQs {
                    LoadingView(message: "Loading frequently asked questions...")
                        .padding(48)
                } else if let faqs = displayFAQs, !faqs.isEmpty {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(faqs.enumerated()), id: \.element.id) { index, faq in
                            FAQItemView(
                                faq: faq,
                                index: index,
                                isOpen: openFAQIndex == index,
                                isLast: index == faqs.count - 1,
                                configuration: configuration,
                                onToggle: {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        openFAQIndex = openFAQIndex == index ? nil : index
                                    }
                                }
                            )
                        }
                    }
                } else {
                    EmptyStateView(
                        title: isSearching ? "No results found" : "No FAQs available",
                        message: isSearching
                        ? "No results found for \"\(searchQuery)\". Try adjusting your search terms or browse our knowledge base."
                        : "No frequently asked questions are available at the moment. Check back later or contact support for assistance.",
                        configuration: configuration
                    )
                    .padding(48)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(faqBackgroundColor)
                    .shadow(color: shadowColor, radius: 8, x: 0, y: 4)
            )
        }
    }
    
    private var displayFAQs: [FAQ]? {
        return isSearching ? sdkManager.searchedFAQs : sdkManager.faqs
    }
    
    private var faqBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray6).opacity(0.3)
            : Color.white
    }
    
    private var shadowColor: Color {
        configuration.theme.mode == .dark
            ? Color.black.opacity(0.3)
            : Color.black.opacity(0.1)
    }
}

// MARK: - Enhanced FAQ Item
struct FAQItemView: View {
    let faq: FAQ
    let index: Int
    let isOpen: Bool
    let isLast: Bool
    let configuration: HelpCenterConfiguration
    let onToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Question Button
            Button(action: onToggle) {
                HStack(spacing: 16) {
                    // Question Number Badge
                    ZStack {
                        Circle()
                            .fill(questionNumberGradient)
                            .frame(width: 32, height: 32)
                            .shadow(color: configuration.theme.primaryColor.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Question Text
                    VStack(alignment: .leading, spacing: 4) {
                        Text(faq.question)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(configuration.theme.textColor)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                        
                        if isOpen {
                            Text("Tap to close")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(configuration.theme.secondaryColor.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    // Expand/Collapse Icon
                    ZStack {
                        Circle()
                            .fill(iconBackgroundColor)
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(configuration.theme.primaryColor)
                            .rotationEffect(.degrees(isOpen ? 180 : 0))
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isOpen)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: isOpen ? 20 : 0)
                        .fill(questionBackgroundColor)
                        .animation(.easeInOut(duration: 0.3), value: isOpen)
                )
            }
            .buttonStyle(PlainButtonStyle())
                                        
            // Answer Section
            if isOpen {
                VStack(alignment: .leading, spacing: 16) {
                    Divider()
                        .background(configuration.theme.borderColor.opacity(0.3))
                        .padding(.horizontal, 20)
                    
                    HStack(alignment: .top, spacing: 16) {
                        // Answer Icon
                        ZStack {
                            Circle()
                                .fill(answerIconGradient)
                                .frame(width: 32, height: 32)
                                .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                            
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        // Answer Text
                        Text(faq.answer)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(configuration.theme.textColor)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(answerBackgroundColor)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.95)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
            
            // Divider (except for last item)
            if !isLast && !isOpen {
                Divider()
                    .background(dividerColor)
                    .padding(.horizontal, 20)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: isOpen ? 20 : 0))
        .overlay(
            RoundedRectangle(cornerRadius: isOpen ? 20 : 0)
                .stroke(isOpen ? configuration.theme.primaryColor.opacity(0.2) : Color.clear, lineWidth: 1)
                .animation(.easeInOut(duration: 0.3), value: isOpen)
        )
    }
    
    private var questionNumberGradient: LinearGradient {
        LinearGradient(
            colors: [configuration.theme.primaryColor, configuration.theme.primaryColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var answerIconGradient: LinearGradient {
        LinearGradient(
            colors: [Color.blue, Color.blue.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var iconBackgroundColor: Color {
        configuration.theme.primaryColor.opacity(0.1)
    }
    
    private var questionBackgroundColor: Color {
        if isOpen {
            return configuration.theme.primaryColor.opacity(0.05)
        }
        return Color.clear
    }
    
    private var answerBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray6).opacity(0.2)
            : Color(.systemGray6).opacity(0.3)
    }
    
    private var dividerColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray4).opacity(0.3)
            : Color(.systemGray4).opacity(0.2)
    }
}

// MARK: - FAQ Loading Skeleton
struct FAQSkeletonView: View {
    let configuration: HelpCenterConfiguration
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: 16) {
                    SkeletonCircle(size: 32)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        SkeletonLine(width: nil, height: 16)
                        SkeletonLine(width: 200, height: 14)
                    }
                    
                    Spacer()
                    
                    SkeletonCircle(size: 36)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(configuration.theme.mode == .dark ? Color(.systemGray6).opacity(0.3) : Color.white)
        )
    }
}

// MARK: - Back Navigation
struct BackNavigationView: View {
    let onBack: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Back to Help Center")
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6).opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(.systemGray4).opacity(0.4), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(.systemGray))
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let title: String
    let message: String
    let configuration: HelpCenterConfiguration
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray5).opacity(0.8))
                    .frame(width: 64, height: 64)
                
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(configuration.theme.secondaryColor)
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(configuration.theme.textColor)
                
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(configuration.theme.secondaryColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
        }
    }
}

// MARK: - View Types

enum ViewType: Hashable {
    case knowledgeBase
    case tickets
    case createTicket
}

#Preview {
    ResolvedHelpCenterView(configuration: .production(
        apiKey: "01JWQ9DPSZ2M3HFXTN31FRVFV5",
//                    baseURL: URL(string: "https://api.example.com")!,
        customerId: "preview-user",
        customerEmail: "user@example.com",
        customerName: "Preview User",
        theme: .light(primaryColor: .blue),
    ))
    .previewDisplayName("Light Theme")
}
