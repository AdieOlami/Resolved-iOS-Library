// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
@_exported import Resolved

// MARK: - Public Interface

/// Main entry point for the Resolved Help Center UI
public struct ResolvedLibrary {
    
    /// Creates a SwiftUI Help Center view with the provided configuration
    /// - Parameter configuration: Configuration settings for the Help Center
    /// - Returns: A SwiftUI view that can be embedded in your app
    @MainActor public static func helpCenter(configuration: HelpCenterConfiguration) -> some View {
        ResolvedHelpCenterView(configuration: configuration)
    }
    
    /// Creates a standalone Knowledge Base view
    /// - Parameters:
    ///   - configuration: Configuration settings
    ///   - onDismiss: Handle dismiss
    /// - Returns: A SwiftUI view for browsing knowledge base articles
    @MainActor public static func knowledgeBase(configuration: HelpCenterConfiguration, onDismiss: (() -> Void)? = nil) -> some View {
        @State var routes = NavigationPath()
        
        return NavigationView {
            KnowledgeBaseView(
                configuration: configuration,
                routes: $routes,
                onBack: {
                    onDismiss?()
                }
            )
        }
    }
    
    /// Creates a standalone Ticket System view
    /// - Parameters:
    ///   - configuration: Configuration settings
    ///   - userId: The user ID for fetching tickets
    ///   - onDismiss: Handle dismiss
    /// - Returns: A SwiftUI view for managing support tickets
    @MainActor public static func ticketSystem(configuration: HelpCenterConfiguration, userId: String, onDismiss: (() -> Void)? = nil) -> some View {
        @State var routes = NavigationPath()
        return NavigationView {
            TicketSystemView(
                configuration: configuration,
                userId: userId,
                routes: $routes,
                onBack: {
                    onDismiss?()
                }
            )
        }
    }
    
    /// Creates a standalone Create Ticket view
    /// - Parameters:
    ///   - configuration: Configuration settings
    ///   - userId: The user ID for creating the ticket
    ///   - onDismiss: Handle dismiss
    /// - Returns: A SwiftUI view for creating new support tickets
    @MainActor public static func createTicket(configuration: HelpCenterConfiguration, userId: String, onDismiss: (() -> Void)? = nil) -> some View {
        CreateTicketView(
            configuration: configuration,
            userId: userId,
            onBack: {
                onDismiss?()
            }
        )
    }
}

// MARK: - Convenience Extensions

public extension HelpCenterConfiguration {
    
    /// Quick configuration for production environment
    /// - Parameters:
    ///   - apiKey: Your Resolved API key
    ///   - customerId: Optional customer ID
    ///   - customerEmail: Optional customer email
    ///   - customerName: Optional customer name
    ///   - theme: UI theme (defaults to light theme)
    /// - Returns: A production-ready configuration
    static func production(
        apiKey: String,
        customerId: String? = nil,
        customerEmail: String? = nil,
        customerName: String? = nil,
        theme: HelpCenterTheme = .light()
    ) -> HelpCenterConfiguration {
        return HelpCenterConfiguration(
            apiKey: apiKey,
            baseURL: URL(string: "https://api.useresolved.com/api/v1/lib")!,
            customerId: customerId,
            customerEmail: customerEmail,
            customerName: customerName,
            includeKnowledgeBase: true,
            theme: theme
        )
    }
    
    /// Quick configuration for staging environment
    /// - Parameters:
    ///   - apiKey: Your Resolved API key
    ///   - customerId: Optional customer ID
    ///   - customerEmail: Optional customer email
    ///   - customerName: Optional customer name
    ///   - theme: UI theme (defaults to light theme)
    /// - Returns: A staging-ready configuration
    static func staging(
        apiKey: String,
        customerId: String? = nil,
        customerEmail: String? = nil,
        customerName: String? = nil,
        theme: HelpCenterTheme = .light()
    ) -> HelpCenterConfiguration {
        return HelpCenterConfiguration(
            apiKey: apiKey,
            baseURL: URL(string: "https://staging-api.useresolved.com/api/v1/lib")!,
            customerId: customerId,
            customerEmail: customerEmail,
            customerName: customerName,
            theme: theme,
            loggingEnabled: true
        )
    }
    
    /// Quick configuration for development/testing
    /// - Parameters:
    ///   - apiKey: Your Resolved API key
    ///   - baseURL: Custom base URL for development
    ///   - customerId: Optional customer ID
    ///   - customerEmail: Optional customer email
    ///   - customerName: Optional customer name
    ///   - theme: UI theme (defaults to light theme)
    /// - Returns: A development-ready configuration
    static func development(
        apiKey: String,
        baseURL: URL,
        customerId: String? = nil,
        customerEmail: String? = nil,
        customerName: String? = nil,
        theme: HelpCenterTheme = .light()
    ) -> HelpCenterConfiguration {
        return HelpCenterConfiguration(
            apiKey: apiKey,
            baseURL: baseURL,
            customerId: customerId,
            customerEmail: customerEmail,
            customerName: customerName,
            theme: theme,
            shouldRetry: false,
            enableOfflineQueue: false,
            loggingEnabled: true
        )
    }
}

// MARK: - SwiftUI Preview Support

#if DEBUG
public struct ResolvedLibrary_Previews: PreviewProvider {
    public static var previews: some View {
        Group {
            // Light Theme Preview
//            ResolvedLibrary.helpCenter(
//                configuration: .development(
//                    apiKey: "preview-key",
//                    baseURL: URL(string: "https://api.example.com")!,
//                    customerId: "preview-user",
//                    customerEmail: "user@example.com",
//                    customerName: "Preview User",
//                    theme: .light(primaryColor: .blue)
//                )
//            )
//            .previewDisplayName("Light Theme")
            ResolvedLibrary.helpCenter(
                configuration: .production(
                    apiKey: "01JWQ9DPSZ2M3HFXTN31FRVFV5",
            //                    baseURL: URL(string: "https://api.example.com")!,
                    customerId: "preview-user",
                    customerEmail: "user@example.com",
                    customerName: "Preview User",
                    theme: .light(primaryColor: .blue),
                )
            )
            .previewDisplayName("Light Theme")
            
            // Dark Theme Preview
            ResolvedLibrary.helpCenter(
                configuration: .development(
                    apiKey: "preview-key",
                    baseURL: URL(string: "https://api.example.com")!,
                    customerId: "preview-user",
                    customerEmail: "user@example.com",
                    customerName: "Preview User",
                    theme: .dark(primaryColor: .purple)
                )
            )
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Theme")
            
            // Custom Theme Preview
            ResolvedLibrary.helpCenter(
                configuration: .development(
                    apiKey: "preview-key",
                    baseURL: URL(string: "https://api.example.com")!,
                    customerId: "preview-user",
                    customerEmail: "user@example.com",
                    customerName: "Preview User",
                    theme: .custom(primaryColor: .orange)
                )
            )
            .previewDisplayName("Custom Theme")
        }
    }
}
#endif
