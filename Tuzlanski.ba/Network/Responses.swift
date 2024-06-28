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

struct MenuItemWithParent: Codable {
    var menuItem: MenuItem
    var parent: MenuItem?
}

struct LatestArticleResponse: Codable {
    
    struct ArticlesResponse: Codable {
        var data: [ListArticle]
    }
    
    var articles: ArticlesResponse
}

struct ArticleResponse: Codable {
    var article: Article
    var related: [ListArticle]
    var latestNewsPortal: [ListArticle]?
    var mostReadsPortal: [ListArticle]?
    
    private enum CodingKeys: String, CodingKey {
        case article
        case related
        case latestNewsPortal = "latest_news_portal"
        case mostReadsPortal = "most_reads_portal"
    }
}

struct LoginResponse: Codable {
    var user: User
    var token: String
}

struct MessageResponse: Codable {
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
    
    struct Article: Codable {
        var id: Int64
        var title: String
        var pre_title: String?
        var published_at: String
        var url: String
        var api_url: String
        var has_videos: Int
        var is_gallery: Int
        var section_id: Int64
        var image: ListArticleImage
        var comments_count: Int
        
        func toListArticle(section: ListArticleSection) -> ListArticle {
            return ListArticle(id: id, title: title, preTitle: pre_title, publishedAt: published_at, isGallery: is_gallery, hasVideos: has_videos, sectionID: section_id, hasComments: 1, image: image, section: section, apiURL: api_url, commentsCount: comments_count, url: url)
        }
    }
    
    struct UserComment: Codable {
        var id: Int64
        var name: String
        var content: String
        var upvotes: Int
        var downvotes: Int
        var created_at: String
        var article_id: Int64
        var article: Article
    }
    
    var comments: [UserComment]
}

struct PasswordChangeResponse: Codable {
    var message: String
    var user: User
}
