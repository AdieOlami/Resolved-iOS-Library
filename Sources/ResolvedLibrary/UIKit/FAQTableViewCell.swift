////
////  FAQTableViewCell.swift
////  ResolvedLibrary
////
////  Created by Olami on 2025-07-13.
////
//
//import UIKit
//
//final class FAQTableViewCell: UITableViewCell {
//    
//    // MARK: - UI Components
//    private let containerView = UIView()
//    private let questionLabel = UILabel()
//    private let categoryLabel = UILabel()
//    private let viewCountLabel = UILabel()
//    private let iconImageView = UIImageView()
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
//        // Container view with glassmorphism
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.layer.cornerRadius = 16
//        contentView.addSubview(containerView)
//        
//        // Question label
//        questionLabel.translatesAutoresizingMaskIntoConstraints = false
//        questionLabel.numberOfLines = 0
//        questionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
//        containerView.addSubview(questionLabel)
//        
//        // Category label
//        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
//        categoryLabel.numberOfLines = 1
//        categoryLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
//        containerView.addSubview(categoryLabel)
//        
//        // View count label
//        viewCountLabel.translatesAutoresizingMaskIntoConstraints = false
//        viewCountLabel.numberOfLines = 1
//        viewCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
//        containerView.addSubview(viewCountLabel)
//        
//        // Icon
//        iconImageView.translatesAutoresizingMaskIntoConstraints = false
//        iconImageView.contentMode = .scaleAspectFit
//        iconImageView.image = UIImage(systemName: "questionmark.circle.fill")
//        containerView.addSubview(iconImageView)
//        
//        // Layout
//        NSLayoutConstraint.activate([
//            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
//            
//            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
//            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            iconImageView.widthAnchor.constraint(equalToConstant: 24),
//            iconImageView.heightAnchor.constraint(equalToConstant: 24),
//            
//            questionLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
//            questionLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
//            questionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//            
//            categoryLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 8),
//            categoryLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
//            categoryLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
//            
//            viewCountLabel.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
//            viewCountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//            viewCountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: categoryLabel.trailingAnchor, constant: 8)
//        ])
//    }
//    
//    func configure(with faq: FAQ, theme: ResolvedTheme) {
//        let colors = theme.effectiveColors
//        
//        questionLabel.text = faq.question
//        questionLabel.textColor = colors.textPrimaryColor
//        
//        categoryLabel.text = faq.category.uppercased()
//        categoryLabel.textColor = colors.primaryColor
//        
//        viewCountLabel.text = "\(faq.viewCount) views"
//        viewCountLabel.textColor = colors.textSecondaryColor
//        
//        iconImageView.tintColor = colors.primaryColor
//        
//        // Glassmorphism styling
//        containerView.backgroundColor = colors.glassSurfaceColor
//        containerView.addModernShadow(theme: theme)
//        containerView.addModernBorder(theme: theme)
//        
//        backgroundColor = .clear
//    }
//}
