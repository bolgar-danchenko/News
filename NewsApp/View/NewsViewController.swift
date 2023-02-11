//
//  ViewController.swift
//  NewsApp
//
//  Created by Konstantin Bolgar-Danchenko on 04.02.2023.
//

import UIKit

class NewsViewController: UIViewController {

    // MARK: - Properties
    
    private var articles = [Article]()
    private var cellViewModels = [CellViewModel]()
    private var articleViewModels = [ArticleViewModel]()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var refreshButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(refreshView))
        
        return button
    }()
    
    let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = refreshButton
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "News"
        
        // Checking for network availability
        if !NetworkStatus.isConnectedToNetwork() {
            handleNetworkError()
        }
        
        tuneTableView()
        tuneRefreshControl()
        
        fetchNews()
    }
    
    // MARK: - Private
    
    private func tuneTableView() {
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.id)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func tuneRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshView), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    /// Fetching news at launch and after refreshing
    private func fetchNews() {
        loadArticles(initial: true) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    private func loadArticles(initial: Bool, completion: (() -> Void)?) {
        guard !NewsManager.shared.isLoading else { return }
        
        NewsManager.shared.getNews { [weak self] result in
            switch result {
            case .success(let articles):
                if initial {
                    self?.articles.removeAll()
                }
                self?.articles.append(contentsOf: articles)
                self?.setModels(with: articles)
            case .failure(let error):
                print("Failed to load more news: \(error)")
            }
            
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    private func setModels(with articles: [Article]) {
        
        // ViewModel for ArticleTableViewCell
        self.cellViewModels = self.articles.compactMap({
            CellViewModel(
                title: $0.title ?? "No Title",
                url: $0.url ?? "",
                imageUrl: URL(string: $0.urlToImage ?? "")
            )
        })
        
        // ViewModel for ArticleViewController
        self.articleViewModels = self.articles.compactMap({
            ArticleViewModel(
                title: $0.title ?? "No Title",
                content: $0.content ?? "No Description",
                imageUrl: URL(string: $0.urlToImage ?? ""),
                publishedAt: $0.publishedAt ?? "",
                source: $0.source.name ?? "Unknown Source",
                url: URL(string: $0.url ?? ""))
        })
        
        // Refreshing TableView with new data
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    /// Action for refreshButton and UIRefreshControll
    @objc private func refreshView() {
        // Checking for network availability before refreshing
        if NetworkStatus.isConnectedToNetwork() {
            NewsManager.shared.resetCurrentPage()
            articles.removeAll()
            cellViewModels.removeAll()
            articleViewModels.removeAll()
            fetchNews()
        } else {
            handleNetworkError()
        }
    }
    
    /// If network is unavailable, the alert will be presented
    private func handleNetworkError() {
        let alert = UIAlertController(title: "No Internet Connection", message: "Please check your connection and try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }))
        present(alert, animated: true)
    }
    
    /// Progress indicator appears in the TableViewFooter while fetching additional news
    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        
        return footerView
    }
}

// MARK: - TableView Delegate and Data Source

extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.id, for: indexPath) as? ArticleTableViewCell else {
            preconditionFailure("Failed to dequeue reusable cell")
        }
        cell.configure(with: cellViewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Storing views count in UserDefaults with article url as a key, so it is always unique
        cellViewModels[indexPath.row].updateCount(key: cellViewModels[indexPath.row].url)
        
        tableView.reloadData()
        
        // Pushing ArticleViewController with article from selected cell
        let vc = ArticleViewController(viewModel: articleViewModels[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - ScrollView Delegate

// Setting up pagination
extension NewsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - scrollView.frame.size.height) {
            
            guard !articles.isEmpty,
                  !NewsManager.shared.isLoading else { return }
            
            self.tableView.tableFooterView = createSpinnerFooter()
            
            if NetworkStatus.isConnectedToNetwork() {
                loadArticles(initial: false) { [weak self] in
                    self?.tableView.tableFooterView = nil
                }
            } else {
                handleNetworkError()
            }
        }
    }
}
