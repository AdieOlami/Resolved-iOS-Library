//
//  File.swift
//  ResolvedLibrary
//
//  Created by Olami on 2025-07-15.
//

import Foundation
import SwiftUI

// MARK: - Markdown Elements
enum MarkdownElement {
    case heading(text: String, level: Int)
    case paragraph(attributedText: AttributedString)
    case listItem(attributedText: AttributedString, level: Int)
    case orderedListItem(attributedText: AttributedString, number: Int, level: Int)
    case checkListItem(attributedText: AttributedString, checked: Bool, level: Int)
    case quote(attributedText: AttributedString, level: Int)
    case codeBlock(content: String, language: String)
    case table(headers: [String], rows: [[String]])
    case horizontalRule
    case lineBreak
}

// MARK: - Inline Markdown Processor
struct InlineMarkdownProcessor {
    private let configuration: HelpCenterConfiguration
    
    init(configuration: HelpCenterConfiguration) {
        self.configuration = configuration
    }
    
    func processInlineMarkdown(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        // Process in order of precedence to avoid conflicts
        processInlineCode(&attributedString)
        processEmphasis(&attributedString)
        processStrikethrough(&attributedString)
        processLinks(&attributedString)
        processHashtags(&attributedString)
        processMentions(&attributedString)
        
        return attributedString
    }
    
    private func processInlineCode(_ attributedString: inout AttributedString) {
        let pattern = "`([^`]+)`"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
        
        let string = String(attributedString.characters)
        let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        
        // Process matches in reverse order to maintain string indices
        for match in matches.reversed() {
            guard match.numberOfRanges >= 2,
                  let range = Range(match.range, in: string),
                  let codeRange = Range(match.range(at: 1), in: string) else { continue }
            
            let codeText = String(string[codeRange])
            
            let startIndex = attributedString.index(attributedString.startIndex, offsetByCharacters: range.lowerBound.utf16Offset(in: string))
            let endIndex = attributedString.index(attributedString.startIndex, offsetByCharacters: range.upperBound.utf16Offset(in: string))
            
            attributedString.replaceSubrange(startIndex..<endIndex, with: AttributedString(codeText))
            let codeEndIndex = attributedString.index(startIndex, offsetByCharacters: codeText.count)
            attributedString[startIndex..<codeEndIndex].font = .system(size: 14, weight: .medium, design: .monospaced)
            attributedString[startIndex..<codeEndIndex].backgroundColor = codeBackgroundColor
        }
    }
    
    private func processEmphasis(_ attributedString: inout AttributedString) {
        // Bold with **text** or __text__
        processPattern("\\*\\*([^*]+)\\*\\*", in: &attributedString) { content, match in
            var newString = AttributedString(content)
            newString.font = .system(size: 16, weight: .bold)
            return newString
        }
        
        processPattern("__([^_]+)__", in: &attributedString) { content, match in
            var newString = AttributedString(content)
            newString.font = .system(size: 16, weight: .bold)
            return newString
        }
        
        // Italic with *text* or _text_ (but not if it's part of bold)
        processPattern("(?<!\\*)\\*([^*]+)\\*(?!\\*)", in: &attributedString) { content, match in
            var newString = AttributedString(content)
            newString.font = .system(size: 16, weight: .medium).italic()
            return newString
        }
        
        processPattern("(?<!_)_([^_]+)_(?!_)", in: &attributedString) { content, match in
            var newString = AttributedString(content)
            newString.font = .system(size: 16, weight: .medium).italic()
            return newString
        }
    }
    
    private func processStrikethrough(_ attributedString: inout AttributedString) {
        processPattern("~~([^~]+)~~", in: &attributedString) { content, match in
            var newString = AttributedString(content)
            newString.strikethroughStyle = .single
            return newString
        }
    }
    
    private func processLinks(_ attributedString: inout AttributedString) {
        // [text](url) format - need to handle both capture groups
        processLinkPattern("\\[([^\\]]+)\\]\\(([^)]+)\\)", in: &attributedString) { linkText, url in
            var newString = AttributedString(linkText)
            newString.foregroundColor = configuration.theme.primaryColor
            newString.underlineStyle = .single
            return newString
        }
        
        // Auto-link URLs
        processPattern("https?://[^\\s]+", in: &attributedString) { content, match in
            var newString = AttributedString(content)
            newString.foregroundColor = configuration.theme.primaryColor
            newString.underlineStyle = .single
            return newString
        }
    }
    
    private func processHashtags(_ attributedString: inout AttributedString) {
        processPattern("#([a-zA-Z0-9_]+)", in: &attributedString) { content, match in
            var newString = AttributedString("#\(content)")
            newString.foregroundColor = configuration.theme.primaryColor
            newString.font = .system(size: 16, weight: .semibold)
            return newString
        }
    }
    
    private func processMentions(_ attributedString: inout AttributedString) {
        processPattern("@([a-zA-Z0-9_]+)", in: &attributedString) { content, match in
            var newString = AttributedString("@\(content)")
            newString.foregroundColor = configuration.theme.primaryColor
            newString.font = .system(size: 16, weight: .semibold)
            return newString
        }
    }
    
    private func processPattern(_ pattern: String, in attributedString: inout AttributedString, transform: (String, NSTextCheckingResult) -> AttributedString) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
        
        let string = String(attributedString.characters)
        let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        
        for match in matches.reversed() {
            guard match.numberOfRanges >= 2,
                  let fullRange = Range(match.range, in: string),
                  let contentRange = Range(match.range(at: 1), in: string) else { continue }
            
            let content = String(string[contentRange])
            
            let startIndex = attributedString.index(attributedString.startIndex, offsetByCharacters: fullRange.lowerBound.utf16Offset(in: string))
            let endIndex = attributedString.index(attributedString.startIndex, offsetByCharacters: fullRange.upperBound.utf16Offset(in: string))
            
            let newAttributedString = transform(content, match)
            attributedString.replaceSubrange(startIndex..<endIndex, with: newAttributedString)
        }
    }
    
    private func processLinkPattern(_ pattern: String, in attributedString: inout AttributedString, transform: (String, String) -> AttributedString) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
        
        let string = String(attributedString.characters)
        let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        
        for match in matches.reversed() {
            guard match.numberOfRanges >= 3,
                  let fullRange = Range(match.range, in: string),
                  let textRange = Range(match.range(at: 1), in: string),
                  let urlRange = Range(match.range(at: 2), in: string) else { continue }
            
            let linkText = String(string[textRange])
            let url = String(string[urlRange])
            
            let startIndex = attributedString.index(attributedString.startIndex, offsetByCharacters: fullRange.lowerBound.utf16Offset(in: string))
            let endIndex = attributedString.index(attributedString.startIndex, offsetByCharacters: fullRange.upperBound.utf16Offset(in: string))
            
            let newAttributedString = transform(linkText, url)
            attributedString.replaceSubrange(startIndex..<endIndex, with: newAttributedString)
        }
    }
    
    private var codeBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.6)
            : Color(.systemGray6).opacity(0.8)
    }
}

// MARK: - Main Markdown Renderer
struct MarkdownRenderer: View {
    let content: String
    let configuration: HelpCenterConfiguration
    
    private let processor: InlineMarkdownProcessor
    
    init(content: String, configuration: HelpCenterConfiguration) {
        self.content = content
        self.configuration = configuration
        self.processor = InlineMarkdownProcessor(configuration: configuration)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            let processedElements = parseMarkdownElements()
            
            ForEach(Array(processedElements.enumerated()), id: \.offset) { index, element in
                renderMarkdownElement(element)
            }
        }
        .padding(.horizontal, 4)
    }
    
    private func parseMarkdownElements() -> [MarkdownElement] {
        let lines = content.components(separatedBy: .newlines)
        var elements: [MarkdownElement] = []
        var i = 0
        
        while i < lines.count {
            let line = lines[i]
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines but add line breaks for double newlines
            if trimmedLine.isEmpty {
                if i > 0 && i < lines.count - 1 {
                    elements.append(.lineBreak)
                }
                i += 1
                continue
            }
            
            // Handle code blocks
            if trimmedLine.hasPrefix("```") {
                let language = String(trimmedLine.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                var codeContent = ""
                i += 1
                
                while i < lines.count && !lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                    codeContent += lines[i] + "\n"
                    i += 1
                }
                
                elements.append(.codeBlock(content: codeContent.trimmingCharacters(in: .newlines), language: language))
                i += 1
                continue
            }
            
            // Handle tables
            if trimmedLine.contains("|") && !trimmedLine.isEmpty {
                var tableLines: [String] = []
                var currentIndex = i
                
                while currentIndex < lines.count {
                    let currentLine = lines[currentIndex].trimmingCharacters(in: .whitespaces)
                    if currentLine.contains("|") && !currentLine.isEmpty {
                        tableLines.append(currentLine)
                        currentIndex += 1
                    } else {
                        break
                    }
                }
                
                if tableLines.count >= 2 {
                    let (headers, rows) = parseTable(tableLines)
                    elements.append(.table(headers: headers, rows: rows))
                    i = currentIndex
                    continue
                }
            }
            
            // Handle horizontal rules
            if trimmedLine == "---" || trimmedLine == "***" || trimmedLine == "___" {
                elements.append(.horizontalRule)
                i += 1
                continue
            }
            
            // Handle headings
            if let headingMatch = parseHeading(line) {
                elements.append(.heading(text: headingMatch.text, level: headingMatch.level))
                i += 1
                continue
            }
            
            // Handle lists
            if let listMatch = parseList(line) {
                switch listMatch {
                case .unordered(let text, let level):
                    elements.append(.listItem(attributedText: processor.processInlineMarkdown(text), level: level))
                case .ordered(let text, let number, let level):
                    elements.append(.orderedListItem(attributedText: processor.processInlineMarkdown(text), number: number, level: level))
                case .checkbox(let text, let checked, let level):
                    elements.append(.checkListItem(attributedText: processor.processInlineMarkdown(text), checked: checked, level: level))
                }
                i += 1
                continue
            }
            
            // Handle quotes
            if let quoteMatch = parseQuote(line) {
                elements.append(.quote(attributedText: processor.processInlineMarkdown(quoteMatch.text), level: quoteMatch.level))
                i += 1
                continue
            }
            
            // Handle paragraphs
            if !trimmedLine.isEmpty {
                elements.append(.paragraph(attributedText: processor.processInlineMarkdown(line)))
            }
            
            i += 1
        }
        
        return elements
    }
    
    private func parseHeading(_ line: String) -> (text: String, level: Int)? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        
        if trimmed.hasPrefix("# ") {
            return (String(trimmed.dropFirst(2)), 1)
        } else if trimmed.hasPrefix("## ") {
            return (String(trimmed.dropFirst(3)), 2)
        } else if trimmed.hasPrefix("### ") {
            return (String(trimmed.dropFirst(4)), 3)
        } else if trimmed.hasPrefix("#### ") {
            return (String(trimmed.dropFirst(5)), 4)
        } else if trimmed.hasPrefix("##### ") {
            return (String(trimmed.dropFirst(6)), 5)
        } else if trimmed.hasPrefix("###### ") {
            return (String(trimmed.dropFirst(7)), 6)
        }
        
        return nil
    }
    
    private enum ListType {
        case unordered(text: String, level: Int)
        case ordered(text: String, number: Int, level: Int)
        case checkbox(text: String, checked: Bool, level: Int)
    }
    
    private func parseList(_ line: String) -> ListType? {
        let leadingSpaces = line.prefix(while: { $0 == " " }).count
        let level = leadingSpaces / 2
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        
        // Checkbox items
        if trimmed.hasPrefix("- [ ] ") {
            return .checkbox(text: String(trimmed.dropFirst(6)), checked: false, level: level)
        } else if trimmed.hasPrefix("- [x] ") || trimmed.hasPrefix("- [X] ") {
            return .checkbox(text: String(trimmed.dropFirst(6)), checked: true, level: level)
        }
        
        // Unordered list
        if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") || trimmed.hasPrefix("+ ") {
            return .unordered(text: String(trimmed.dropFirst(2)), level: level)
        }
        
        // Ordered list
        let orderedPattern = "^(\\d+)\\. (.+)$"
        guard let regex = try? NSRegularExpression(pattern: orderedPattern, options: []) else { return nil }
        let range = NSRange(location: 0, length: trimmed.count)
        
        if let match = regex.firstMatch(in: trimmed, options: [], range: range),
           match.numberOfRanges >= 3,
           let numberRange = Range(match.range(at: 1), in: trimmed),
           let textRange = Range(match.range(at: 2), in: trimmed) {
            let number = Int(String(trimmed[numberRange])) ?? 1
            let text = String(trimmed[textRange])
            return .ordered(text: text, number: number, level: level)
        }
        
        return nil
    }
    
    private func parseQuote(_ line: String) -> (text: String, level: Int)? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        var level = 0
        var remaining = trimmed
        
        while remaining.hasPrefix("> ") {
            level += 1
            remaining = String(remaining.dropFirst(2))
        }
        
        if level > 0 {
            return (remaining, level)
        }
        
        return nil
    }
    
    private func parseTable(_ lines: [String]) -> (headers: [String], rows: [[String]]) {
        var headers: [String] = []
        var rows: [[String]] = []
        
        for (index, line) in lines.enumerated() {
            // Skip separator lines
            if line.contains("---") || line.contains("===") {
                continue
            }
            
            let cells = line.components(separatedBy: "|")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            
            if index == 0 {
                headers = cells
            } else {
                rows.append(cells)
            }
        }
        
        return (headers, rows)
    }
    
    @ViewBuilder
    private func renderMarkdownElement(_ element: MarkdownElement) -> some View {
        switch element {
        case .heading(let text, let level):
            renderHeading(text: text, level: level)
        case .paragraph(let attributedText):
            renderParagraph(attributedText: attributedText)
        case .listItem(let attributedText, let level):
            renderListItem(attributedText: attributedText, level: level)
        case .orderedListItem(let attributedText, let number, let level):
            renderOrderedListItem(attributedText: attributedText, number: number, level: level)
        case .checkListItem(let attributedText, let checked, let level):
            renderCheckListItem(attributedText: attributedText, checked: checked, level: level)
        case .quote(let attributedText, let level):
            renderQuote(attributedText: attributedText, level: level)
        case .codeBlock(let content, let language):
            renderCodeBlock(content: content, language: language)
        case .table(let headers, let rows):
            renderTable(headers: headers, rows: rows)
        case .horizontalRule:
            renderHorizontalRule()
        case .lineBreak:
            Spacer().frame(height: 8)
        }
    }
    
    @ViewBuilder
    private func renderHeading(text: String, level: Int) -> some View {
        let fontSize: CGFloat = {
            switch level {
            case 1: return 28
            case 2: return 24
            case 3: return 20
            case 4: return 18
            case 5: return 16
            default: return 14
            }
        }()
        
        let weight: Font.Weight = level <= 2 ? .bold : .semibold
        
        Text(text)
            .font(.system(size: fontSize, weight: weight))
            .foregroundColor(configuration.theme.textColor)
            .padding(.vertical, level <= 2 ? 6 : 4)
    }
    
    @ViewBuilder
    private func renderParagraph(attributedText: AttributedString) -> some View {
        Text(attributedText)
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(configuration.theme.textColor)
            .lineSpacing(2)
            .padding(.vertical, 2)
    }
    
    @ViewBuilder
    private func renderListItem(attributedText: AttributedString, level: Int) -> some View {
        let indent = CGFloat(level * 20)
        let bulletColor = configuration.theme.primaryColor
        
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(bulletColor)
                .frame(width: 6, height: 6)
                .padding(.top, 8)
            
            Text(attributedText)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(configuration.theme.textColor)
                .lineSpacing(2)
            
            Spacer()
        }
        .padding(.leading, indent + 16)
    }
    
    @ViewBuilder
    private func renderOrderedListItem(attributedText: AttributedString, number: Int, level: Int) -> some View {
        let indent = CGFloat(level * 20)
        
        HStack(alignment: .top, spacing: 12) {
            Text("\(number).")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(configuration.theme.primaryColor)
                .frame(minWidth: 20, alignment: .trailing)
            
            Text(attributedText)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(configuration.theme.textColor)
                .lineSpacing(2)
            
            Spacer()
        }
        .padding(.leading, indent + 16)
    }
    
    @ViewBuilder
    private func renderCheckListItem(attributedText: AttributedString, checked: Bool, level: Int) -> some View {
        let indent = CGFloat(level * 20)
        
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(configuration.theme.primaryColor, lineWidth: 2)
                    .frame(width: 18, height: 18)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(checked ? configuration.theme.primaryColor : Color.clear)
                    )
                
                if checked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 2)
            
            Text(attributedText)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(configuration.theme.textColor)
                .lineSpacing(2)
            
            Spacer()
        }
        .padding(.leading, indent + 16)
    }
    
    @ViewBuilder
    private func renderQuote(attributedText: AttributedString, level: Int) -> some View {
        let borderColor = configuration.theme.primaryColor
        let backgroundColor = configuration.theme.primaryColor.opacity(0.08)
        
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                ForEach(0..<level, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(borderColor)
                        .frame(width: 4)
                }
            }
            
            Text(attributedText)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(configuration.theme.textColor)
                .italic()
                .lineSpacing(2)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    private func renderCodeBlock(content: String, language: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if !language.isEmpty {
                HStack {
                    Text(language.uppercased())
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(configuration.theme.textColor.opacity(0.7))
                    Spacer()
                    
                    Button(action: {
                        UIPasteboard.general.string = content
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 12))
                            .foregroundColor(configuration.theme.textColor.opacity(0.7))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                Text(content)
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundColor(configuration.theme.textColor)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(codeBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(configuration.theme.borderColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    private func renderTable(headers: [String], rows: [[String]]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            HStack(spacing: 0) {
                ForEach(Array(headers.enumerated()), id: \.offset) { index, header in
                    Text(header)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(configuration.theme.textColor)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(configuration.theme.primaryColor.opacity(0.1))
                        .overlay(
                            Rectangle()
                                .stroke(configuration.theme.borderColor.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            
            // Data rows
            ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, row in
                HStack(spacing: 0) {
                    ForEach(Array(row.enumerated()), id: \.offset) { cellIndex, cell in
                        Text(cell)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(configuration.theme.textColor)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                rowIndex % 2 == 0 ? Color.clear : configuration.theme.primaryColor.opacity(0.05)
                            )
                            .overlay(
                                Rectangle()
                                    .stroke(configuration.theme.borderColor.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(tableBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(configuration.theme.borderColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    private func renderHorizontalRule() -> some View {
        Rectangle()
            .fill(configuration.theme.borderColor.opacity(0.4))
            .frame(height: 1)
            .padding(.vertical, 16)
    }
    
    // MARK: - Color Helpers
    private var codeBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray6).opacity(0.4)
            : Color(.systemGray6).opacity(0.8)
    }
    
    private var tableBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray6).opacity(0.2)
            : Color(.systemGray6).opacity(0.4)
    }
}
