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

struct GalleryImage: Identifiable, Codable {
    
    struct Style: Codable {
        var _120x88: String
        var _440x272: String
        var _676x617: String
        var _1200x744: String
        var original: String
        
        private enum CodingKeys: String, CodingKey {
            case _120x88 = "120x88"
            case _440x272 = "440x272"
            case _676x617 = "676x617"
            case _1200x744 = "1200x744"
            case original
        }
    }
    
    var id: Int64
    var is_main: Int
    var title: String
    var image_file_name: String
    var author: String
    var styles: Style
}

struct Article: Codable {
    
    struct Author: Codable {
        var name: String
    }
    
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
    var shortText: String?
    var longText: String
    var isAdFree: Int
    var tags: [Tag]
    var commentsCount: Int
    var url: String
    var _images: [GalleryImage]?
    var author: Author
    
    var images: [GalleryImage] {
        return _images ?? []
    }
    
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
        case commentsCount = "comments_count"
        case url
        case _images = "images"
        case author
    }
    
    func toListArticle() -> ListArticle {
        return ListArticle(id: id, title: title, preTitle: preTitle, publishedAt: publishedAt, isGallery: isGallery, hasVideos: hasVideos, sectionID: sectionID, hasComments: hasComments, image: image, section: section, apiURL: apiURL, commentsCount: commentsCount, url: url)
    }
    
    func body() -> String {
        var shortText = self.shortText ?? ""
        if !shortText.isEmpty {
            shortText = "<strong>\(shortText)</strong>\r\n"
        }
        
        return shortText + self.longText
    }
}
