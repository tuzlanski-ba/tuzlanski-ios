//
//  ListArticle.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import Foundation

struct ListArticleImage: Codable {
    var original: String
}

struct ListArticleSection: Codable {
    var name: String
    var path: String
    var slug_short: String
    var color_hex: String
}

struct ListArticle: Codable {
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
    }
}

@propertyWrapper
struct BoolFromInt: Codable {
    var wrappedValue: Bool
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let intValue = try container.decode(Int.self)
        switch intValue {
        case 0: wrappedValue = false
        case 1: wrappedValue = true
        default: throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected `0` or `1` but received `\(intValue)`")
        }
    }
}
