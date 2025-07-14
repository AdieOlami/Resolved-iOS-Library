////
////  BaseViewController.swift
////  ResolvedLibrary
////
////  Created by Olami on 2025-07-13.
////
//
//import UIKit
//
//open class BaseViewController: UIViewController {
//    public let library: ResolvedLibrary
//    public var theme: ResolvedTheme { return library.theme }
//    public var colors: EffectiveColors { return theme.effectiveColors }
//    
//    private lazy var loadingOverlay: UIView = {
//        let overlay = UIView()
//        overlay.translatesAutoresizingMaskIntoConstraints = false
//        overlay.isHidden = true
//        
//        let backgroundView = createGlassView()
//        backgroundView.translatesAutoresizingMaskIntoConstraints = false
//        overlay.addSubview(backgroundView)
//        
//        let container = UIView()
//        container.translatesAutoresizingMaskIntoConstraints = false
//        container.backgroundColor = colors.glassSurfaceColor
//        container.layer.cornerRadius = theme.largeCornerRadius
//        container.addModernShadow(theme: theme)
//        overlay.addSubview(container)
//        
//        let spinner = UIActivityIndicatorView(style: .large)
//        spinner.translatesAutoresizingMaskIntoConstraints = false
//        spinner.color = colors.primaryColor
//        spinner.startAnimating()
//        container.addSubview(spinner)
//        
//        let loadingLabel = createStyledLabel(text: "Loading...", style: .body)
//        loadingLabel.textAlignment = .center
//        loadingLabel.textColor = colors.textSecondaryColor
//        container.addSubview(loadingLabel)
//        
//        NSLayoutConstraint.activate([
//            backgroundView.topAnchor.constraint(equalTo: overlay.topAnchor),
//            backgroundView.leadingAnchor.constraint(equalTo: overlay.leadingAnchor),
//            backgroundView.trailingAnchor.constraint(equalTo: overlay.trailingAnchor),
//            backgroundView.bottomAnchor.constraint(equalTo: overlay.bottomAnchor),
//            
//            container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
//            container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
//            container.widthAnchor.constraint(equalToConstant: 120),
//            container.heightAnchor.constraint(equalToConstant: 120),
//            
//            spinner.centerXAnchor.constraint(equalTo: container.centerXAnchor),
//            spinner.topAnchor.constraint(equalTo: container.topAnchor, constant: theme.mediumSpacing),
//            
//            loadingLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: theme.smallSpacing),
//            loadingLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: theme.smallSpacing),
//            loadingLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -theme.smallSpacing),
//            loadingLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -theme.smallSpacing)
//        ])
//        
//        return overlay
//    }()
//    
//    public init(library: ResolvedLibrary) {
//        self.library = library
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required public init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    open override func viewDidLoad() {
//        super.viewDidLoad()
//        setupBaseUI()
//    }
//    
//    private func setupBaseUI() {
//        view.backgroundColor = colors.backgroundColor
//        view.addSubview(loadingOverlay)
//        NSLayoutConstraint.activate([
//            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
//            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//    
//    // MARK: - Factory Methods
//    
//    public func createGlassView() -> UIView {
//        let view = UIView()
//        view.backgroundColor = colors.glassSurfaceColor
//        view.layer.cornerRadius = theme.largeCornerRadius
//        
//        if #available(iOS 13.0, *) {
//            let blurEffect = UIBlurEffect(style: colors.isDarkMode ? .systemUltraThinMaterialDark : .systemUltraThinMaterialLight)
//            let blurView = UIVisualEffectView(effect: blurEffect)
//            blurView.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(blurView)
//            
//            NSLayoutConstraint.activate([
//                blurView.topAnchor.constraint(equalTo: view.topAnchor),
//                blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//                blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//                blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//            ])
//            
//            blurView.layer.cornerRadius = theme.largeCornerRadius
//            blurView.clipsToBounds = true
//        }
//        
//        view.addModernShadow(theme: theme)
//        view.addModernBorder(theme: theme)
//        return view
//    }
//    
//    public func createModernButton(title: String, style: ButtonStyle = .primary) -> UIButton {
//        let button = UIButton(type: .system)
//        button.setTitle(title, for: .normal)
//        button.titleLabel?.font = theme.buttonFont
//        button.layer.cornerRadius = theme.mediumCornerRadius
//        button.translatesAutoresizingMaskIntoConstraints = false
//        
//        switch style {
//        case .primary:
//            button.backgroundColor = colors.primaryColor
//            button.setTitleColor(.white, for: .normal)
//            button.addModernShadow(theme: theme, color: colors.primaryColor)
//        case .secondary:
//            button.backgroundColor = colors.glassSurfaceColor
//            button.setTitleColor(colors.primaryColor, for: .normal)
//            button.addModernBorder(theme: theme)
//            button.addModernShadow(theme: theme)
//        case .glass:
//            button.backgroundColor = colors.glassSurfaceColor
//            button.setTitleColor(colors.textPrimaryColor, for: .normal)
//            button.addGlassEffect(theme: theme)
//        case .text:
//            button.backgroundColor = .clear
//            button.setTitleColor(colors.primaryColor, for: .normal)
//        }
//        
//        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
//        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
//        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
//        
//        return button
//    }
//    
//    @objc private func buttonTouchDown(_ button: UIButton) {
//        UIView.animate(withDuration: 0.1) {
//            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//        }
//    }
//    
//    @objc private func buttonTouchUp(_ button: UIButton) {
//        UIView.animate(withDuration: 0.1) {
//            button.transform = .identity
//        }
//    }
//    
//    public func createStyledLabel(text: String, style: LabelStyle = .body) -> UILabel {
//        let label = UILabel()
//        label.text = text
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.numberOfLines = 0
//        
//        switch style {
//        case .heroTitle:
//            label.font = theme.headingFont
//            label.textColor = colors.textPrimaryColor
//        case .title:
//            label.font = theme.titleFont
//            label.textColor = colors.textPrimaryColor
//        case .body:
//            label.font = theme.bodyFont
//            label.textColor = colors.textPrimaryColor
//        case .caption:
//            label.font = theme.captionFont
//            label.textColor = colors.textSecondaryColor
//        }
//        
//        return label
//    }
//    
//    // MARK: - Loading and Error States
//    
//    public func showLoading() {
//        loadingOverlay.isHidden = false
//        loadingOverlay.alpha = 0
//        UIView.animate(withDuration: 0.3) {
//            self.loadingOverlay.alpha = 1
//        }
//    }
//    
//    public func hideLoading() {
//        UIView.animate(withDuration: 0.3, animations: {
//            self.loadingOverlay.alpha = 0
//        }, completion: { _ in
//            self.loadingOverlay.isHidden = true
//        })
//    }
//    
//    public func showError(_ error: Error, title: String = "Error") {
//        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
//        alert.view.tintColor = colors.primaryColor
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
//
//public enum ButtonStyle {
//    case primary, secondary, glass, text
//}
//
//public enum LabelStyle {
//    case heroTitle, title, body, caption
//}
