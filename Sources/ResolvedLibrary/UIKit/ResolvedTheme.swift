////
////  ResolvedTheme.swift
////  ResolvedLibrary
////
////  Created by Olami on 2025-07-13.
////
//
//import UIKit
//
//public struct ResolvedTheme {
//    // MARK: - Properties
//    public var mode: ThemeMode
//    public var primaryColor: UIColor
//    public var secondaryColor: UIColor
//    public var backgroundColor: UIColor
//    public var surfaceColor: UIColor
//    public var glassSurfaceColor: UIColor
//    public var textPrimaryColor: UIColor
//    public var textSecondaryColor: UIColor
//    public var borderColor: UIColor
//    public var errorColor: UIColor
//    public var successColor: UIColor
//    public var warningColor: UIColor
//    
//    public var headingFont: UIFont
//    public var titleFont: UIFont
//    public var bodyFont: UIFont
//    public var captionFont: UIFont
//    public var buttonFont: UIFont
//    
//    public var smallSpacing: CGFloat
//    public var mediumSpacing: CGFloat
//    public var largeSpacing: CGFloat
//    public var extraLargeSpacing: CGFloat
//    
//    public var smallCornerRadius: CGFloat
//    public var mediumCornerRadius: CGFloat
//    public var largeCornerRadius: CGFloat
//    public var extraLargeCornerRadius: CGFloat
//    
//    public var glassOpacity: CGFloat
//    public var glassBlurRadius: CGFloat
//    public var shadowOpacity: Float
//    public var shadowRadius: CGFloat
//    
//    public enum ThemeMode {
//        case light
//        case dark
//        case auto
//    }
//    
//    // MARK: - Default Themes
//    public static let `default` = ResolvedTheme(
//        mode: .auto,
//        primaryColor: UIColor(red: 59/255, green: 130/255, blue: 246/255, alpha: 1.0),
//        secondaryColor: UIColor(red: 107/255, green: 114/255, blue: 128/255, alpha: 1.0),
//        backgroundColor: UIColor.systemBackground,
//        surfaceColor: UIColor.secondarySystemBackground,
//        glassSurfaceColor: UIColor(white: 1.0, alpha: 0.7),
//        textPrimaryColor: UIColor.label,
//        textSecondaryColor: UIColor.secondaryLabel,
//        borderColor: UIColor.separator,
//        errorColor: UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0),
//        successColor: UIColor(red: 34/255, green: 197/255, blue: 94/255, alpha: 1.0),
//        warningColor: UIColor(red: 251/255, green: 191/255, blue: 36/255, alpha: 1.0),
//        headingFont: UIFont.systemFont(ofSize: 28, weight: .black),
//        titleFont: UIFont.systemFont(ofSize: 20, weight: .bold),
//        bodyFont: UIFont.systemFont(ofSize: 16, weight: .medium),
//        captionFont: UIFont.systemFont(ofSize: 12, weight: .medium),
//        buttonFont: UIFont.systemFont(ofSize: 16, weight: .semibold),
//        smallSpacing: 8, mediumSpacing: 16, largeSpacing: 24, extraLargeSpacing: 32,
//        smallCornerRadius: 8, mediumCornerRadius: 16, largeCornerRadius: 24, extraLargeCornerRadius: 32,
//        glassOpacity: 0.7, glassBlurRadius: 20, shadowOpacity: 0.1, shadowRadius: 25
//    )
//    
//    public static let dark = ResolvedTheme(
//        mode: .dark,
//        primaryColor: UIColor(red: 59/255, green: 130/255, blue: 246/255, alpha: 1.0),
//        secondaryColor: UIColor(red: 156/255, green: 163/255, blue: 175/255, alpha: 1.0),
//        backgroundColor: UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1.0),
//        surfaceColor: UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 1.0),
//        glassSurfaceColor: UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 0.6),
//        textPrimaryColor: UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1.0),
//        textSecondaryColor: UIColor(red: 148/255, green: 163/255, blue: 184/255, alpha: 1.0),
//        borderColor: UIColor(red: 148/255, green: 163/255, blue: 184/255, alpha: 0.2),
//        errorColor: UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0),
//        successColor: UIColor(red: 34/255, green: 197/255, blue: 94/255, alpha: 1.0),
//        warningColor: UIColor(red: 251/255, green: 191/255, blue: 36/255, alpha: 1.0),
//        headingFont: UIFont.systemFont(ofSize: 28, weight: .black),
//        titleFont: UIFont.systemFont(ofSize: 20, weight: .bold),
//        bodyFont: UIFont.systemFont(ofSize: 16, weight: .medium),
//        captionFont: UIFont.systemFont(ofSize: 12, weight: .medium),
//        buttonFont: UIFont.systemFont(ofSize: 16, weight: .semibold),
//        smallSpacing: 8, mediumSpacing: 16, largeSpacing: 24, extraLargeSpacing: 32,
//        smallCornerRadius: 8, mediumCornerRadius: 16, largeCornerRadius: 24, extraLargeCornerRadius: 32,
//        glassOpacity: 0.6, glassBlurRadius: 20, shadowOpacity: 0.25, shadowRadius: 25
//    )
//    
//    public var effectiveColors: EffectiveColors {
//        let isDarkMode: Bool
//        switch mode {
//        case .light: isDarkMode = false
//        case .dark: isDarkMode = true
//        case .auto:
//            if #available(iOS 13.0, *) {
//                isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
//            } else {
//                isDarkMode = false
//            }
//        }
//        
//        return EffectiveColors(
//            isDarkMode: isDarkMode,
//            primaryColor: primaryColor,
//            secondaryColor: secondaryColor,
//            backgroundColor: isDarkMode ? Self.dark.backgroundColor : backgroundColor,
//            surfaceColor: isDarkMode ? Self.dark.surfaceColor : surfaceColor,
//            glassSurfaceColor: isDarkMode ? Self.dark.glassSurfaceColor : glassSurfaceColor,
//            textPrimaryColor: isDarkMode ? Self.dark.textPrimaryColor : textPrimaryColor,
//            textSecondaryColor: isDarkMode ? Self.dark.textSecondaryColor : textSecondaryColor,
//            borderColor: isDarkMode ? Self.dark.borderColor : borderColor
//        )
//    }
//}
//
//public struct EffectiveColors {
//    public let isDarkMode: Bool
//    public let primaryColor: UIColor
//    public let secondaryColor: UIColor
//    public let backgroundColor: UIColor
//    public let surfaceColor: UIColor
//    public let glassSurfaceColor: UIColor
//    public let textPrimaryColor: UIColor
//    public let textSecondaryColor: UIColor
//    public let borderColor: UIColor
//}
