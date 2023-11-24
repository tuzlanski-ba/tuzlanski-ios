//
//  Article.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 18. 11. 2023..
//

import Foundation

struct Tag: Identifiable, Codable {
    var id: Int64
    var name: String
    var slug: String
}

struct Article: Codable {
    var id: Int64
    var title: String
    var preTitle: String?
    var publishedAt: String
    @BoolFromInt var isGallery: Bool
    @BoolFromInt var hasVideos: Bool
    var sectionID: Int64
    var hasComments: Int?
    var image: ListArticleImage
    var section: ListArticleSection
    var apiURL: String
    var shortText: String?
    var longText: String
    @BoolFromInt var isAdFree: Bool
    var tags: [Tag]
    
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
        case shortText = "short_text"
        case longText = "long_text"
        case isAdFree = "is_ad_free"
        case tags
    }
}
