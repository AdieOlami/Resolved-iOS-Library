//
//  KnowledgeBaseView.swift
//  ResolvedLibrary
//
//  Created by Olami on 2025-07-13.
//

import SwiftUI
@_exported import Resolved

// MARK: - Knowledge Base View

struct KnowledgeBaseView: View {
    let configuration: HelpCenterConfiguration
    let onBack: () -> Void
    
    @StateObject private var sdkManager = ResolvedSDKManager()
    @State private var searchQuery = ""
    @State private var isSearching = false
    @State private var selectedArticleId: String?
    @State private var expandedCollections: Set<String> = []
    @State private var showingArticleDetail = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(spacing: 0) {
                // Sidebar Header
                sidebarHeader
                
                // Sidebar Content
                ScrollView {
                    LazyVStack(spacing: 8) {
                        if isSearching {
                            searchResults
                        } else {
                            collectionsView
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .refreshable {
                    await refreshKnowledgeBase()
                }
            }
            .frame(width: 400)
            .background(sidebarBackgroundColor)
            .overlay(
                Rectangle()
                    .fill(configuration.theme.borderColor.opacity(0.3))
                    .frame(width: 1),
                alignment: .trailing
            )
            
            // Main Content
            Group {
                if let selectedArticleId = selectedArticleId {
                    ArticleDetailView(
                        articleId: selectedArticleId,
                        configuration: configuration,
                        sdkManager: sdkManager
                    )
                } else {
                    emptyMainContent
                }
            }
            .frame(maxWidth: .infinity)
            .background(configuration.theme.backgroundColor)
        }
        .onAppear {
            sdkManager.initialize(with: configuration)
        }
    }
    
    // MARK: - Sidebar Header
    private var sidebarHeader: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Knowledge Base")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(configuration.theme.textColor)
                
                Spacer()
                
                if !sdkManager.collections.isEmpty {
                    Text("\(sdkManager.collections.count) Collections")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(configuration.theme.secondaryColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(configuration.theme.primaryColor.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(configuration.theme.primaryColor.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
            }
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(configuration.theme.secondaryColor)
                    .font(.system(size: 16))
                
                TextField("Search articles and guides...", text: $searchQuery)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(configuration.theme.textColor)
                    .onSubmit {
                        performSearch()
                    }
                    .onChange(of: searchQuery) { newValue in
                        if newValue.isEmpty {
                            isSearching = false
                        }
                    }
                
                if !searchQuery.isEmpty {
                    Button(action: {
                        searchQuery = ""
                        isSearching = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(configuration.theme.secondaryColor)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(searchBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(configuration.theme.borderColor.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .padding(20)
        .background(sidebarHeaderBackgroundColor)
        .overlay(
            Rectangle()
                .fill(configuration.theme.borderColor.opacity(0.3))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Collections View
    private var collectionsView: some View {
        Group {
            if sdkManager.isLoadingCollections {
                LoadingView(message: "Loading collections...")
                    .padding(40)
            } else if let error = sdkManager.collectionError {
                ErrorView(message: error, onRetry: {
                    sdkManager.loadCollections()
                })
                .padding(16)
            } else if sdkManager.collections.isEmpty {
                EmptyStateView(
                    title: "No collections available",
                    message: "No knowledge base collections have been created yet.",
                    configuration: configuration
                )
                .padding(40)
            } else {
                ForEach(sdkManager.collections, id: \.id) { collection in
                    CollectionItemView(
                        collection: collection,
                        configuration: configuration,
                        sdkManager: sdkManager,
                        expandedCollections: $expandedCollections,
                        selectedArticleId: $selectedArticleId,
                        level: 0
                    )
                }
            }
        }
    }
    
    // MARK: - Search Results
    private var searchResults: some View {
        Group {
            if sdkManager.isLoadingArticles {
                LoadingView(message: "Searching...")
                    .padding(40)
            } else if let error = sdkManager.articleError {
                ErrorView(message: error, onRetry: {
                    performSearch()
                })
                .padding(16)
            } else if sdkManager.articles.isEmpty {
                EmptyStateView(
                    title: "No results found",
                    message: "No articles match \"\(searchQuery)\". Try adjusting your search terms.",
                    configuration: configuration
                )
                .padding(40)
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Search Results (\(sdkManager.articles.count))")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(configuration.theme.textColor)
                        .padding(.horizontal, 8)
                    
                    ForEach(sdkManager.articles, id: \.id) { article in
                        SearchResultItemView(
                            article: article,
                            configuration: configuration,
                            isSelected: selectedArticleId == article.id,
                            onSelect: {
                                selectedArticleId = article.id
                                sdkManager.loadArticle(id: article.id)
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Empty Main Content
    private var emptyMainContent: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray5).opacity(0.8))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "book.fill")
                    .font(.system(size: 32))
                    .foregroundColor(configuration.theme.secondaryColor)
            }
            
            VStack(spacing: 8) {
                Text("Select an article")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(configuration.theme.textColor)
                
                Text("Choose an article from the sidebar to view its content, or use the search function to find specific topics.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(configuration.theme.secondaryColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(configuration.theme.backgroundColor)
    }
    
    // MARK: - Helper Methods
    
    @MainActor
    private func refreshKnowledgeBase() async {
        if isSearching {
            // Refresh search results
            await performSearchRefresh()
        } else {
            // Refresh collections
            sdkManager.loadCollections()
            
            // Wait for completion
            while sdkManager.isLoadingCollections {
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        }
    }

    @MainActor
    private func performSearchRefresh() async {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        sdkManager.searchArticles(query: searchQuery)
        
        while sdkManager.isLoadingArticles {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }
    
    private func performSearch() {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            isSearching = false
            return
        }
        
        isSearching = true
        sdkManager.searchArticles(query: searchQuery)
    }
    
    // MARK: - Computed Properties
    private var sidebarBackgroundColor: Color {
        configuration.theme.mode == .dark 
            ? Color(.systemGray6).opacity(0.3) 
            : Color.white.opacity(0.7)
    }
    
    private var sidebarHeaderBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.3)
            : Color(.systemGray6).opacity(0.5)
    }
    
    private var searchBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.3)
            : Color.white.opacity(0.9)
    }
}

// MARK: - Collection Item View
struct CollectionItemView: View {
    let collection: Collection
    let configuration: HelpCenterConfiguration
    @ObservedObject var sdkManager: ResolvedSDKManager
    @Binding var expandedCollections: Set<String>
    @Binding var selectedArticleId: String?
    let level: Int
    
    private var isExpanded: Bool {
        expandedCollections.contains(collection.id)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Collection Header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isExpanded {
                        expandedCollections.remove(collection.id)
                    } else {
                        expandedCollections.insert(collection.id)
                        if collection.articles?.isEmpty == true {
                            sdkManager.loadArticles(for: collection.id)
                        }
                    }
                }
            }) {
                HStack {
                    HStack(spacing: 12) {
                        // Icon
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(iconBackgroundColor)
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: level == 0 ? "folder.fill" : "doc.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(iconColor)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(collection.name)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(configuration.theme.textColor)
                                .multilineTextAlignment(.leading)
                            
                            if let articlesCount = collection.articles?.count, articlesCount > 0 {
                                Text("\(articlesCount) Article\(articlesCount == 1 ? "" : "s")")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(configuration.theme.secondaryColor)
                                    .textCase(.uppercase)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(configuration.theme.secondaryColor)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(collectionBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(collectionBorderColor, lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Articles List
            if isExpanded {
                LazyVStack(spacing: 4) {
                    if let articles = collection.articles, !articles.isEmpty {
                        ForEach(articles, id: \.id) { article in
                            ArticleItemView(
                                article: article,
                                configuration: configuration,
                                isSelected: selectedArticleId == article.id,
                                onSelect: {
                                    selectedArticleId = article.id
                                    sdkManager.loadArticle(id: article.id)
                                }
                            )
                        }
                    } else if sdkManager.isLoadingArticles {
                        LoadingView(message: "Loading articles...")
                            .padding(20)
                    }
                    
                    // Sub-collections
                    if let subCollections = collection.subCollections {
                        ForEach(subCollections, id: \.id) { subCollection in
                            CollectionItemView(
                                collection: subCollection,
                                configuration: configuration,
                                sdkManager: sdkManager,
                                expandedCollections: $expandedCollections,
                                selectedArticleId: $selectedArticleId,
                                level: level + 1
                            )
                        }
                    }
                }
                .padding(.leading, 16)
                .padding(.top, 8)
            }
        }
        .padding(.bottom, 8)
    }
    
    private var iconBackgroundColor: Color {
        let colors = [
            configuration.theme.primaryColor,
            Color.green,
            Color.orange,
            Color.red
        ]
        return colors[min(level, colors.count - 1)].opacity(0.15)
    }
    
    private var iconColor: Color {
        let colors = [
            configuration.theme.primaryColor,
            Color.green,
            Color.orange,
            Color.red
        ]
        return colors[min(level, colors.count - 1)]
    }
    
    private var collectionBackgroundColor: Color {
        if isExpanded {
            return configuration.theme.primaryColor.opacity(0.05)
        }
        return configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.3)
            : Color.white.opacity(0.6)
    }
    
    private var collectionBorderColor: Color {
        isExpanded 
            ? configuration.theme.primaryColor.opacity(0.3)
            : Color.clear
    }
}

// MARK: - Article Item View
struct ArticleItemView: View {
    let article: Article
    let configuration: HelpCenterConfiguration
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconBackgroundColor)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(configuration.theme.primaryColor)
                }
                
                Text(article.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(configuration.theme.textColor)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(articleBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(articleBorderColor, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconBackgroundColor: Color {
        configuration.theme.primaryColor.opacity(0.1)
    }
    
    private var articleBackgroundColor: Color {
        if isSelected {
            return configuration.theme.primaryColor.opacity(0.1)
        }
        return configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.2)
            : Color.white.opacity(0.8)
    }
    
    private var articleBorderColor: Color {
        isSelected 
            ? configuration.theme.primaryColor.opacity(0.4)
            : Color.clear
    }
}

// MARK: - Search Result Item View
struct SearchResultItemView: View {
    let article: Article
    let configuration: HelpCenterConfiguration
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(configuration.theme.primaryColor.opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(configuration.theme.primaryColor)
                    }
                    
                    Text(article.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(configuration.theme.textColor)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Spacer()
                }
                
                if let description = article.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(configuration.theme.secondaryColor)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(searchResultBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(searchResultBorderColor, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var searchResultBackgroundColor: Color {
        if isSelected {
            return configuration.theme.primaryColor.opacity(0.1)
        }
        return configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.3)
            : Color.white.opacity(0.8)
    }
    
    private var searchResultBorderColor: Color {
        isSelected 
            ? configuration.theme.primaryColor.opacity(0.4)
            : Color.clear
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 8) {
                Text("Error")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.red)
                
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(.systemGray))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            Button("Try Again", action: onRetry)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.red)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.red, lineWidth: 1)
                )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.red.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.red.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
