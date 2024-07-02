//
//  ListArticle.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import Foundation

struct ListArticleImage: Codable {
    var original: String?
    var _440x272: String?
    
    private enum CodingKeys: String, CodingKey {
        case original
        case _440x272 = "440x272"
    }
}

struct ListArticleSection: Codable {
    var name: String
    var path: String
    var slug_short: String
    var color_hex: String
}

struct ListArticle: Codable, Identifiable, Hashable {
    var id: Int64
    var title: String
    var preTitle: String?
    var publishedAt: String
    var isGallery: Int
    var hasVideos: Int
    var sectionID: Int64
    var hasComments: Int?
    var image: ListArticleImage
    var section: ListArticleSection
    var apiURL: String
    var commentsCount: Int
    var url: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case preTitle = "pre_title"
        case publishedAt = "published_at"
        case isGallery = "is_gallery"
        case hasVideos = "has_videos"
        case sectionID = "section_id"
        case hasComments = "has_comments"
        case image
        case section
        case apiURL = "api_url"
        case commentsCount = "comments_count"
        case url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ListArticle, rhs: ListArticle) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - API helper extensions

extension Int {
    
    var bool: Bool {
        return self == 1
    }
}
