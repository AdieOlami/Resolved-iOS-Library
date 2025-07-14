////
////  FAQListViewController.swift
////  ResolvedLibrary
////
////  Created by Olami on 2025-07-13.
////
//
//import UIKit
//
//public final class FAQListViewController: BaseViewController {
//    public weak var delegate: FAQListViewControllerDelegate?
//    private let category: String?
//    private var faqs: [FAQ] = []
//    private var filteredFAQs: [FAQ] = []
//    private var currentPage = 1
//    private let pageSize = 20
//    private var isLoading = false
//    private var hasMorePages = true
//    
//    // MARK: - UI Components
//    private lazy var tableView: UITableView = {
//        let tableView = UITableView()
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.backgroundColor = .clear
//        tableView.separatorStyle = .none
//        tableView.register(FAQTableViewCell.self, forCellReuseIdentifier: "FAQCell")
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
//        return tableView
//    }()
//    
//    private lazy var searchController: UISearchController = {
//        let controller = UISearchController(searchResultsController: nil)
//        controller.searchResultsUpdater = self
//        controller.obscuresBackgroundDuringPresentation = false
//        controller.searchBar.placeholder = "Search FAQs..."
//        controller.searchBar.backgroundColor = colors.backgroundColor
//        return controller
//    }()
//    
//    public init(
//        library: ResolvedLibrary,
//        category: String? = nil,
//        delegate: FAQListViewControllerDelegate? = nil
//    ) {
//        self.category = category
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
//        loadFAQs()
//    }
//    
//    private func setupUI() {
//        title = category ?? "FAQs"
//        navigationItem.searchController = searchController
//        navigationItem.hidesSearchBarWhenScrolling = false
//        
//        view.addSubview(tableView)
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//    
//    private func loadFAQs(reset: Bool = false) {
//        guard !isLoading else { return }
//        
//        if reset {
//            currentPage = 1
//            hasMorePages = true
//            faqs.removeAll()
//        }
//        
//        guard hasMorePages else { return }
//        
//        isLoading = true
//        if faqs.isEmpty {
//            showLoading()
//        }
//        
//        let params = FAQListParams(
//            category: category,
//            status: .published,
//            page: currentPage,
//            limit: pageSize,
//            sortBy: "order",
//            sortOrder: "asc"
//        )
//        
//        library.sdk.faq.getFAQs(params: params) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                self?.hideLoading()
//                
//                switch result {
//                case .success(let response):
//                    if let newFAQs = response.data {
//                        if reset {
//                            self?.faqs = newFAQs
//                        } else {
//                            self?.faqs.append(contentsOf: newFAQs)
//                        }
//                    }
//                    
//                    self?.hasMorePages = response.hasMorePages
//                    self?.currentPage += 1
//                    self?.updateFilteredFAQs()
//                    self?.tableView.reloadData()
//                    
//                case .failure(let error):
//                    self?.showError(error)
//                    self?.delegate?.faqListViewController(self!, didEncounterError: error)
//                }
//            }
//        }
//    }
//    
//    private func updateFilteredFAQs() {
//        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
//            filteredFAQs = faqs.filter { faq in
//                faq.question.localizedCaseInsensitiveContains(searchText) ||
//                faq.answer.localizedCaseInsensitiveContains(searchText)
//            }
//        } else {
//            filteredFAQs = faqs
//        }
//    }
//}
//
//// MARK: - UITableViewDataSource
//
//extension FAQListViewController: UITableViewDataSource {
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return filteredFAQs.count
//    }
//    
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "FAQCell", for: indexPath) as! FAQTableViewCell
//        cell.configure(with: filteredFAQs[indexPath.row], theme: theme)
//        return cell
//    }
//}
//
//// MARK: - UITableViewDelegate
//
//extension FAQListViewController: UITableViewDelegate {
//    
//    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let faq = filteredFAQs[indexPath.row]
//        delegate?.faqListViewController(self, didSelectFAQ: faq)
//    }
//    
//    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        // Load more when reaching the last few cells
//        if indexPath.row >= filteredFAQs.count - 3 && !searchController.isActive {
//            loadFAQs()
//        }
//        
//        // Add fade-in animation
//        cell.alpha = 0
//        cell.transform = CGAffineTransform(translationX: 0, y: 20)
//        
//        UIView.animate(
//            withDuration: 0.5,
//            delay: TimeInterval(indexPath.row % 5) * 0.1,
//            usingSpringWithDamping: 0.8,
//            initialSpringVelocity: 0,
//            options: [.curveEaseOut],
//            animations: {
//                cell.alpha = 1
//                cell.transform = .identity
//            }
//        )
//    }
//}
//
//// MARK: - UISearchResultsUpdating
//
//extension FAQListViewController: UISearchResultsUpdating {
//    public func updateSearchResults(for searchController: UISearchController) {
//        updateFilteredFAQs()
//        tableView.reloadData()
//    }
//}
