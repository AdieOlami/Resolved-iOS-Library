//
//  ResolvedSDKManager.swift
//  ResolvedLibrary
//
//  Created by Olami on 2025-07-13.
//

import Combine
@_exported @preconcurrency import Resolved
import SwiftUI

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
    @Published public var isLoadingOrganization = true
    @Published public var isLoadingFAQs = true
    @Published public var isLoadingTickets = true
    @Published public var isLoadingCollections = true
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
    public func initialize(with configuration: HelpCenterConfiguration) async {
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

        await loadOrganization()
    }

    // MARK: - Organization
    
    public func loadOrganization() async {
        guard let sdk = sdk else { return }
        
        await MainActor.run {
            isLoadingOrganization = true
            organizationError = nil
        }
        
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

    // MARK: - FAQs
    
    public func loadFAQs() async {
        guard configuration?.includeFAQs == true, let sdk = sdk else { return }
        
        await MainActor.run {
            isLoadingFAQs = true
            faqError = nil
        }
        
        let params = FAQListParams(
            status: .published,
            limit: 20,
            sortBy: "viewCount",
            sortOrder: "desc"
        )
        
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
            }
        }
    }

    public func searchFAQs(query: String) async {
        guard let sdk = sdk else { return }
        
        let params = FAQSearchParams(query: query, limit: 20)
        
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

    // MARK: - Knowledge Base
    
    public func loadCollections() async {
        guard configuration?.includeKnowledgeBase == true, let sdk = sdk else { return }

        await MainActor.run {
            isLoadingCollections = true
            collectionError = nil
        }

        let params = CollectionListParams(includeArticleCounts: true)

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

    public func loadArticles(for collectionId: String) async {
        guard let sdk = sdk else { return }
        
        await MainActor.run {
            isLoadingArticles = true
            articleError = nil
        }
        
        let params = ArticleListParams(
            collectionId: collectionId,
            status: [.published],
            limit: 50
        )
        
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

    public func loadArticle(id: String) async {
        guard let sdk = sdk else { return }
        
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

    public func searchArticles(query: String, collectionId: String? = nil) async {
        guard let sdk = sdk else { return }
        
        await MainActor.run {
            isLoadingArticles = true
            articleError = nil
        }
        
        let params = SearchParams(
            query: query,
            collectionId: collectionId,
            limit: 20
        )
        
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

    // MARK: - Tickets

    public func loadTickets() async {
        guard configuration?.includeTickets == true, let sdk = sdk, let customerId = configuration?.customerId else { return }
        
        await MainActor.run {
            isLoadingTickets = true
            ticketError = nil
        }
        
        let params = TicketListParams(
            createdById: customerId,
            limit: 20,
            sortBy: "createdAt",
            sortOrder: "desc"
        )
        
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

    public func loadTicket(id: String) async  {
        guard let sdk = sdk else { return }
        
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

    public func createTicket(request: CreateTicketRequest) async throws -> Ticket {
        guard let sdk = sdk else {
            throw NSError(
                domain: "ResolvedSDKManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "SDK not initialized"])
        }

        return try await sdk.ticketing.createTicket(request: request)
    }

    public func addComment(to ticketId: String, content: String, senderId: String?) async throws
        -> TicketComment
    {
        guard let sdk = sdk else {
            throw NSError(
                domain: "ResolvedSDKManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "SDK not initialized"])
        }

        let request = CreateCommentRequest(
            content: content,
            senderId: senderId,
            isInternal: false
        )

        return try await sdk.ticketing.addComment(ticketId: ticketId, request: request)
    }

    public func updateTicket(id: String, request: UpdateTicketRequest) async throws -> Ticket {
        guard let sdk = sdk else {
            throw NSError(
                domain: "ResolvedSDKManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "SDK not initialized"])
        }

        let updatedTicket = try await sdk.ticketing.updateTicket(id: id, request: request)

        // Update the selected ticket if it's the one being updated
        await MainActor.run {
            if self.selectedTicket?.id == id {
                self.selectedTicket = updatedTicket
            }

            // Update in the tickets list as well
            if let index = self.tickets.firstIndex(where: { $0.id == id }) {
                self.tickets[index] = updatedTicket
            }
        }

        return updatedTicket
    }

    public func closeTicket(id: String) async throws {
        guard let sdk = sdk else {
            throw NSError(
                domain: "ResolvedSDKManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "SDK not initialized"])
        }
        
        return try await sdk.ticketing.closeTicket(id: id)
    }

    // MARK: - Helper Methods
    public func refreshData() async {
        await loadOrganization()

        if configuration?.includeFAQs == true {
            await loadFAQs()
        }

        if configuration?.includeKnowledgeBase == true {
            await loadCollections()
        }

        if configuration?.includeTickets == true && configuration?.customerId != nil {
            await loadTickets()
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
    public func refreshAll() async {
        await loadOrganization()

        if configuration?.includeFAQs == true {
            await loadFAQs()
        }

        if configuration?.includeKnowledgeBase == true {
            await loadCollections()
        }

        if configuration?.includeTickets == true && configuration?.customerId != nil {
            await loadTickets()
        }
    }

    /// Refresh FAQ data specifically
    public func refreshFAQs() async {
        // Clear current data first for immediate UI feedback
        await MainActor.run {
            faqError = nil
        }

        await loadFAQs()

        // If we have search results, refresh those too
        if !searchedFAQs.isEmpty {
            // Re-run the last search
            // You'd need to store the last search query
        }
    }

    /// Refresh knowledge base data
    public func refreshKnowledgeBase() async {
        await MainActor.run {
            collectionError = nil
            articleError = nil
        }

        await loadCollections()
    }

    /// Refresh tickets data
    public func refreshTickets() async {
        await MainActor.run {
            ticketError = nil
        }
        await loadTickets()
    }

    /// Refresh specific ticket
    public func refreshTicket(id: String) async {
        await loadTicket(id: id)
    }

    // MARK: - Loading State Helpers

    /// Check if any refresh operation is in progress
    public var isRefreshing: Bool {
        return isLoadingOrganization || isLoadingFAQs || isLoadingCollections || isLoadingArticles
            || isLoadingTickets
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
    public func refreshCapabilities() async {
        await MainActor.run {
            organizationError = nil
            isLoadingOrganization = true
        }

        await loadOrganization()

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
