//
//  ArticleViewModel.swift
//  NewsApp
//
//  Created by Konstantin Bolgar-Danchenko on 04.02.2023.
//

import Foundation

class CellViewModel {
    
    let title: String
    let url: String
    let imageUrl: URL?
    var imageData: Data? = nil
    
    init(title: String, url: String, imageUrl: URL?) {
        self.title = title
        self.url = url
        self.imageUrl = imageUrl
    }
    
    /// Updating count of views in UserDefaults. This method is called each time whenever cell is selected.
    func updateCount(key: String) {
        var currentCount = UserDefaults.standard.value(forKey: key) as? Int ?? 0
        currentCount += 1
        UserDefaults.standard.set(currentCount, forKey: key)
    }
}
