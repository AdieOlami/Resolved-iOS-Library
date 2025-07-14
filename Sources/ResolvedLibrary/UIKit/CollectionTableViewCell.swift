////
////  CollectionTableViewCell.swift
////  ResolvedLibrary
////
////  Created by Olami on 2025-07-13.
////
//
//import UIKit
//
//final class CollectionTableViewCell: UITableViewCell {
//    private let containerView = UIView()
//    private let iconContainer = UIView()
//    private let iconImageView = UIImageView()
//    private let titleLabel = UILabel()
//    private let articleCountLabel = UILabel()
//    private let chevronImageView = UIImageView()
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupUI() {
//        selectionStyle = .none
//        backgroundColor = .clear
//        
//        container    private func setupUI() {
//        view.backgroundColor = colors.backgroundColor
//        view.addSubview(scrollView)
//        scrollView.addSubview(contentView)
//        
//        setupHeroSection()
//        setupCardsSection()
//        setupFAQSection()
//        setupConstraints()
//    }
//    
//    private func setupHeroSection() {
//        contentView.addSubview(heroContainer)
//        
//        let heroStack = UIStackView(arrangedSubviews: [heroTitle, heroSubtitle, searchContainer])
//        heroStack.translatesAutoresizingMaskIntoConstraints = false
//        heroStack.axis = .vertical
//        heroStack.spacing = theme.largeSpacing
//        heroStack.alignment = .fill
//        heroContainer.addSubview(heroStack)
//        
//        searchContainer.addSubview(searchBar)
//        
//        NSLayoutConstraint.activate([
//            heroStack.topAnchor.constraint(equalTo: heroContainer.topAnchor, constant: theme.extraLargeSpacing),
//            heroStack.leadingAnchor.constraint(equalTo: heroContainer.leadingAnchor, constant: theme.largeSpacing),
//            heroStack.trailingAnchor.constraint(equalTo: heroContainer.trailingAnchor, constant: -theme.largeSpacing),
//            heroStack.bottomAnchor.constraint(equalTo: heroContainer.bottomAnchor, constant: -theme.extraLargeSpacing),
//            
//            searchContainer.heightAnchor.constraint(equalToConstant: 56),
//            
//            searchBar.topAnchor.constraint(equalTo: searchContainer.topAnchor),
//            searchBar.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor),
//            searchBar.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor),
//            searchBar.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor)
//        ])
//    }
//    
//    private func setupCardsSection() {
//        contentView.addSubview(cardsStackView)
//        createFeatureCards()
//    }
//    
//    private func createFeatureCards() {
//        // Knowledge Base Card
//        let knowledgeBaseCard = createFeatureCard(
//            title: "Knowledge Base",
//            description: "Explore our comprehensive collection of guides, tutorials, and documentation to find instant answers.",
//            iconName: "book.fill"
//        ) { [weak self] in
//            self?.navigateToKnowledgeBase()
//        }
//        cardsStackView.addArrangedSubview(knowledgeBaseCard)
//        
//        // Create Ticket Card
//        let createTicketCard = createFeatureCard(
//            title: "Get Support",
//            description: "Need personalized assistance? Submit a support ticket and our expert team will help you promptly.",
//            iconName: "paperplane.fill"
//        ) { [weak self] in
//            self?.navigateToCreateTicket()
//        }
//        cardsStackView.addArrangedSubview(createTicketCard)
//        
//        // Your Tickets Card (only if customer ID is available)
//        if customerId != nil {
//            let ticketsCard = createFeatureCard(
//                title: "Your Tickets",
//                description: "Track the progress of your support requests and communicate with our support team.",
//                iconName: "ticket.fill"
//            ) { [weak self] in
//                self?.navigateToTickets()
//            }
//            cardsStackView.addArrangedSubview(ticketsCard)
//        }
//    }
//    
//    private func createFeatureCard(
//        title: String,
//        description: String,
//        iconName: String,
//        action: @escaping () -> Void
//    ) -> UIView {
//        let card = createGlassView()
//        card.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Add tap gesture
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
//        card.addGestureRecognizer(tapGesture)
//        card.isUserInteractionEnabled = true
//        
//        // Store action in card
//        objc_setAssociatedObject(card, "action", action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        
//        // Icon container
//        let iconContainer = UIView()
//        iconContainer.translatesAutoresizingMaskIntoConstraints = false
//        iconContainer.backgroundColor = colors.primaryColor.withAlphaComponent(0.15)
//        iconContainer.layer.cornerRadius = theme.mediumCornerRadius
//        
//        let iconImageView = UIImageView()
//        iconImageView.translatesAutoresizingMaskIntoConstraints = false
//        iconImageView.image = UIImage(systemName: iconName)
//        iconImageView.tintColor = colors.primaryColor
//        iconImageView.contentMode = .scaleAspectFit
//        iconContainer.addSubview(iconImageView)
//        
//        // Title and description
//        let titleLabel = createStyledLabel(text: title, style: .title)
//        let descriptionLabel = createStyledLabel(text: description, style: .body)
//        descriptionLabel.textColor = colors.textSecondaryColor
//        
//        let contentStack = UIStackView(arrangedSubviews: [iconContainer, titleLabel, descriptionLabel])
//        contentStack.translatesAutoresizingMaskIntoConstraints = false
//        contentStack.axis = .vertical
//        contentStack.spacing = theme.mediumSpacing
//        contentStack.alignment = .leading
//        card.addSubview(contentStack)
//        
//        NSLayoutConstraint.activate([
//            iconContainer.widthAnchor.constraint(equalToConstant: 64),
//            iconContainer.heightAnchor.constraint(equalToConstant: 64),
//            
//            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
//            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
//            iconImageView.widthAnchor.constraint(equalToConstant: 28),
//            iconImageView.heightAnchor.constraint(equalToConstant: 28),
//            
//            contentStack.topAnchor.constraint(equalTo: card.topAnchor, constant: theme.largeSpacing),
//            contentStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: theme.largeSpacing),
//            contentStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -theme.largeSpacing),
//            contentStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -theme.largeSpacing)
//        ])
//        
//        return card
//    }
//    
//    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
//        guard let card = gesture.view else { return }
//        
//        // Add ripple effect
//        let location = gesture.location(in: card)
//        card.addRippleEffect(at: location, color: colors.primaryColor)
//        
//        // Execute action
//        if let action = objc_getAssociatedObject(card, "action") as? () -> Void {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                action()
//            }
//        }
//    }
//    
//    private func setupFAQSection() {
//        contentView.addSubview(faqSectionTitle)
//        contentView.addSubview(faqContainer)
//        faqContainer.addSubview(faqStackView)
//    }
//    
//    private func setupConstraints() {
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
//            heroContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: theme.mediumSpacing),
//            heroContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: theme.mediumSpacing),
//            heroContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -theme.mediumSpacing),
//            
//            cardsStackView.topAnchor.constraint(equalTo: heroContainer.bottomAnchor, constant: theme.extraLargeSpacing),
//            cardsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: theme.mediumSpacing),
//            cardsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -theme.mediumSpacing),
//            
//            faqSectionTitle.topAnchor.constraint(equalTo: cardsStackView.bottomAnchor, constant: theme.extraLargeSpacing),
//            faqSectionTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: theme.mediumSpacing),
//            faqSectionTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -theme.mediumSpacing),
//            
//            faqContainer.topAnchor.constraint(equalTo: faqSectionTitle.bottomAnchor, constant: theme.largeSpacing),
//            faqContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: theme.mediumSpacing),
//            faqContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -theme.mediumSpacing),
//            faqContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -theme.largeSpacing),
//            
//            faqStackView.topAnchor.constraint(equalTo: faqContainer.topAnchor),
//            faqStackView.leadingAnchor.constraint(equalTo: faqContainer.leadingAnchor),
//            faqStackView.trailingAnchor.constraint(equalTo: faqContainer.trailingAnchor),
//            faqStackView.bottomAnchor.constraint(equalTo: faqContainer.bottomAnchor)
//        ])
//    }
//    
//    private func setupAnimations() {
//        heroContainer.addFadeInAnimation(delay: 0.1)
//        cardsStackView.addFadeInAnimation(delay: 0.3)
//        faqContainer.addFadeInAnimation(delay: 0.5)
//    }
//    
//    // MARK: - Navigation Methods
//    
//    private func navigateToKnowledgeBase() {
//        let knowledgeBaseVC = library.createKnowledgeBaseViewController()
//        navigationController?.pushViewController(knowledgeBaseVC, animated: true)
//        delegate?.helpCenterViewController(self, didSelectView: .knowledgeBase)
//    }
//    
//    private func navigateToCreateTicket() {
//        let createTicketVC = library.createTicketCreationViewController(
//            customerId: customerId,
//            customerEmail: customerEmail,
//            customerName: customerName,
//            customerMetadata: customerMetadata
//        )
//        let navController = UINavigationController(rootViewController: createTicketVC)
//        present(navController, animated: true)
//        delegate?.helpCenterViewController(self, didSelectView: .createTicket)
//    }
//    
//    private func navigateToTickets() {
//        guard let customerId = customerId else { return }
//        let ticketsVC = library.createTicketListViewController(customerId: customerId)
//        navigationController?.pushViewController(ticketsVC, animated: true)
//        delegate?.helpCenterViewController(self, didSelectView: .tickets)
//    }
//    
//    // MARK: - Data Loading
//    
//    private func loadFAQs() {
//        showLoading()
//        
//        let params = FAQListParams(
//            status: .published,
//            page: 1,
//            limit: 10,
//            sortBy: "viewCount",
//            sortOrder: "desc"
//        )
//        
//        library.sdk.faq.getFAQs(params: params) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.hideLoading()
//                
//                switch result {
//                case .success(let response):
//                    self?.faqs = response.data ?? []
//                    self?.updateFAQDisplay()
//                    
//                case .failure(let error):
//                    self?.showError(error)
//                    self?.delegate?.helpCenterViewController(self!, didEncounterError: error)
//                }
//            }
//        }
//    }
//    
//    private func searchFAQs(query: String) {
//        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//            isSearching = false
//            faqSectionTitle.text = "Frequently Asked Questions"
//            updateFAQDisplay()
//            return
//        }
//        
//        isSearching = true
//        faqSectionTitle.text = "Search Results for \"\(query)\""
//        
//        let params = FAQSearchParams(query: query, page: 1, limit: 20)
//        
//        library.sdk.faq.searchFAQs(params: params) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    self?.searchResults = response.data ?? []
//                    self?.updateFAQDisplay()
//                    
//                case .failure(let error):
//                    self?.showError(error)
//                    self?.delegate?.helpCenterViewController(self!, didEncounterError: error)
//                }
//            }
//        }
//        
//        delegate?.helpCenterViewController(self, didPerformSearch: query)
//    }
//    
//    private func updateFAQDisplay() {
//        // Clear existing FAQ views
//        faqStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//        
//        let displayFAQs = isSearching ? searchResults : faqs
//        
//        if displayFAQs.isEmpty {
//            let emptyView = createEmptyFAQView()
//            faqStackView.addArrangedSubview(emptyView)
//        } else {
//            for (index, faq) in displayFAQs.enumerated() {
//                let faqView = createFAQView(faq: faq, index: index, isLast: index == displayFAQs.count - 1)
//                faqStackView.addArrangedSubview(faqView)
//                faqView.addFadeInAnimation(delay: TimeInterval(index) * 0.1)
//            }
//        }
//    }
//    
//    private func createEmptyFAQView() -> UIView {
//        let container = UIView()
//        container.translatesAutoresizingMaskIntoConstraints = false
//        
//        let iconImageView = UIImageView()
//        iconImageView.translatesAutoresizingMaskIntoConstraints = false
//        iconImageView.image = UIImage(systemName: "questionmark.circle")
//        iconImageView.tintColor = colors.secondaryColor
//        iconImageView.contentMode = .scaleAspectFit
//        
//        let titleLabel = createStyledLabel(
//            text: isSearching ? "No results found" : "No FAQs available",
//            style: .title
//        )
//        titleLabel.textAlignment = .center
//        
//        let messageLabel = createStyledLabel(
//            text: isSearching 
//                ? "No results found for your search. Try adjusting your search terms."
//                : "No frequently asked questions are available at the moment.",
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
//            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: theme.extraLargeSpacing),
//            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: theme.largeSpacing),
//            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -theme.largeSpacing),
//            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -theme.extraLargeSpacing)
//        ])
//        
//        return container
//    }
//    
//    private func createFAQView(faq: FAQ, index: Int, isLast: Bool) -> UIView {
//        let container = UIView()
//        container.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Question container (tappable)
//        let questionContainer = UIView()
//        questionContainer.translatesAutoresizingMaskIntoConstraints = false
//        questionContainer.backgroundColor = expandedFAQIndex == index ? colors.primaryColor.withAlphaComponent(0.08) : .clear
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(faqTapped(_:)))
//        questionContainer.addGestureRecognizer(tapGesture)
//        questionContainer.isUserInteractionEnabled = true
//        questionContainer.tag = index
//        
//        // Question label
//        let questionLabel = createStyledLabel(text: faq.question, style: .body)
//        questionLabel.font = theme.bodyFont.withSize(18)
//        
//        // Expand/collapse icon
//        let iconContainer = UIView()
//        iconContainer.translatesAutoresizingMaskIntoConstraints = false
//        iconContainer.backgroundColor = colors.primaryColor.withAlphaComponent(0.15)
//        iconContainer.layer.cornerRadius = 12
//        
//        let iconImageView = UIImageView()
//        iconImageView.translatesAutoresizingMaskIntoConstraints = false
//        iconImageView.image = UIImage(systemName: expandedFAQIndex == index ? "minus" : "plus")
//        iconImageView.tintColor = colors.primaryColor
//        iconImageView.contentMode = .scaleAspectFit
//        iconContainer.addSubview(iconImageView)
//        
//        questionContainer.addSubview(questionLabel)
//        questionContainer.addSubview(iconContainer)
//        container.addSubview(questionContainer)
//        
//        // Answer container (collapsible)
//        var answerContainer: UIView?
//        if expandedFAQIndex == index {
//            let answerView = UIView()
//            answerView.translatesAutoresizingMaskIntoConstraints = false
//            answerView.backgroundColor = colors.surfaceColor.withAlphaComponent(0.5)
//            
//            let answerLabel = createStyledLabel(text: faq.answer, style: .body)
//            answerLabel.textColor = colors.textSecondaryColor
//            answerView.addSubview(answerLabel)
//            
//            container.addSubview(answerView)
//            answerContainer = answerView
//            
//            NSLayoutConstraint.activate([
//                answerLabel.topAnchor.constraint(equalTo: answerView.topAnchor, constant: theme.largeSpacing),
//                answerLabel.leadingAnchor.constraint(equalTo: answerView.leadingAnchor, constant: theme.largeSpacing),
//                answerLabel.trailingAnchor.constraint(equalTo: answerView.trailingAnchor, constant: -theme.largeSpacing),
//                answerLabel.bottomAnchor.constraint(equalTo: answerView.bottomAnchor, constant: -theme.largeSpacing)
//            ])
//        }
//        
//        // Separator (except for last item)
//        var separator: UIView?
//        if !isLast {
//            let separatorView = UIView()
//            separatorView.translatesAutoresizingMaskIntoConstraints = false
//            separatorView.backgroundColor = colors.borderColor
//            container.addSubview(separatorView)
//            separator = separatorView
//        }
//        
//        // Layout constraints
//        NSLayoutConstraint.activate([
//            questionContainer.topAnchor.constraint(equalTo: container.topAnchor),
//            questionContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor),
//            questionContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor),
//            
//            questionLabel.topAnchor.constraint(equalTo: questionContainer.topAnchor, constant: theme.largeSpacing),
//            questionLabel.leadingAnchor.constraint(equalTo: questionContainer.leadingAnchor, constant: theme.largeSpacing),
//            questionLabel.trailingAnchor.constraint(equalTo: iconContainer.leadingAnchor, constant: -theme.mediumSpacing),
//            questionLabel.bottomAnchor.constraint(equalTo: questionContainer.bottomAnchor, constant: -theme.largeSpacing),
//            
//            iconContainer.centerYAnchor.constraint(equalTo: questionContainer.centerYAnchor),
//            iconContainer.trailingAnchor.constraint(equalTo: questionContainer.trailingAnchor, constant: -theme.largeSpacing),
//            iconContainer.widthAnchor.constraint(equalToConstant: 40),
//            iconContainer.heightAnchor.constraint(equalToConstant: 40),
//            
//            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
//            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
//            iconImageView.widthAnchor.constraint(equalToConstant: 20),
//            iconImageView.heightAnchor.constraint(equalToConstant: 20)
//        ])
//        
//        if let answerContainer = answerContainer {
//            NSLayoutConstraint.activate([
//                answerContainer.topAnchor.constraint(equalTo: questionContainer.bottomAnchor),
//                answerContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor),
//                answerContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor),
//                answerContainer.bottomAnchor.constraint(equalTo: separator?.topAnchor ?? container.bottomAnchor)
//            ])
//        } else {
//            questionContainer.bottomAnchor.constraint(equalTo: separator?.topAnchor ?? container.bottomAnchor).isActive = true
//        }
//        
//        if let separator = separator {
//            NSLayoutConstraint.activate([
//                separator.heightAnchor.constraint(equalToConstant: 1),
//                separator.leadingAnchor.constraint(equalTo: container.leadingAnchor),
//                separator.trailingAnchor.constraint(equalTo: container.trailingAnchor),
//                separator.bottomAnchor.constraint(equalTo: container.bottomAnchor)
//            ])
//        }
//        
//        return container
//    }
//    
//    @objc private func faqTapped(_ gesture: UITapGestureRecognizer) {
//        guard let container = gesture.view else { return }
//        let index = container.tag
//        
//        // Add ripple effect
//        let location = gesture.location(in: container)
//        container.addRippleEffect(at: location, color: colors.primaryColor)
//        
//        // Toggle FAQ expansion
//        if expandedFAQIndex == index {
//            expandedFAQIndex = nil
//        } else {
//            expandedFAQIndex = index
//        }
//        
//        // Update display with animation
//        UIView.animate(withDuration: 0.3) {
//            self.updateFAQDisplay()
//        }
//    }
//}
