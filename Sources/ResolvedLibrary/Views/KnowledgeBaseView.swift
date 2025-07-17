//
//  KnowledgeBaseView.swift
//  ResolvedLibrary
//
//  Created by Olami on 2025-07-13.
//

import SwiftUI
@_exported import Resolved

// MARK: - KnowledgeBaseView

struct KnowledgeBaseView: View {
    let configuration: HelpCenterConfiguration
    @Binding var routes: NavigationPath
    let onBack: () -> Void
    
    @StateObject private var sdkManager = ResolvedSDKManager()
    @State private var searchQuery = ""
    @State private var isSearching = false
    @State private var selectedArticleId: String?
    @State private var expandedCollections: Set<String> = []
    @State private var showingArticleDetail = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Content
            ScrollView {
                LazyVStack(spacing: 0) {
                    if isSearching {
                        searchResults
                    } else {
                        collectionsView
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .refreshable {
                await refreshKnowledgeBase()
            }
            .background(configuration.theme.backgroundColor)
            .navigationBarHidden(true)
            .navigationDestination(for: String.self) { articleId in
                ArticleDetailView(
                    articleId: articleId,
                    configuration: configuration,
                    sdkManager: sdkManager
                )
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            routes.removeLast()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(configuration.theme.primaryColor)
                        }
                    }
                }
            }
        }
        .task {
            if sdkManager.organization == nil {
                await sdkManager.initialize(with: configuration)
            }
            await sdkManager.loadCollections()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 0) {
            // Top section with title and collections count
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Knowledge Base")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(configuration.theme.textColor)
                    
                    if !sdkManager.collections.isEmpty {
                        Text("\(sdkManager.collections.count) Collections Available")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(configuration.theme.secondaryColor)
                    }
                }
                
                Spacer()
                
                // Back button
                Button(action: onBack) {
                    ZStack {
                        Circle()
                            .fill(configuration.theme.primaryColor.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(configuration.theme.primaryColor)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Search Bar
            searchBarView
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            
            Divider()
                .background(configuration.theme.borderColor.opacity(0.3))
        }
        .background(headerBackgroundColor)
    }
    
    private var searchBarView: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(configuration.theme.primaryColor.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(configuration.theme.primaryColor)
            }
            
            TextField("Search articles and guides...", text: $searchQuery)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(configuration.theme.textColor)
                .onSubmit {
                    Task {
                        await performSearch()
                    }
                }
                .onChange(of: searchQuery) { _, newValue in
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
                        .font(.system(size: 20))
                        .foregroundColor(configuration.theme.secondaryColor)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(searchBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(configuration.theme.borderColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Collections View
    private var collectionsView: some View {
        Group {
            if sdkManager.isLoadingCollections {
//                LoadingView(message: "Loading collections...")
//                    .padding(40)
                loadingCollectionsView
            } else if let error = sdkManager.collectionError {
                ErrorView(message: error, onRetry: {
                    Task {
                        await sdkManager.loadCollections()
                    }
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
                LazyVStack(spacing: 16) {
                    ForEach(sdkManager.collections, id: \.id) { collection in
                        CollectionCardView(
                            collection: collection,
                            configuration: configuration,
                            sdkManager: sdkManager,
                            expandedCollections: $expandedCollections,
                            onArticleSelect: { articleId in
                                routes.append(articleId)
                            },
                            level: 0
                        )
                    }
                }
                .padding(.top, 20)
            }
        }
    }
    
    private var loadingCollectionsView: some View {
        LazyVStack(spacing: 16) {
            ForEach(0..<5, id: \.self) { _ in
                SkeletonKnowledgeBaseCardView(configuration: configuration)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Search Results
    private var searchResults: some View {
        Group {
            if sdkManager.isLoadingArticles {
                LoadingView(message: "Searching...")
                    .padding(40)
            } else if let error = sdkManager.articleError {
                ErrorView(message: error, onRetry: {
                    Task {
                        await performSearch()
                    }
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
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Search Results")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(configuration.theme.textColor)
                        
                        Spacer()
                        
                        Text("\(sdkManager.articles.count) found")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(configuration.theme.secondaryColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(configuration.theme.primaryColor.opacity(0.1))
                            )
                    }
                    .padding(.top, 20)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(sdkManager.articles, id: \.id) { article in
                            SearchResultCardView(
                                article: article,
                                configuration: configuration,
                                onSelect: {
                                    routes.append(article.id)
                                }
                            )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func refreshKnowledgeBase() async {
        if isSearching {
            await performSearchRefresh()
        } else {
            await sdkManager.loadCollections()
            while sdkManager.isLoadingCollections {
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        }
    }

    private func performSearchRefresh() async {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        await sdkManager.searchArticles(query: searchQuery)
        while sdkManager.isLoadingArticles {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }
    
    private func performSearch() async {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await MainActor.run {
                isSearching = false
            }
            return
        }
        
        await MainActor.run {
            isSearching = true
        }
        await sdkManager.searchArticles(query: searchQuery)
    }
    
    // MARK: - Computed Properties
    private var headerBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemBackground)
            : Color(.systemBackground)
    }
    
    private var searchBackgroundColor: Color {
        configuration.theme.adaptiveInputBackground(for: colorScheme)
    }
}

// MARK: - KnowledgeBaseWrapper

struct KnowledgeBaseWrapper: View {
    let configuration: HelpCenterConfiguration
    let onDismiss: (() -> Void)?
    
    @State private var routes = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $routes) {
            KnowledgeBaseView(
                configuration: configuration,
                routes: $routes,
                onBack: {
                    onDismiss?()
                }
            )
        }
        .animation(nil)
    }
}

// MARK: - SkeletonTicketCardView

struct SkeletonKnowledgeBaseCardView: View {
    let configuration: HelpCenterConfiguration
    @State private var animationOffset: CGFloat = -200
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 12) {
                    SkeletonCircle(size: 44)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        SkeletonLine(width: 80, height: 16)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    SkeletonLine(width: 60, height: 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                SkeletonLine(width: nil, height: 18)
                SkeletonLine(width: 150, height: 14)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(skeletonBackgroundColor)
        )
    }
    
    private var skeletonBackgroundColor: Color {
        configuration.theme.adaptiveCardBackground(for: colorScheme)
    }
}

// MARK: - Collection Card View
struct CollectionCardView: View {
    let collection: Collection
    let configuration: HelpCenterConfiguration
    @ObservedObject var sdkManager: ResolvedSDKManager
    @Binding var expandedCollections: Set<String>
    let onArticleSelect: (String) -> Void
    let level: Int
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var isExpanded: Bool {
        expandedCollections.contains(collection.id)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Collection Header Card
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    if isExpanded {
                        expandedCollections.remove(collection.id)
                    } else {
                        expandedCollections.insert(collection.id)
                        if collection.articles?.isEmpty == true {
                            Task {
                                await sdkManager.loadArticles(for: collection.id)
                            }
                        }
                    }
                }
            }) {
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        // Icon
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(iconBackgroundGradient)
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: level == 0 ? "folder.fill" : "doc.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .shadow(color: iconColor.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(collection.name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(configuration.theme.textColor)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                            
                            if let articlesCount = collection.articles?.count, articlesCount > 0 {
                                HStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(configuration.theme.primaryColor.opacity(0.2))
                                            .frame(width: 24, height: 24)
                                        
                                        Text("\(articlesCount)")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(configuration.theme.primaryColor)
                                    }
                                    
                                    Text("Article\(articlesCount == 1 ? "" : "s")")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(configuration.theme.secondaryColor)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(configuration.theme.primaryColor.opacity(0.1))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(configuration.theme.primaryColor)
                                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isExpanded)
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(cardBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(cardBorderColor, lineWidth: isExpanded ? 2 : 1)
                        )
                        .shadow(color: shadowColor, radius: isExpanded ? 12 : 6, x: 0, y: isExpanded ? 6 : 3)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded Content
            if isExpanded {
                VStack(spacing: 12) {
                    if let articles = collection.articles, !articles.isEmpty {
                        LazyVStack(spacing: 8) {
                            ForEach(articles, id: \.id) { article in
                                ArticleRowView(
                                    article: article,
                                    configuration: configuration,
                                    onSelect: {
                                        Task {
                                            await MainActor.run {
                                                onArticleSelect(article.id)
                                            }
                                            await sdkManager.loadArticle(id: article.id)
                                        }
                                    }
                                )
                            }
                        }
                    } else if sdkManager.isLoadingArticles {
                        LoadingView(message: "Loading articles...")
                            .padding(20)
                    }
                    
                    // Sub-collections
                    if let subCollections = collection.subCollections {
                        LazyVStack(spacing: 12) {
                            ForEach(subCollections, id: \.id) { subCollection in
                                CollectionCardView(
                                    collection: subCollection,
                                    configuration: configuration,
                                    sdkManager: sdkManager,
                                    expandedCollections: $expandedCollections,
                                    onArticleSelect: onArticleSelect,
                                    level: level + 1
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isExpanded)
            }
        }
    }
    
    private var iconBackgroundGradient: LinearGradient {
        let colors = [
            [configuration.theme.primaryColor, configuration.theme.primaryColor.opacity(0.7)],
            [Color.green, Color.green.opacity(0.7)],
            [Color.orange, Color.orange.opacity(0.7)],
            [Color.red, Color.red.opacity(0.7)]
        ]
        let colorPair = colors[min(level, colors.count - 1)]
        return LinearGradient(colors: colorPair, startPoint: .topLeading, endPoint: .bottomTrailing)
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
    
    private var cardBackgroundColor: Color {
        if isExpanded {
            return configuration.theme.primaryColor.opacity(0.05)
        }
        return configuration.theme.adaptiveCardBackground(for: colorScheme)
    }
    
    private var cardBorderColor: Color {
        isExpanded
            ? configuration.theme.primaryColor.opacity(0.3)
            : configuration.theme.borderColor.opacity(0.1)
    }
    
    private var shadowColor: Color {
        configuration.theme.adaptiveShadowColor(for: colorScheme)
    }
}

// MARK: - Article Row View
struct ArticleRowView: View {
    let article: Article
    let configuration: HelpCenterConfiguration
    let onSelect: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconBackgroundGradient)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .shadow(color: configuration.theme.primaryColor.opacity(0.3), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(configuration.theme.textColor)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    if let description = article.description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(configuration.theme.secondaryColor)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(configuration.theme.secondaryColor)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(articleBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(configuration.theme.borderColor.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [configuration.theme.primaryColor, configuration.theme.primaryColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var articleBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray6).opacity(0.2)
            : Color(.systemGray6).opacity(0.3)
    }
}

// MARK: - Search Result Card View

struct SearchResultCardView: View {
    let article: Article
    let configuration: HelpCenterConfiguration
    let onSelect: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(iconBackgroundGradient)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .shadow(color: configuration.theme.primaryColor.opacity(0.3), radius: 6, x: 0, y: 3)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(article.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(configuration.theme.textColor)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                        if let description = article.description, !description.isEmpty {
                            Text(description)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(configuration.theme.secondaryColor)
                                .multilineTextAlignment(.leading)
                                .lineLimit(3)
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(searchResultBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(configuration.theme.primaryColor.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: shadowColor, radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [configuration.theme.primaryColor, configuration.theme.primaryColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var searchResultBackgroundColor: Color {
        configuration.theme.adaptiveCardBackground(for: colorScheme)
    }
    
    private var shadowColor: Color {
        configuration.theme.adaptiveShadowColor(for: colorScheme)
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 64, height: 64)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 12) {
                Text("Something went wrong")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.red)
                
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(.systemGray))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            Button(action: onRetry) {
                Text("Try Again")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red)
                    )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.red.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.red.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
