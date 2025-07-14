////
////  KnowledgeBaseSidebarViewController.swift
////  ResolvedLibrary
////
////  Created by Olami on 2025-07-13.
////
//
//import UIKit
//
//final class KnowledgeBaseSidebarViewController: BaseViewController {
//    weak var delegate: KnowledgeBaseSidebarDelegate?
//    
//    private var collections: [Collection] = []
//    private var searchResults: [Article] = []
//    private var isSearching = false
//    private var expandedCollections: Set<String> = []
//    
//    // MARK: - UI Components
//    private lazy var headerView: UIView = {
//        let header = createGlassView()
//        header.translatesAutoresizingMaskIntoConstraints = false
//        return header
//    }()
//    
//    private lazy var titleLabel: UILabel = {
//        let label = createStyledLabel(text: "Knowledge Base", style: .title)
//        return label
//    }()
//    
//    private lazy var searchBar: UISearchBar = {
//        let searchBar = UISearchBar()
//        searchBar.translatesAutoresizingMaskIntoConstraints = false
//        searchBar.placeholder = "Search articles and guides..."
//        searchBar.backgroundColor = .clear
//        searchBar.delegate = self
//        return searchBar
//    }()
//    
//    private lazy var contentTableView: UITableView = {
//        let tableView = UITableView()
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.backgroundColor = .clear
//        tableView.separatorStyle = .none
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(CollectionTableViewCell.self, forCellReuseIdentifier: "CollectionCell")
//        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: "ArticleCell")
//        return tableView
//    }()
//    
//    init(library: ResolvedLibrary, delegate: KnowledgeBaseSidebarDelegate?) {
//        self.delegate = delegate
//        super.init(library: library)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//    }
//    
//    private func setupUI() {
//        view.backgroundColor = colors.backgroundColor
//        
//        // Header
//        view.addSubview(headerView)
//        
//        let headerStack = UIStackView(arrangedSubviews: [titleLabel, searchBar])
//        headerStack.translatesAutoresizingMaskIntoConstraints = false
//        headerStack.axis = .vertical
//        headerStack.spacing = theme.mediumSpacing
//        headerView.addSubview(headerStack)
//        
//        // Content
//        view.addSubview(contentTableView)
//        
//        NSLayoutConstraint.activate([
//            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: theme.mediumSpacing),
//            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -theme.mediumSpacing),
//            
//            headerStack.topAnchor.constraint(equalTo: headerView.topAnchor, constant: theme.largeSpacing),
//            headerStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: theme.largeSpacing),
//            headerStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -theme.largeSpacing),
//            headerStack.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -theme.largeSpacing),
//            
//            contentTableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: theme.mediumSpacing),
//            contentTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            contentTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            contentTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//    
//    func updateCollections(_ collections: [Collection]) {
//        self.collections = collections
//        self.isSearching = false
//        contentTableView.reloadData()
//    }
//    
//    func updateSearchResults(_ results: [Article]) {
//        self.searchResults = results
//        self.isSearching = true
//        contentTableView.reloadData()
//    }
//}
//
//// MARK: - UITableViewDataSource
//
//extension KnowledgeBaseSidebarViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if isSearching {
//            return searchResults.count
//        } else {
//            return getTotalRowCount()
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if isSearching {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleTableViewCell
//            cell.configure(with: searchResults[indexPath.row], theme: theme, isSearchResult: true)
//            return cell
//        } else {
//            return getCollectionCell(for: indexPath, in: tableView)
//        }
//    }
//    
//    private func getTotalRowCount() -> Int {
//        var count = 0
//        for collection in collections {
//            count += 1 // Collection itself
//            if expandedCollections.contains(collection.id) {
//                count += collection.articles?.count ?? 0
//            }
//        }
//        return count
//    }
//    
//    private func getCollectionCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
//        var currentIndex = 0
//        
//        for collection in collections {
//            if currentIndex == indexPath.row {
//                // This is a collection row
//                let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! CollectionTableViewCell
//                let isExpanded = expandedCollections.contains(collection.id)
//                cell.configure(with: collection, theme: theme, isExpanded: isExpanded)
//                return cell
//            }
//            currentIndex += 1
//            
//            if expandedCollections.contains(collection.id) {
//                let articleCount = collection.articles?.count ?? 0
//                if indexPath.row < currentIndex + articleCount {
//                    // This is an article row
//                    let articleIndex = indexPath.row - currentIndex
//                    if let article = collection.articles?[articleIndex] {
//                        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleTableViewCell
//                        cell.configure(with: article, theme: theme, isSearchResult: false)
//                        return cell
//                    }
//                }
//                currentIndex += articleCount
//            }
//        }
//        
//        // Fallback
//        return UITableViewCell()
//    }
//}
//
//// MARK: - UITableViewDelegate
//
//extension KnowledgeBaseSidebarViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        if isSearching {
//            let article = searchResults[indexPath.row]
//            delegate?.sidebarDidSelectArticle(article)
//        } else {
//            handleCollectionSelection(at: indexPath)
//        }
//    }
//    
//    private func handleCollectionSelection(at indexPath: IndexPath) {
//        var currentIndex = 0
//        
//        for collection in collections {
//            if currentIndex == indexPath.row {
//                // Toggle collection expansion
//                if expandedCollections.contains(collection.id) {
//                    expandedCollections.remove(collection.id)
//                } else {
//                    expandedCollections.insert(collection.id)
//                }
//                contentTableView.reloadData()
//                delegate?.sidebarDidSelectCollection(collection)
//                return
//            }
//            currentIndex += 1
//            
//            if expandedCollections.contains(collection.id) {
//                let articleCount = collection.articles?.count ?? 0
//                if indexPath.row < currentIndex + articleCount {
//                    // Selected an article
//                    let articleIndex = indexPath.row - currentIndex
//                    if let article = collection.articles?[articleIndex] {
//                        delegate?.sidebarDidSelectArticle(article)
//                        return
//                    }
//                }
//                currentIndex += articleCount
//            }
//        }
//    }
//}
//
//// MARK: - UISearchBarDelegate
//
//extension KnowledgeBaseSidebarViewController: UISearchBarDelegate {
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        delegate?.sidebarDidPerformSearch(searchText)
//    }
//    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//    }
//}
