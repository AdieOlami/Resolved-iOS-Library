//
//  LexicalContentRenderer.swift
//  ResolvedLibrary
//
//  Created by Olami on 2025-07-14.
//

import SwiftUI
import Foundation

// MARK: - Enhanced Lexical Content Renderer with Full Plugin Support

struct LexicalContentRenderer: View {
    let content: String
    let configuration: HelpCenterConfiguration
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let data = content.data(using: .utf8),
               let lexicalData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                LexicalNodeRenderer(
                    node: lexicalData,
                    configuration: configuration
                )
            } else {
                Text(content)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(configuration.theme.textColor)
                    .lineLimit(nil)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(fallbackBackgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(configuration.theme.borderColor.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
        }
    }
    
    private var fallbackBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray6).opacity(0.2)
            : Color(.systemGray6).opacity(0.3)
    }
}

// MARK: - Enhanced Lexical Node Renderer
struct LexicalNodeRenderer: View {
    let node: [String: Any]
    let configuration: HelpCenterConfiguration
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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

// MARK: - Enhanced Lexical Element Renderer with Plugin Support
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
                case "link":
                    renderLink()
                case "hashtag":
                    renderHashtag()
                case "table":
                    renderTable()
                case "horizontalrule":
                    renderHorizontalRule()
                case "check-list":
                    renderCheckList()
                default:
                    renderParagraph()
                }
            } else {
                renderParagraph()
            }
        }
    }
    
    @ViewBuilder
    private func renderParagraph() -> some View {
        if let children = element["children"] as? [[String: Any]] {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                        renderTextNode(child)
                    }
                    Spacer()
                }
            }
            .padding(.bottom, 12)
        }
    }
    
    @ViewBuilder
    private func renderHeading() -> some View {
        if let children = element["children"] as? [[String: Any]],
           let tag = element["tag"] as? String {
            let fontSize: CGFloat = {
                switch tag {
                case "h1": return 26
                case "h2": return 22
                case "h3": return 20
                case "h4": return 18
                case "h5": return 16
                case "h6": return 15
                default: return 20
                }
            }()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                        renderTextNode(child, fontSize: fontSize, weight: .bold)
                    }
                    Spacer()
                }
            }
            .padding(.vertical, 12)
        }
    }
    
    @ViewBuilder
    private func renderList() -> some View {
        if let children = element["children"] as? [[String: Any]] {
            let listType = element["listType"] as? String ?? "bullet"
            let startNumber = element["start"] as? Int ?? 1
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                    if let listItemChildren = child["children"] as? [[String: Any]] {
                        HStack(alignment: .top, spacing: 12) {
                            // List marker
                            VStack {
                                if listType == "number" {
                                    Text("\(startNumber + index).")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(configuration.theme.textColor)
                                        .frame(minWidth: 20, alignment: .trailing)
                                } else {
                                    ZStack {
                                        Circle()
                                            .fill(configuration.theme.primaryColor)
                                            .frame(width: 6, height: 6)
                                    }
                                    .padding(.top, 8)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(Array(listItemChildren.enumerated()), id: \.offset) { childIndex, listChild in
                                    renderTextNode(listChild)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            .padding(.leading, 20)
            .padding(.bottom, 12)
        }
    }
    
    @ViewBuilder
    private func renderCheckList() -> some View {
        if let children = element["children"] as? [[String: Any]] {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                    if let listItemChildren = child["children"] as? [[String: Any]] {
                        let isChecked = child["checked"] as? Bool ?? false
                        
                        HStack(alignment: .top, spacing: 12) {
                            // Checkbox
                            Button(action: {
                                // Handle checkbox toggle if needed
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(configuration.theme.primaryColor, lineWidth: 2)
                                        .frame(width: 18, height: 18)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(isChecked ? configuration.theme.primaryColor : Color.clear)
                                        )
                                    
                                    if isChecked {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, 2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(Array(listItemChildren.enumerated()), id: \.offset) { childIndex, listChild in
                                    renderTextNode(listChild, strikethrough: isChecked)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            .padding(.leading, 20)
            .padding(.bottom, 12)
        }
    }
    
    @ViewBuilder
    private func renderQuote() -> some View {
        if let children = element["children"] as? [[String: Any]] {
            HStack(alignment: .top, spacing: 20) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(configuration.theme.primaryColor)
                    .frame(width: 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                        renderTextNode(child, style: .callout)
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(quoteBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(configuration.theme.primaryColor.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.bottom, 16)
        }
    }
    
    @ViewBuilder
    private func renderCodeBlock() -> some View {
        if let children = element["children"] as? [[String: Any]] {
            let language = element["language"] as? String ?? ""
            
            VStack(alignment: .leading, spacing: 0) {
                // Language header if specified
                if !language.isEmpty {
                    HStack {
                        Text(language.uppercased())
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(configuration.theme.textColor.opacity(0.7))
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                        renderTextNode(child, fontSize: 14, fontDesign: .monospaced)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(codeBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(configuration.theme.borderColor.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.bottom, 16)
        }
    }
    
    @ViewBuilder
    private func renderLink() -> some View {
        if let children = element["children"] as? [[String: Any]],
           let url = element["url"] as? String {
            
            HStack(spacing: 0) {
                ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                    if let text = child["text"] as? String {
                        Button(action: {
                            if let url = URL(string: url) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text(text)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(configuration.theme.primaryColor)
                                .underline()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func renderHashtag() -> some View {
        if let children = element["children"] as? [[String: Any]] {
            HStack(spacing: 0) {
                ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                    if let text = child["text"] as? String {
                        Button(action: {
                            // Handle hashtag tap
                        }) {
                            Text(text)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(configuration.theme.primaryColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(configuration.theme.primaryColor.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(configuration.theme.primaryColor.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func renderTable() -> some View {
        if let children = element["children"] as? [[String: Any]] {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(children.enumerated()), id: \.offset) { rowIndex, row in
                    if let rowChildren = row["children"] as? [[String: Any]] {
                        HStack(spacing: 0) {
                            ForEach(Array(rowChildren.enumerated()), id: \.offset) { cellIndex, cell in
                                VStack(alignment: .leading, spacing: 4) {
                                    if let cellChildren = cell["children"] as? [[String: Any]] {
                                        ForEach(Array(cellChildren.enumerated()), id: \.offset) { childIndex, cellChild in
                                            renderTextNode(cellChild, weight: rowIndex == 0 ? .bold : .medium)
                                        }
                                    }
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    Rectangle()
                                        .fill(rowIndex == 0 ? configuration.theme.primaryColor.opacity(0.1) : Color.clear)
                                )
                                .overlay(
                                    Rectangle()
                                        .stroke(configuration.theme.borderColor.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(tableBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(configuration.theme.borderColor.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.bottom, 16)
        }
    }
    
    @ViewBuilder
    private func renderHorizontalRule() -> some View {
        Rectangle()
            .fill(configuration.theme.borderColor.opacity(0.4))
            .frame(height: 2)
            .padding(.vertical, 20)
    }
    
    @ViewBuilder
    private func renderTextNode(
        _ textNode: [String: Any],
        fontSize: CGFloat = 16,
        weight: Font.Weight = .medium,
        style: Font.TextStyle = .body,
        fontDesign: Font.Design = .default,
        strikethrough: Bool = false
    ) -> some View {
        if let text = textNode["text"] as? String {
            let format = textNode["format"] as? Int ?? 0
            let isBold = (format & 1) != 0
            let isItalic = (format & 2) != 0
            let isUnderline = (format & 8) != 0
            let isCode = (format & 16) != 0
            let isStrikethrough = (format & 4) != 0 || strikethrough
            
            Text(text)
                .font(.system(size: fontSize, weight: isBold ? .bold : weight, design: isCode ? .monospaced : fontDesign))
                .foregroundColor(isCode ? configuration.theme.primaryColor : configuration.theme.textColor)
                .italic(isItalic)
                .underline(isUnderline)
                .strikethrough(isStrikethrough)
                .background(isCode ? codeInlineBackgroundColor : Color.clear)
                .padding(.horizontal, isCode ? 6 : 0)
                .padding(.vertical, isCode ? 3 : 0)
                .cornerRadius(isCode ? 6 : 0)
        }
    }
    
    // MARK: - Color Helpers
    private var quoteBackgroundColor: Color {
        configuration.theme.primaryColor.opacity(0.08)
    }
    
    private var codeBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray6).opacity(0.4)
            : Color(.systemGray6).opacity(0.6)
    }
    
    private var codeInlineBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.4)
            : Color(.systemGray5).opacity(0.6)
    }
    
    private var tableBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray6).opacity(0.2)
            : Color(.systemGray6).opacity(0.3)
    }
}
