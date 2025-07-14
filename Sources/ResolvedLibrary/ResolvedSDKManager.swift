//
//  ResolvedSDKManager.swift
//  ResolvedLibrary
//
//  Created by Olami on 2025-07-13.
//

import SwiftUI
import Combine
@_exported @preconcurrency import Resolved

// MARK: - SDK Manager
@MainActor
public class ResolvedSDKManager: ObservableObject {
    // SDK Instance
    private var sdk: ResolvedSDK?
    
    // Published Properties
    @Published public var organization: Organization?
    @Published public var faqs: [FAQ] = []
    @Published public var searchedFAQs: [FAQ] = []
    @Published public var tickets: [Ticket] = []
    @Published public var collections: [Collection] = []
    @Published public var articles: [Article] = []
    @Published public var selectedArticle: Article?
    @Published public var selectedTicket: Ticket?
    
    // Loading States
    @Published public var isLoadingOrganization = false
    @Published public var isLoadingFAQs = false
    @Published public var isLoadingTickets = false
    @Published public var isLoadingCollections = false
    @Published public var isLoadingArticles = false
    
    // Error States
    @Published public var organizationError: String?
    @Published public var faqError: String?
    @Published public var ticketError: String?
    @Published public var collectionError: String?
    @Published public var articleError: String?
    
    // Configuration
    private var configuration: HelpCenterConfiguration?
    
    // Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    public init() {}
    
    // MARK: - Initialization
    public func initialize(with configuration: HelpCenterConfiguration) {
        self.configuration = configuration
        
        let sdkConfig = ResolvedSDKConfiguration(
            baseURL: configuration.baseURL,
            apiKey: configuration.apiKey,
            enableOfflineQueue: configuration.enableOfflineQueue,
            loggingEnabled: configuration.loggingEnabled,
            timeoutInterval: configuration.timeoutInterval,
            shouldRetry: configuration.shouldRetry,
            maxRetries: configuration.maxRetries
        )
        
        self.sdk = ResolvedSDK(configuration: sdkConfig)
        
        loadOrganization()
        
        if configuration.includeFAQs {
            loadFAQs()
        }
        
        if configuration.includeKnowledgeBase {
            loadCollections()
        }
        
        if configuration.includeTickets && configuration.customerId != nil {
            loadTickets()
        }
    }
    
    // MARK: - Organization
    public func loadOrganization() {
        guard let sdk = sdk else { return }
        
        isLoadingOrganization = true
        organizationError = nil
        
        Task {
            do {
                let org = try await sdk.getCurrentOrganization()
                await MainActor.run {
                    self.organization = org
                    self.isLoadingOrganization = false
                }
            } catch {
                await MainActor.run {
                    self.organizationError = error.localizedDescription
                    self.isLoadingOrganization = false
                }
            }
        }
    }
    
    // MARK: - FAQs
    public func loadFAQs() {
        guard let sdk = sdk else { return }
        
        isLoadingFAQs = true
        faqError = nil
        
        let params = FAQListParams(
            status: .published,
            limit: 20,
            sortBy: "viewCount",
            sortOrder: "desc"
        )
        
        Task {
            do {
                let response = try await sdk.faq.getFAQs(params: params)
                await MainActor.run {
                    self.faqs = response.data ?? []
                    self.isLoadingFAQs = false
                }
            } catch {
                await MainActor.run {
                    self.faqError = error.localizedDescription
                    self.isLoadingFAQs = false
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    
    public func searchFAQs(query: String) {
        guard let sdk = sdk else { return }
        
        let params = FAQSearchParams(query: query, limit: 20)
        
        Task {
            do {
                let response = try await sdk.faq.searchFAQs(params: params)
                await MainActor.run {
                    self.searchedFAQs = response.data ?? []
                }
            } catch {
                await MainActor.run {
                    self.faqError = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Knowledge Base
    public func loadCollections() {
        guard let sdk = sdk else { return }
        
        isLoadingCollections = true
        collectionError = nil
        
        let params = CollectionListParams(includeArticleCounts: true)
        
        Task {
            do {
                let response = try await sdk.knowledgeBase.getCollections(params: params)
                await MainActor.run {
                    self.collections = response.data ?? []
                    self.isLoadingCollections = false
                }
            } catch {
                await MainActor.run {
                    self.collectionError = error.localizedDescription
                    self.isLoadingCollections = false
                }
            }
        }
    }
    
    public func loadArticles(for collectionId: String) {
        guard let sdk = sdk else { return }
        
        isLoadingArticles = true
        articleError = nil
        
        let params = ArticleListParams(
            collectionId: collectionId,
            status: [.published],
            limit: 50
        )
        
        Task {
            do {
                let response = try await sdk.knowledgeBase.getArticles(params: params)
                await MainActor.run {
                    self.articles = response.data ?? []
                    self.isLoadingArticles = false
                }
            } catch {
                await MainActor.run {
                    self.articleError = error.localizedDescription
                    self.isLoadingArticles = false
                }
            }
        }
    }
    
    public func loadArticle(id: String) {
        guard let sdk = sdk else { return }
        
        Task {
            do {
                let article = try await sdk.knowledgeBase.getArticle(id: id)
                await MainActor.run {
                    self.selectedArticle = article
                }
            } catch {
                await MainActor.run {
                    self.articleError = error.localizedDescription
                }
            }
        }
    }
    
    public func searchArticles(query: String, collectionId: String? = nil) {
        guard let sdk = sdk else { return }
        
        isLoadingArticles = true
        articleError = nil
        
        let params = SearchParams(
            query: query,
            collectionId: collectionId,
            limit: 20
        )
        
        Task {
            do {
                let response = try await sdk.knowledgeBase.searchArticles(params: params)
                await MainActor.run {
                    self.articles = response.data ?? []
                    self.isLoadingArticles = false
                }
            } catch {
                await MainActor.run {
                    self.articleError = error.localizedDescription
                    self.isLoadingArticles = false
                }
            }
        }
    }
    
    // MARK: - Tickets
    public func loadTickets() {
        guard let sdk = sdk, let customerId = configuration?.customerId else { return }
        
        isLoadingTickets = true
        ticketError = nil
        
        let params = TicketListParams(
            createdById: customerId,
            limit: 20,
            sortBy: "createdAt",
            sortOrder: "desc"
        )
        
        Task {
            do {
                let response = try await sdk.ticketing.getTickets(params: params)
                await MainActor.run {
                    self.tickets = response.data ?? []
                    self.isLoadingTickets = false
                }
            } catch {
                await MainActor.run {
                    self.ticketError = error.localizedDescription
                    self.isLoadingTickets = false
                }
            }
        }
    }
    
    public func loadTicket(id: String) {
        guard let sdk = sdk else { return }
        
        Task {
            do {
                let ticket = try await sdk.ticketing.getTicket(id: id)
                await MainActor.run {
                    self.selectedTicket = ticket
                }
            } catch {
                await MainActor.run {
                    self.ticketError = error.localizedDescription
                }
            }
        }
    }
    
    public func createTicket(request: CreateTicketRequest) async throws -> Ticket {
        guard let sdk = sdk else {
            throw NSError(domain: "ResolvedSDKManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "SDK not initialized"])
        }
        
        return try await sdk.ticketing.createTicket(request: request)
    }
    
    public func addComment(to ticketId: String, content: String, senderId: String?) async throws -> TicketComment {
        guard let sdk = sdk else {
            throw NSError(domain: "ResolvedSDKManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "SDK not initialized"])
        }
        
        let request = CreateCommentRequest(
            content: content,
            senderId: senderId,
            isInternal: false
        )
        
        return try await sdk.ticketing.addComment(ticketId: ticketId, request: request)
    }
    
    // MARK: - Helper Methods
    public func refreshData() {
        loadOrganization()
        
        if configuration?.includeFAQs == true {
            loadFAQs()
        }
        
        if configuration?.includeKnowledgeBase == true {
            loadCollections()
        }
        
        if configuration?.includeTickets == true && configuration?.customerId != nil {
            loadTickets()
        }
    }
    
    public func clearErrors() {
        organizationError = nil
        faqError = nil
        ticketError = nil
        collectionError = nil
        articleError = nil
    }
}

extension ResolvedSDKManager {
    
    // MARK: - Refresh Methods
    
    /// Refresh all data
    @MainActor
    public func refreshAll() {
        loadOrganization()
        
        if configuration?.includeFAQs == true {
            loadFAQs()
        }
        
        if configuration?.includeKnowledgeBase == true {
            loadCollections()
        }
        
        if configuration?.includeTickets == true && configuration?.customerId != nil {
            loadTickets()
        }
    }
    
    /// Refresh FAQ data specifically
    @MainActor
    public func refreshFAQs() {
        // Clear current data first for immediate UI feedback
        faqError = nil
        
        loadFAQs()
        
        // If we have search results, refresh those too
        if !searchedFAQs.isEmpty {
            // Re-run the last search
            // You'd need to store the last search query
        }
    }
    
    /// Refresh knowledge base data
    @MainActor
    public func refreshKnowledgeBase() {
        collectionError = nil
        articleError = nil
        
        loadCollections()
    }
    
    /// Refresh tickets data
    @MainActor
    public func refreshTickets() {
        ticketError = nil
        loadTickets()
    }
    
    /// Refresh specific ticket
    @MainActor
    public func refreshTicket(id: String) {
        loadTicket(id: id)
    }
    
    // MARK: - Loading State Helpers
    
    /// Check if any refresh operation is in progress
    public var isRefreshing: Bool {
        return isLoadingOrganization ||
               isLoadingFAQs ||
               isLoadingCollections ||
               isLoadingArticles ||
               isLoadingTickets
    }
}

extension ResolvedSDKManager {
    
    // MARK: - Capability Checks
    
    /// Check if the user has access to the SDK
    public var hasSDKAccess: Bool {
        return organization?.capabilities.contains("use_sdk") == true
    }
    
    /// Check specific capability
    public func hasCapability(_ capability: String) -> Bool {
        return organization?.capabilities.contains(capability) == true
    }
    
    /// Get all available capabilities
    public var availableCapabilities: [String] {
        return organization?.capabilities ?? []
    }
    
    /// Refresh organization capabilities specifically
    @MainActor
    public func refreshCapabilities() async {
        organizationError = nil
        isLoadingOrganization = true
        
        loadOrganization()
        
        // Wait for completion
        while isLoadingOrganization {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }
    
    /// Check if the organization is in a valid state
    public var isOrganizationValid: Bool {
        guard let org = organization else { return false }
        return org.status.lowercased() == "active"
    }
    
    /// Get user-friendly capability descriptions
    public func getCapabilityDescription(_ capability: String) -> String {
        switch capability {
        case "use_sdk":
            return "Access to Help Center SDK"
        case "use_knowledgebase":
            return "Knowledge Base Access"
        case "use_tickets":
            return "Support Tickets"
        case "use_faq":
            return "Frequently Asked Questions"
        default:
            return capability.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}
