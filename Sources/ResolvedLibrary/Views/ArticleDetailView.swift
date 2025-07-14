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
    
    var body: some View {
        ScrollView {
            if let article = sdkManager.selectedArticle {
                VStack(alignment: .leading, spacing: 32) {
                    // Article Header
                    VStack(alignment: .leading, spacing: 16) {
                        Text(article.title)
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(configuration.theme.textColor)
                            .lineLimit(nil)
                        
                        // Metadata
                        HStack(spacing: 12) {
                            MetadataBadge(
                                text: "Last updated: \(formatDate(article.updatedAt))",
                                configuration: configuration
                            )
                            
                            if let description = article.description, !description.isEmpty {
                                MetadataBadge(
                                    text: description,
                                    configuration: configuration
                                )
                            }
                            
                            MetadataBadge(
                                text: "Published",
                                configuration: configuration
                            )
                        }
                        .padding(.bottom, 16)
                        
                        Divider()
                            .background(configuration.theme.borderColor)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 32)
                    
                    // Article Content
                    VStack(alignment: .leading, spacing: 0) {
                        if let lexicalContent = article.lexicalContent, !lexicalContent.isEmpty {
                            // Render Lexical content (you'll need to implement this based on your Lexical JSON structure)
                            LexicalContentRenderer(
                                content: lexicalContent,
                                configuration: configuration
                            )
                        } else {
                            // Fallback to markdown/plain text
                            MarkdownRenderer(
                                content: article.content,
                                configuration: configuration
                            )
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
            } else if sdkManager.articleError != nil {
                ErrorView(
                    message: sdkManager.articleError ?? "Failed to load article",
                    onRetry: {
                        sdkManager.loadArticle(id: articleId)
                    }
                )
                .padding(32)
            } else {
                LoadingView(message: "Loading article...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(configuration.theme.backgroundColor)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .long
        return displayFormatter.string(from: date)
    }
}

// MARK: - Metadata Badge
struct MetadataBadge: View {
    let text: String
    let configuration: HelpCenterConfiguration
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(configuration.theme.secondaryColor)
            .textCase(.uppercase)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(configuration.theme.primaryColor.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(configuration.theme.primaryColor.opacity(0.15), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Lexical Content Renderer
struct LexicalContentRenderer: View {
    let content: String
    let configuration: HelpCenterConfiguration
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Parse and render Lexical JSON content
            // This is a simplified implementation - you'll need to parse the actual Lexical JSON structure
            if let data = content.data(using: .utf8),
               let lexicalData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                LexicalNodeRenderer(
                    node: lexicalData,
                    configuration: configuration
                )
            } else {
                // Fallback to plain text
                Text(content)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(configuration.theme.textColor)
                    .lineLimit(nil)
            }
        }
    }
}

// MARK: - Lexical Node Renderer
struct LexicalNodeRenderer: View {
    let node: [String: Any]
    let configuration: HelpCenterConfiguration
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let root = node["root"] as? [String: Any],
               let children = root["children"] as? [[String: Any]] {
                ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                    LexicalElementRenderer(
                        element: child,
                        configuration: configuration
                    )
                }
            }
        }
    }
}

// MARK: - Lexical Element Renderer
struct LexicalElementRenderer: View {
    let element: [String: Any]
    let configuration: HelpCenterConfiguration
    
    var body: some View {
        Group {
            if let type = element["type"] as? String {
                switch type {
                case "paragraph":
                    renderParagraph()
                case "heading":
                    renderHeading()
                case "list":
                    renderList()
                case "quote":
                    renderQuote()
                case "code":
                    renderCodeBlock()
                default:
                    renderParagraph() // Default to paragraph
                }
            } else {
                renderParagraph()
            }
        }
    }
    
    @ViewBuilder
    private func renderParagraph() -> some View {
        if let children = element["children"] as? [[String: Any]] {
            HStack(alignment: .top, spacing: 0) {
                ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                    renderTextNode(child)
                }
                Spacer()
            }
            .padding(.bottom, 8)
        }
    }
    
    @ViewBuilder
    private func renderHeading() -> some View {
        if let children = element["children"] as? [[String: Any]],
           let tag = element["tag"] as? String {
            let fontSize: CGFloat = {
                switch tag {
                case "h1": return 28
                case "h2": return 24
                case "h3": return 20
                case "h4": return 18
                case "h5": return 16
                case "h6": return 14
                default: return 20
                }
            }()
            
            HStack(alignment: .top, spacing: 0) {
                ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                    renderTextNode(child, fontSize: fontSize, weight: .bold)
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
    
    @ViewBuilder
    private func renderList() -> some View {
        if let children = element["children"] as? [[String: Any]] {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                    if let listItemChildren = child["children"] as? [[String: Any]] {
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(configuration.theme.textColor)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(Array(listItemChildren.enumerated()), id: \.offset) { childIndex, listChild in
                                    renderTextNode(listChild)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            .padding(.leading, 16)
            .padding(.bottom, 8)
        }
    }
    
    @ViewBuilder
    private func renderQuote() -> some View {
        if let children = element["children"] as? [[String: Any]] {
            HStack(alignment: .top, spacing: 16) {
                Rectangle()
                    .fill(configuration.theme.primaryColor)
                    .frame(width: 4)
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                        renderTextNode(child, style: .callout) // .italic
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(configuration.theme.primaryColor.opacity(0.05))
            )
            .padding(.bottom, 8)
        }
    }
    
    @ViewBuilder
    private func renderCodeBlock() -> some View {
        if let children = element["children"] as? [[String: Any]] {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                    renderTextNode(child, fontDesign: .monospaced)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(codeBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(configuration.theme.borderColor.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.bottom, 8)
        }
    }
    
    @ViewBuilder
    private func renderTextNode(
        _ textNode: [String: Any],
        fontSize: CGFloat = 16,
        weight: Font.Weight = .medium,
        style: Font.TextStyle = .body,
        fontDesign: Font.Design = .default
    ) -> some View {
        if let text = textNode["text"] as? String {
            let format = textNode["format"] as? Int ?? 0
            let isBold = (format & 1) != 0
            let isItalic = (format & 2) != 0
            let isUnderline = (format & 8) != 0
            let isCode = (format & 16) != 0
            
            Text(text)
                .font(.system(size: fontSize, weight: isBold ? .bold : weight, design: isCode ? .monospaced : fontDesign))
                .foregroundColor(isCode ? configuration.theme.primaryColor : configuration.theme.textColor)
                .italic(isItalic)
                .underline(isUnderline)
                .background(isCode ? codeInlineBackgroundColor : Color.clear)
                .padding(.horizontal, isCode ? 4 : 0)
                .padding(.vertical, isCode ? 2 : 0)
                .cornerRadius(isCode ? 4 : 0)
        }
    }
    
    private var codeBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray6).opacity(0.3)
            : Color(.systemGray6).opacity(0.5)
    }
    
    private var codeInlineBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.3)
            : Color(.systemGray5).opacity(0.5)
    }
}

// MARK: - Markdown Renderer (Fallback)
struct MarkdownRenderer: View {
    let content: String
    let configuration: HelpCenterConfiguration
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Basic markdown parsing - you can enhance this or use a markdown library
            let paragraphs = content.components(separatedBy: "\n\n")
            
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { index, paragraph in
                if paragraph.hasPrefix("# ") {
                    Text(String(paragraph.dropFirst(2)))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(configuration.theme.textColor)
                        .padding(.bottom, 8)
                } else if paragraph.hasPrefix("## ") {
                    Text(String(paragraph.dropFirst(3)))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(configuration.theme.textColor)
                        .padding(.bottom, 6)
                } else if paragraph.hasPrefix("### ") {
                    Text(String(paragraph.dropFirst(4)))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(configuration.theme.textColor)
                        .padding(.bottom, 4)
                } else if paragraph.hasPrefix("> ") {
                    HStack(alignment: .top, spacing: 16) {
                        Rectangle()
                            .fill(configuration.theme.primaryColor)
                            .frame(width: 4)
                        
                        Text(String(paragraph.dropFirst(2)))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(configuration.theme.textColor)
                            .italic()
                            .lineLimit(nil)
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(configuration.theme.primaryColor.opacity(0.05))
                    )
                } else if paragraph.hasPrefix("```") {
                    let codeContent = paragraph
                        .replacingOccurrences(of: "```", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    Text(codeContent)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(configuration.theme.textColor)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(codeBackgroundColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(configuration.theme.borderColor.opacity(0.3), lineWidth: 1)
                                )
                        )
                } else if !paragraph.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(paragraph)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(configuration.theme.textColor)
                        .lineLimit(nil)
                        .padding(.bottom, 4)
                }
            }
        }
    }
    
    private var codeBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray6).opacity(0.3)
            : Color(.systemGray6).opacity(0.5)
    }
}
