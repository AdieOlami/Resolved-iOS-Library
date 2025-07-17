//
//  HelpCenterTheme+Extensions.swift
//  ResolvedLibrary
//
//  Created by Olami on 2025-07-17.
//

import SwiftUI

// MARK: - Theme Extensions for Better Dark Mode Support

extension HelpCenterTheme {

    /// Returns the effective theme mode based on current system appearance
    func effectiveMode(for colorScheme: ColorScheme) -> ThemeMode {
        switch self.mode {
        case .automatic:
            return colorScheme == .dark ? .dark : .light
        case .light, .dark:
            return self.mode
        }
    }

    /// Returns the effective text color based on theme mode and system appearance
    func effectiveTextColor(for colorScheme: ColorScheme) -> Color {
        switch self.mode {
        case .automatic:
            return Color(.label)
        case .light, .dark:
            return self.textColor
        }
    }

    /// Returns the effective background color based on theme mode and system appearance
    func effectiveBackgroundColor(for colorScheme: ColorScheme) -> Color {
        switch self.mode {
        case .automatic:
            return Color(.systemBackground)
        case .light, .dark:
            return self.backgroundColor
        }
    }

    /// Returns the effective secondary color based on theme mode and system appearance
    func effectiveSecondaryColor(for colorScheme: ColorScheme) -> Color {
        switch self.mode {
        case .automatic:
            return Color(.secondaryLabel)
        case .light, .dark:
            return self.secondaryColor
        }
    }

    /// Returns the effective border color based on theme mode and system appearance
    func effectiveBorderColor(for colorScheme: ColorScheme) -> Color {
        switch self.mode {
        case .automatic:
            return Color(.systemGray4)
        case .light, .dark:
            return self.borderColor
        }
    }

    /// Returns the preferred color scheme for the view
    var preferredColorScheme: ColorScheme? {
        switch self.mode {
        case .automatic:
            return nil  // Let system decide
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

// MARK: - Adaptive Color Helpers

extension HelpCenterTheme {

    /// Returns an adaptive card background color that works well in both light and dark modes
    func adaptiveCardBackground(for colorScheme: ColorScheme) -> Color {
        let effectiveMode = self.effectiveMode(for: colorScheme)
        switch effectiveMode {
        case .light:
            return Color.white
        case .dark:
            return Color(.systemGray6).opacity(0.3)
        case .automatic:
            return Color(.systemGray6).opacity(colorScheme == .dark ? 0.3 : 1.0)
        }
    }

    /// Returns an adaptive shadow color that works well in both light and dark modes
    func adaptiveShadowColor(for colorScheme: ColorScheme) -> Color {
        let effectiveMode = self.effectiveMode(for: colorScheme)
        switch effectiveMode {
        case .light:
            return Color.black.opacity(0.1)
        case .dark:
            return Color.black.opacity(0.3)
        case .automatic:
            return Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1)
        }
    }

    /// Returns an adaptive input field background color
    func adaptiveInputBackground(for colorScheme: ColorScheme) -> Color {
        let effectiveMode = self.effectiveMode(for: colorScheme)
        switch effectiveMode {
        case .light:
            return Color(.systemGray6).opacity(0.3)
        case .dark:
            return Color(.systemGray5).opacity(0.3)
        case .automatic:
            return Color(.systemGray5).opacity(colorScheme == .dark ? 0.3 : 0.5)
        }
    }

    /// Returns an adaptive button background color for secondary buttons
    func adaptiveSecondaryButtonBackground(for colorScheme: ColorScheme) -> Color {
        let effectiveMode = self.effectiveMode(for: colorScheme)
        switch effectiveMode {
        case .light:
            return Color.white.opacity(0.8)
        case .dark:
            return Color(.systemGray5).opacity(0.3)
        case .automatic:
            return colorScheme == .dark
                ? Color(.systemGray5).opacity(0.3) : Color.white.opacity(0.8)
        }
    }

    /// Returns an adaptive divider color
    func adaptiveDividerColor(for colorScheme: ColorScheme) -> Color {
        let effectiveMode = self.effectiveMode(for: colorScheme)
        switch effectiveMode {
        case .light:
            return Color(.systemGray4).opacity(0.2)
        case .dark:
            return Color(.systemGray4).opacity(0.3)
        case .automatic:
            return Color(.systemGray4).opacity(colorScheme == .dark ? 0.3 : 0.2)
        }
    }
}

// MARK: - View Modifier for Theme Support

struct AdaptiveTheme: ViewModifier {
    let configuration: HelpCenterConfiguration
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(configuration.theme.preferredColorScheme)
            .background(configuration.theme.effectiveBackgroundColor(for: colorScheme))
    }
}

extension View {
    /// Applies adaptive theme styling to the view
    func adaptiveTheme(_ configuration: HelpCenterConfiguration) -> some View {
        self.modifier(AdaptiveTheme(configuration: configuration))
    }
}
