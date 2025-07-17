//
//  HelpCenterConfiguration.swift
//  ResolvedLibrary
//
//  Created by Olami on 2025-07-13.
//

import Foundation
import SwiftUI

// MARK: - Help Center Configuration
public struct HelpCenterConfiguration {
    // Required
    public let apiKey: String
    public let baseURL: URL

    // User Information
    public let customerId: String?
    public let customerEmail: String?
    public let customerName: String?
    public let customerMetadata: [String: Any]?

    // Feature Flags
    public let includeKnowledgeBase: Bool
    public let includeTickets: Bool
    public let includeCreateTicket: Bool
    public let includeFAQs: Bool

    // Theme
    public let theme: HelpCenterTheme

    // Network Configuration
    public let timeoutInterval: TimeInterval
    public let shouldRetry: Bool
    public let maxRetries: Int
    public let enableOfflineQueue: Bool
    public let loggingEnabled: Bool

    public init(
        apiKey: String,
        baseURL: URL = URL(string: "https://api.useresolved.com/api/v1/lib")!,
        customerId: String? = nil,
        customerEmail: String? = nil,
        customerName: String? = nil,
        customerMetadata: [String: Any]? = nil,
        includeKnowledgeBase: Bool = true,
        includeTickets: Bool = true,
        includeCreateTicket: Bool = true,
        includeFAQs: Bool = true,
        theme: HelpCenterTheme = .light(),
        timeoutInterval: TimeInterval = 30.0,
        shouldRetry: Bool = true,
        maxRetries: Int = 3,
        enableOfflineQueue: Bool = true,
        loggingEnabled: Bool = false
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.customerId = customerId
        self.customerEmail = customerEmail
        self.customerName = customerName
        self.customerMetadata = customerMetadata
        self.includeKnowledgeBase = includeKnowledgeBase
        self.includeTickets = includeTickets
        self.includeCreateTicket = includeCreateTicket
        self.includeFAQs = includeFAQs
        self.theme = theme
        self.timeoutInterval = timeoutInterval
        self.shouldRetry = shouldRetry
        self.maxRetries = maxRetries
        self.enableOfflineQueue = enableOfflineQueue
        self.loggingEnabled = loggingEnabled
    }
}

// MARK: - Help Center Theme
public struct HelpCenterTheme {
    public let mode: ThemeMode
    public let primaryColor: Color
    public let textColor: Color
    public let backgroundColor: Color
    public let borderColor: Color
    public let secondaryColor: Color

    public init(
        mode: ThemeMode,
        primaryColor: Color,
        textColor: Color,
        backgroundColor: Color,
        borderColor: Color,
        secondaryColor: Color
    ) {
        self.mode = mode
        self.primaryColor = primaryColor
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.secondaryColor = secondaryColor
    }

    // Predefined themes
    public static func light(
        primaryColor: Color = .blue,
        textColor: Color = Color(.label),
        backgroundColor: Color = Color(.systemBackground),
        borderColor: Color = Color(.systemGray4),
        secondaryColor: Color = Color(.secondaryLabel)
    ) -> HelpCenterTheme {
        return HelpCenterTheme(
            mode: .light,
            primaryColor: primaryColor,
            textColor: textColor,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            secondaryColor: secondaryColor
        )
    }

    public static func dark(
        primaryColor: Color = .blue,
        textColor: Color = Color(.label),
        backgroundColor: Color = Color(.systemBackground),
        borderColor: Color = Color(.systemGray4),
        secondaryColor: Color = Color(.secondaryLabel)
    ) -> HelpCenterTheme {
        return HelpCenterTheme(
            mode: .dark,
            primaryColor: primaryColor,
            textColor: textColor,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            secondaryColor: secondaryColor
        )
    }

    public static func custom(
        mode: ThemeMode = .light,
        primaryColor: Color,
        textColor: Color? = nil,
        backgroundColor: Color? = nil,
        borderColor: Color? = nil,
        secondaryColor: Color? = nil
    ) -> HelpCenterTheme {
        let baseTheme = mode == .dark ? HelpCenterTheme.dark() : HelpCenterTheme.light()

        return HelpCenterTheme(
            mode: mode,
            primaryColor: primaryColor,
            textColor: textColor ?? baseTheme.textColor,
            backgroundColor: backgroundColor ?? baseTheme.backgroundColor,
            borderColor: borderColor ?? baseTheme.borderColor,
            secondaryColor: secondaryColor ?? baseTheme.secondaryColor
        )
    }

    // Automatic theme that adapts to system appearance
    public static func automatic(
        primaryColor: Color = .blue,
        lightTextColor: Color = Color(.label),
        lightBackgroundColor: Color = Color(.systemBackground),
        lightBorderColor: Color = Color(.systemGray4),
        lightSecondaryColor: Color = Color(.secondaryLabel),
        darkTextColor: Color = Color(.label),
        darkBackgroundColor: Color = Color(.systemBackground),
        darkBorderColor: Color = Color(.systemGray4),
        darkSecondaryColor: Color = Color(.secondaryLabel)
    ) -> HelpCenterTheme {
        return HelpCenterTheme(
            mode: .automatic,
            primaryColor: primaryColor,
            textColor: lightTextColor,  // Will be dynamically handled in views
            backgroundColor: lightBackgroundColor,
            borderColor: lightBorderColor,
            secondaryColor: lightSecondaryColor
        )
    }
}

// MARK: - Theme Mode
public enum ThemeMode {
    case light
    case dark
    case automatic  // Follows system appearance
}
