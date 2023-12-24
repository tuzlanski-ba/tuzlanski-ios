//
//  Bookmark.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 24. 12. 2023..
//

import Foundation
import GRDB

struct Bookmark: Codable, Identifiable, FetchableRecord, MutablePersistableRecord, EncodableRecord {
    static var databaseTableName: String = "bookmark"
    
    var id: Int64? = nil
    var articleID: Int64
    var listArticle: ListArticle
    var addedAt: Int64
    
    enum CodingKeys: String, CodingKey {
        case id
        case articleID = "article_id"
        case listArticle = "list_article_json"
        case addedAt = "added_at"
    }
    
    init(with listArticle: ListArticle) {
        self.articleID = listArticle.id
        self.listArticle = listArticle
        self.addedAt = Int64(Date().timeIntervalSince1970)
    }
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
    
    func encode(to container: inout PersistenceContainer) throws {
        container[Columns.id.name] = id
        container[Columns.articleID.name] = articleID
        container[Columns.listArticleJSON.name] = try JSONEncoder().encode(listArticle)
        container[Columns.addedAt.name] = addedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int64.self, forKey: .id)
        self.articleID = try container.decode(Int64.self, forKey: .articleID)
        self.addedAt = try container.decode(Int64.self, forKey: .addedAt)
        
        let json = try container.decode(String.self, forKey: .listArticle)
        self.listArticle = try JSONDecoder().decode(ListArticle.self, from: Data(json.utf8))
    }
}

extension Bookmark {
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let articleID = Column(CodingKeys.articleID)
        static let listArticleJSON = Column("list_article_json")
        static let addedAt = Column(CodingKeys.addedAt)
    }
}
