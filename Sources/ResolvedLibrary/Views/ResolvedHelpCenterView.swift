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
    @State private var activeView: ViewType = .home
    @State private var searchQuery: String = ""
    @State private var isSearching: Bool = false
    @State private var openFAQIndex: Int? = 0
    
    // SDK instance
    @StateObject private var sdkManager = ResolvedSDKManager()
    
    public init(configuration: HelpCenterConfiguration) {
        self.configuration = configuration
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                // Background
                configuration.theme.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Back navigation (if not on home)
                    if activeView != .home {
                        BackNavigationView {
                            activeView = .home
                        }
                        .padding(.horizontal)
                    }
                    
                    // Main content
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            switch activeView {
                            case .home:
                                homeView
                            case .knowledgeBase:
                                KnowledgeBaseView(
                                    configuration: configuration,
                                    onBack: { activeView = .home }
                                )
                            case .tickets:
                                TicketSystemView(
                                    configuration: configuration,
                                    userId: configuration.customerId ?? "",
                                    onBack: { activeView = .home }
                                )
                            case .createTicket:
                                CreateTicketView(
                                    configuration: configuration,
                                    userId: configuration.customerId ?? "",
                                    onBack: { activeView = .home }
                                )
                            }
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            setupSDK()
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
                if shouldShowActionCards {
                    ActionCardsView(
                        configuration: configuration,
                        onNavigate: { view in
                            activeView = view
                        }
                    )
                }
                
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
    
    private var shouldShowActionCards: Bool {
        let hasKB = configuration.includeKnowledgeBase && sdkManager.organization?.capabilities.contains("use_knowledgebase") == true
        let hasTickets = configuration.includeTickets && sdkManager.organization?.capabilities.contains("use_tickets") == true
        let hasCreate = configuration.includeCreateTicket && sdkManager.organization?.capabilities.contains("use_tickets") == true
        
        return hasKB || hasTickets || hasCreate
    }
    
    // MARK: - Helper Methods
    private func setupSDK() {
        sdkManager.initialize(with: configuration)
    }
    
    private func handleSearch() {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            isSearching = false
            return
        }
        
        isSearching = true
        sdkManager.searchFAQs(query: searchQuery)
    }
    
    @MainActor
    private func refreshMainContent() async {
        // Refresh organization capabilities
        sdkManager.loadOrganization()
        
        // Refresh FAQs
        if configuration.includeFAQs {
            sdkManager.loadFAQs()
        }
        
        // Wait for completion
        while sdkManager.isLoadingFAQs || sdkManager.isLoadingOrganization {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        }
    }
}

// MARK: - Hero Section
struct HeroSectionView: View {
    let configuration: HelpCenterConfiguration
    @Binding var searchQuery: String
    @Binding var isSearching: Bool
    let onSearch: () -> Void
    
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
                        onSearch()
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

// MARK: - Action Cards
struct ActionCardsView: View {
    let configuration: HelpCenterConfiguration
    let onNavigate: (ViewType) -> Void
    @StateObject private var sdkManager = ResolvedSDKManager()
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            
            // Knowledge Base Card
            if configuration.includeKnowledgeBase && sdkManager.organization?.capabilities.contains("use_knowledgebase") == true {
                ActionCard(
                    icon: "lightbulb.fill",
                    title: "Knowledge Base",
                    description: "Explore our comprehensive collection of guides, tutorials, and documentation to find instant answers.",
                    configuration: configuration
                ) {
                    onNavigate(.knowledgeBase)
                }
            }
            
            // Create Ticket Card
            if configuration.includeCreateTicket && sdkManager.organization?.capabilities.contains("use_tickets") == true {
                ActionCard(
                    icon: "paperplane.fill",
                    title: "Get Support",
                    description: "Need personalized assistance? Submit a support ticket and our expert team will help you promptly.",
                    configuration: configuration
                ) {
                    onNavigate(.createTicket)
                }
            }
            
            // Your Tickets Card
            if configuration.includeTickets && sdkManager.organization?.capabilities.contains("use_tickets") == true {
                ActionCard(
                    icon: "ticket.fill",
                    title: "Your Tickets",
                    description: "Track the progress of your support requests and communicate with our support team.",
                    configuration: configuration
                ) {
                    onNavigate(.tickets)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Action Card
struct ActionCard: View {
    let icon: String
    let title: String
    let description: String
    let configuration: HelpCenterConfiguration
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(configuration.theme.primaryColor.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(configuration.theme.primaryColor)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(configuration.theme.textColor)
                        .multilineTextAlignment(.leading)
                    
                    Text(description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(configuration.theme.secondaryColor)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                }
                
                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 200)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(cardBorderColor, lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, perform: {}, onPressingChanged: { pressing in
            isPressed = pressing
        })
    }
    
    private var cardBackgroundColor: Color {
        if configuration.theme.mode == .dark {
            return Color(.systemGray6).opacity(0.3)
        } else {
            return Color.white.opacity(0.8)
        }
    }
    
    private var cardBorderColor: Color {
        if configuration.theme.mode == .dark {
            return Color(.systemGray4).opacity(0.3)
        } else {
            return Color(.systemGray4).opacity(0.4)
        }
    }
}

// MARK: - FAQ Section
struct FAQSectionView: View {
    let configuration: HelpCenterConfiguration
    let searchQuery: String
    let isSearching: Bool
    @Binding var openFAQIndex: Int?
    @ObservedObject var sdkManager: ResolvedSDKManager
    
    var body: some View {
        VStack(spacing: 24) {
            Text(isSearching ? "Search Results for \"\(searchQuery)\"" : "Frequently Asked Questions")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(configuration.theme.textColor)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 0) {
                if sdkManager.isLoadingFAQs {
                    LoadingView(message: "Loading frequently asked questions...")
                        .padding(48)
                } else if let faqs = displayFAQs, !faqs.isEmpty {
                    ForEach(Array(faqs.enumerated()), id: \.element.id) { index, faq in
                        FAQItemView(
                            faq: faq,
                            isOpen: openFAQIndex == index,
                            isLast: index == faqs.count - 1,
                            configuration: configuration,
                            onToggle: {
                                openFAQIndex = openFAQIndex == index ? nil : index
                            }
                        )
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(faqBorderColor, lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal)
    }
    
    private var displayFAQs: [FAQ]? {
        return isSearching ? sdkManager.searchedFAQs : sdkManager.faqs
    }
    
    private var faqBackgroundColor: Color {
        if configuration.theme.mode == .dark {
            return Color(.systemGray6).opacity(0.3)
        } else {
            return Color.white.opacity(0.7)
        }
    }
    
    private var faqBorderColor: Color {
        if configuration.theme.mode == .dark {
            return Color(.systemGray4).opacity(0.3)
        } else {
            return Color(.systemGray4).opacity(0.4)
        }
    }
}

// MARK: - FAQ Item
struct FAQItemView: View {
    let faq: FAQ
    let isOpen: Bool
    let isLast: Bool
    let configuration: HelpCenterConfiguration
    let onToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    Text(faq.question)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(configuration.theme.textColor)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(iconBackgroundColor)
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: isOpen ? "minus" : "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(configuration.theme.primaryColor)
                            .rotationEffect(.degrees(isOpen ? 0 : 0))
                            .animation(.easeInOut(duration: 0.2), value: isOpen)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(isOpen ? questionBackgroundColor : Color.clear)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isOpen {
                Text(faq.answer)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(configuration.theme.secondaryColor)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                    .background(answerBackgroundColor)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeInOut(duration: 0.3), value: isOpen)
            }
            
            if !isLast {
                Divider()
                    .background(dividerColor)
            }
        }
    }
    
    private var iconBackgroundColor: Color {
        configuration.theme.primaryColor.opacity(0.15)
    }
    
    private var questionBackgroundColor: Color {
        configuration.theme.primaryColor.opacity(0.05)
    }
    
    private var answerBackgroundColor: Color {
        if configuration.theme.mode == .dark {
            return Color(.systemGray6).opacity(0.2)
        } else {
            return Color(.systemGray6).opacity(0.3)
        }
    }
    
    private var dividerColor: Color {
        if configuration.theme.mode == .dark {
            return Color(.systemGray4).opacity(0.3)
        } else {
            return Color(.systemGray4).opacity(0.4)
        }
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
enum ViewType {
    case home
    case knowledgeBase
    case tickets
    case createTicket
}
