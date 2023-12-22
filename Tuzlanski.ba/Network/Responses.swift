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

struct ArticleResponse: Codable {
    var article: Article
}

struct LoginResponse: Codable {
    var user: User
    var token: String
}

struct FailLoginResponse: Codable {
    var message: String
}

struct InputErrorResponse: Codable, Error {
    var errors: [String: [String]]
}

struct CommentReportResponse: Codable {
    var comment_id: Int64
    var type: String
    var ip: String
    var user_id: Int64
    var uid: String
    var id: Int64
}

struct UserCommentsResponse: Codable {
    
    struct UserComment: Codable {
        var id: Int64
        var name: String
        var content: String
        var upvotes: Int
        var downvotes: Int
        var created_at: String
        var article_id: Int64
    }
    
    var comments: [UserComment]
}

struct PasswordChangeResponse: Codable {
    var message: String
    var user: User
}
