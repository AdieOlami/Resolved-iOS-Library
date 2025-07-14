////
////  KnowledgeBaseViewController.swift
////  ResolvedLibrary
////
////  Created by Olami on 2025-07-13.
////
//
//import UIKit
//
//public final class KnowledgeBaseViewController: BaseViewController {
//    public weak var delegate: KnowledgeBaseViewControllerDelegate?
//    private let collectionId: String?
//    
//    private var collections: [Collection] = []
//    private var searchResults: [Article] = []
//    private var selectedArticleId: String?
//    private var isSearching = false
//    private var expandedCollections: Set<String> = []
//    
//    // MARK: - UI Components
//    private lazy var splitViewController: UISplitViewController = {
//        let splitVC = UISplitViewController(style: .doubleColumn)
//        splitVC.preferredDisplayMode = .oneBesideSecondary
//        splitVC.delegate = self
//        return splitVC
//    }()
//    
//    private lazy var sidebarViewController: KnowledgeBaseSidebarViewController = {
//        return KnowledgeBaseSidebarViewController(library: library, delegate: self)
//    }()
//    
//    private lazy var detailViewController: KnowledgeBaseDetailViewController = {
//        return KnowledgeBaseDetailViewController(library: library)
//    }()
//    
//    public init(
//        library: ResolvedLibrary,
//        collectionId: String? = nil,
//        delegate: KnowledgeBaseViewControllerDelegate? = nil
//    ) {
//        self.collectionId = collectionId
//        self.delegate = delegate
//        super.init(library: library)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        loadCollections()
//    }
//    
//    private func setupUI() {
//        title = "Knowledge Base"
//        
//        // Setup split view controller
//        addChild(splitViewController)
//        view.addSubview(splitViewController.view)
//        splitViewController.view.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            splitViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
//            splitViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            splitViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            splitViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//        
//        splitViewController.didMove(toParent: self)
//        
//        // Set view controllers
//        let sidebarNav = UINavigationController(rootViewController: sidebarViewController)
//        let detailNav = UINavigationController(rootViewController: detailViewController)
//        
//        splitViewController.setViewController(sidebarNav, for: .primary)
//        splitViewController.setViewController(detailNav, for: .secondary)
//    }
//    
//    private func loadCollections() {
//        showLoading()
//        
//        let params = CollectionListParams(includeArticleCounts: true)
//        
//        library.sdk.knowledgeBase.getCollections(params: params) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.hideLoading()
//                
//                switch result {
//                case .success(let response):
//                    self?.collections = response.data ?? []
//                    self?.sidebarViewController.updateCollections(self?.collections ?? [])
//                    
//                case .failure(let error):
//                    self?.showError(error)
//                    self?.delegate?.knowledgeBaseViewController(self!, didEncounterError: error)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - UISplitViewControllerDelegate
//
//extension KnowledgeBaseViewController: UISplitViewControllerDelegate {
//    public func splitViewController(
//        _ splitViewController: UISplitViewController,
//        collapseSecondary secondaryViewController: UIViewController,
//        onto primaryViewController: UIViewController
//    ) -> Bool {
//        return selectedArticleId == nil
//    }
//}
//
//// MARK: - KnowledgeBaseSidebarDelegate
//
//extension KnowledgeBaseViewController: KnowledgeBaseSidebarDelegate {
//    func sidebarDidSelectArticle(_ article: Article) {
//        selectedArticleId = article.id
//        detailViewController.displayArticle(article)
//        delegate?.knowledgeBaseViewController(self, didSelectArticle: article)
//    }
//    
//    func sidebarDidSelectCollection(_ collection: Collection) {
//        delegate?.knowledgeBaseViewController(self, didSelectCollection: collection)
//    }
//    
//    func sidebarDidPerformSearch(_ query: String) {
//        // Handle search
//        isSearching = !query.isEmpty
//        if isSearching {
//            performSearch(query: query)
//        }
//    }
//    
//    private func performSearch(query: String) {
//        let params = SearchParams(query: query, limit: 20)
//        
//        library.sdk.knowledgeBase.searchArticles(params: params) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    self?.searchResults = response.data ?? []
//                    self?.sidebarViewController.updateSearchResults(self?.searchResults ?? [])
//                    
//                case .failure(let error):
//                    self?.showError(error)
//                    self?.delegate?.knowledgeBaseViewController(self!, didEncounterError: error)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Knowledge Base Sidebar Protocol
//
//protocol KnowledgeBaseSidebarDelegate: AnyObject {
//    func sidebarDidSelectArticle(_ article: Article)
//    func sidebarDidSelectCollection(_ collection: Collection)
//    func sidebarDidPerformSearch(_ query: String)
//}
