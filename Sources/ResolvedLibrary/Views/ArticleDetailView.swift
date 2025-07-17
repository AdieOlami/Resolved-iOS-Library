//
//  ArticleDetailView.swift
//  ResolvedLibrary
//
//  Created by Olami on 2025-07-13.
//

import SwiftUI
@_exported import Resolved

// MARK: - Article Detail View

struct ArticleDetailView: View {
    let articleId: String
    let configuration: HelpCenterConfiguration
    @ObservedObject var sdkManager: ResolvedSDKManager
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            if let article = sdkManager.selectedArticle {
                VStack(alignment: .leading, spacing: 24) {
                    // Hero Section
                    VStack(alignment: .leading, spacing: 20) {
                        // Article Title
                        Text(article.title)
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(configuration.theme.textColor)
                            .lineLimit(nil)
                            .padding(.top, 8)
                        
                        // Metadata Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(configuration.theme.primaryColor.opacity(0.1))
                                        .frame(width: 32, height: 32)
                                    
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(configuration.theme.primaryColor)
                                }
                                
                                Text("Last updated: \(formatDate(article.updatedAt))")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(configuration.theme.secondaryColor)
                                
                                Spacer()
                            }
                            
                            if let description = article.description, !description.isEmpty {
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(configuration.theme.primaryColor.opacity(0.1))
                                            .frame(width: 32, height: 32)
                                        
                                        Image(systemName: "info.circle.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(configuration.theme.primaryColor)
                                    }
                                    
                                    Text(description)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(configuration.theme.secondaryColor)
                                        .lineLimit(nil)
                                    
                                    Spacer()
                                }
                            }
                            
                            // Status Badge
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.1))
                                        .frame(width: 32, height: 32)
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.green)
                                }
                                
                                Text("Published")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.green)
                                    .textCase(.uppercase)
                                
                                Spacer()
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(metadataBackgroundColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(configuration.theme.borderColor.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Content Divider
                    Divider()
                        .background(configuration.theme.borderColor.opacity(0.3))
                        .padding(.horizontal, 20)
                    
                    // Article Content
                    VStack(alignment: .leading, spacing: 0) {
//                        if let lexicalContent = article.lexicalContent, !lexicalContent.isEmpty {
//                            LexicalContentRenderer(
//                                content: lexicalContent,
//                                configuration: configuration
//                            )
//                        } else {
                            MarkdownRenderer(
                                content: article.content,
                                configuration: configuration
                            )
//                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            } else if sdkManager.articleError != nil {
                VStack(spacing: 24) {
                    Spacer()
                    
                    ErrorView(
                        message: sdkManager.articleError ?? "Failed to load article",
                        onRetry: {
                            Task {
                                await sdkManager.loadArticle(id: articleId)
                            }
                        }
                    )
                    
                    Spacer()
                }
                .padding(20)
            } else {
                VStack(spacing: 24) {
                    Spacer()
                    
                    LoadingView(message: "Loading article...")
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(configuration.theme.effectiveBackgroundColor(for: colorScheme))
        .preferredColorScheme(configuration.theme.preferredColorScheme)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .long
        return displayFormatter.string(from: date)
    }
    
    private var metadataBackgroundColor: Color {
        configuration.theme.adaptiveCardBackground(for: colorScheme).opacity(0.5)
    }
}
