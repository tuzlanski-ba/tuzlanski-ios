//
//  IndexResponse.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import Foundation

struct IndexResponse: Codable {
    var top: [ListArticle]
    var vijesti: [ListArticle]
    var biznis: [ListArticle]
    var sport: [ListArticle]
    var magazin: [ListArticle]
    var lifestyle: [ListArticle]
    var automoto: [ListArticle]
    var scitech: [ListArticle]
    var viral: [ListArticle]
    var promo: [ListArticle]
}

struct MenuItem: Codable {
    var id: Int64
    var name: String
    var slug_short: String
    var color: String?
    var color_hex: String?
    var status_code: String?
    var childs: [MenuItem]?
}

struct LatestArticleResponse: Codable {
    
    struct ArticlesResponse: Codable {
        var data: [ListArticle]
    }
    
    var articles: ArticlesResponse
}
