//
//  NewsManager.swift
//  NewsApp
//
//  Created by Konstantin Bolgar-Danchenko on 04.02.2023.
//

import Foundation

class NewsManager {
    
    static let shared = NewsManager()
    
    // The following two properties are used to correctly process pagination
    private var currentPage: Int?
    public private(set) var isLoading: Bool = false
    
    private let urlString = "https://newsapi.org/v2/everything?domains=wsj.com&apiKey=4284fbbf091e43c9b535d40c10d778bd&pageSize=20"
    
    /// Fetching news from NewsAPI
    public func getNews(completion: @escaping (Result<[Article], Error>) -> Void) {
        
        isLoading = true
        
        if let currentPage = currentPage {
            self.currentPage = currentPage + 1
        } else {
            self.currentPage = 1
        }
        
        guard let currentPage else { return }
        
        // Adding currentPage to urlString
        let urlString = urlString + "&page=\(currentPage)"
        guard let url = URL(string: urlString) else { return }
        
        // URLRequest cache policy is used to cache news and show them if network connection is missing
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .returnCacheDataDontLoad
        
        if NetworkStatus.isConnectedToNetwork() {
            urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        }
        
        // Fetching data with URLRequest
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, error in
            
            if let error {
                completion(.failure(error))
                self?.isLoading = false
                
            } else if let data {
                
                do {
                    let result = try JSONDecoder().decode(ApiResponse.self, from: data)
                    
                    let newArticles = result.articles
                    
                    completion(.success(newArticles))
                    self?.isLoading = false
                } catch {
                    completion(.failure(error))
                    self?.isLoading = false
                }
            }
        }
        task.resume()
    }
    
    /// Reseting currentPage to nil, so articles will be downloaded from the first page again
    func resetCurrentPage() {
        currentPage = nil
    }
}
