//
//  ArticleViewModel.swift
//  NewsApp
//
//  Created by Konstantin Bolgar-Danchenko on 04.02.2023.
//

import Foundation

class ArticleViewModel {
    
    let title: String
    let content: String
    let publishedAt: String
    let source: String
    let url: URL?
    let imageUrl: URL?
    
    init(title: String, content: String, imageUrl: URL?, publishedAt: String, source: String, url: URL?) {
        self.title = title
        self.content = content
        self.publishedAt = publishedAt
        self.source = source
        self.url = url
        self.imageUrl = imageUrl
    }
}
