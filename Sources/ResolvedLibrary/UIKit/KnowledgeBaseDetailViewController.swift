////
////  KnowledgeBaseDetailViewController.swift
////  ResolvedLibrary
////
////  Created by Olami on 2025-07-13.
////
//
//import UIKit
//
//final class KnowledgeBaseDetailViewController: BaseViewController {
//    private var currentArticle: Article?
//    
//    // MARK: - UI Components
//    private lazy var scrollView: UIScrollView = {
//        let scrollView = UIScrollView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.showsVerticalScrollIndicator = false
//        return scrollView
//    }()
//    
//    private lazy var contentView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private lazy var emptyStateView: UIView = {
//        let container = UIView()
//        container.translatesAutoresizingMaskIntoConstraints = false
//        
//        let iconImageView = UIImageView()
//        iconImageView.translatesAutoresizingMaskIntoConstraints = false
//        iconImageView.image = UIImage(systemName: "doc.text")
//        iconImageView.tintColor = colors.secondaryColor
//        iconImageView.contentMode = .scaleAspectFit
//        
//        let titleLabel = createStyledLabel(text: "Select an article", style: .title)
//        titleLabel.textAlignment = .center
//        
//        let messageLabel = createStyledLabel(
//            text: "Choose an article from the sidebar to view its content, or use the search function to find specific topics.",
//            style: .body
//        )
//        messageLabel.textAlignment = .center
//        messageLabel.textColor = colors.textSecondaryColor
//        
//        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel, messageLabel])
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.axis = .vertical
//        stackView.spacing = theme.mediumSpacing
//        stackView.alignment = .center
//        container.addSubview(stackView)
//        
//        NSLayoutConstraint.activate([
//            iconImageView.widthAnchor.constraint(equalToConstant: 64),
//            iconImageView.heightAnchor.constraint(equalToConstant: 64),
//            
//            stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
//            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
//            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: theme.largeSpacing),
//            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -theme.largeSpacing)
//        ])
//        
//        return container
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        showEmptyState()
//    }
//    
//    private func setupUI() {
//        view.backgroundColor = colors.backgroundColor
//        
//        view.addSubview(scrollView)
//        scrollView.addSubview(contentView)
//        view.addSubview(emptyStateView)
//        
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//            
//            emptyStateView.topAnchor.constraint(equalTo: view.topAnchor),
//            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//    
//    func displayArticle(_ article: Article) {
//        currentArticle = article
//        hideEmptyState()
//        buildArticleContent(article)
//    }
//    
//    private func showEmptyState() {
//        emptyStateView.isHidden = false
//        scrollView.isHidden = true
//    }
//    
//    private func hideEmptyState() {
//        emptyStateView.isHidden = true
//        scrollView.isHidden = false
//    }
//    
//    private func buildArticleContent(_ article: Article) {
//        // Clear existing content
//        contentView.subviews.forEach { $0.removeFromSuperview() }
//        
//        // Title
//        let titleLabel = createStyledLabel(text: article.title, style: .heroTitle)
//        contentView.addSubview(titleLabel)
//        
//        // Metadata
//        let metadataContainer = UIView()
//        metadataContainer.translatesAutoresizingMaskIntoConstraints = false
//        
//        let statusBadge = createBadge(text: article.status.rawValue.capitalized)
//        let typeBadge = createBadge(text: article.type.rawValue.capitalized)
//        
//        let badgeStack = UIStackView(arrangedSubviews: [statusBadge, typeBadge])
//        badgeStack.translatesAutoresizingMaskIntoConstraints = false
//        badgeStack.axis = .horizontal
//        badgeStack.spacing = theme.smallSpacing
//        badgeStack.distribution = .fill
//        
//        metadataContainer.addSubview(badgeStack)
//        contentView.addSubview(metadataContainer)
//        
//        // Content
//        let contentLabel = createStyledLabel(text: article.content, style: .body)
//        contentView.addSubview(contentLabel)
//        
//        // Separator
//        let separator = UIView()
//        separator.translatesAutoresizingMaskIntoConstraints = false
//        separator.backgroundColor = colors.borderColor
//        contentView.addSubview(separator)
//        
//        // Layout
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: theme.largeSpacing),
//            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: theme.largeSpacing),
//            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -theme.largeSpacing),
//            
//            separator.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: theme.largeSpacing),
//            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: theme.largeSpacing),
//            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -theme.largeSpacing),
//            separator.heightAnchor.constraint(equalToConstant: 1),
//            
//            metadataContainer.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: theme.largeSpacing),
//            metadataContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: theme.largeSpacing),
//            metadataContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -theme.largeSpacing),
//            
//            badgeStack.topAnchor.constraint(equalTo: metadataContainer.topAnchor),
//            badgeStack.leadingAnchor.constraint(equalTo: metadataContainer.leadingAnchor),
//            badgeStack.bottomAnchor.constraint(equalTo: metadataContainer.bottomAnchor),
//            
//            contentLabel.topAnchor.constraint(equalTo: metadataContainer.bottomAnchor, constant: theme.largeSpacing),
//            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: theme.largeSpacing),
//            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -theme.largeSpacing),
//            contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -theme.largeSpacing)
//        ])
//        
//        // Animate content appearance
//        contentView.addFadeInAnimation()
//    }
//    
//    private func createBadge(text: String) -> UIView {
//        let container = UIView()
//        container.translatesAutoresizingMaskIntoConstraints = false
//        container.backgroundColor = colors.primaryColor.withAlphaComponent(0.1)
//        container.layer.cornerRadius = 12
//        container.layer.borderWidth = 1
//        container.layer.borderColor = colors.primaryColor.withAlphaComponent(0.2).cgColor
//        
//        let label = createStyledLabel(text: text, style: .caption)
//        label.textColor = colors.primaryColor
//        label.font = theme.captionFont.withSize(10)
//        container.addSubview(label)
//        
//        NSLayoutConstraint.activate([
//            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
//            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
//            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
//            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
//        ])
//        
//        return container
//    }
//}
