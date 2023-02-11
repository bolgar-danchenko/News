//
//  NewsModel.swift
//  NewsApp
//
//  Created by Konstantin Bolgar-Danchenko on 04.02.2023.
//


struct ApiResponse: Codable {
    let articles: [Article]
}

struct Article: Codable {
    let source: Source
    let title: String?
    let content: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    
    var count: Int?
}

struct Source: Codable {
    let name: String?
}
