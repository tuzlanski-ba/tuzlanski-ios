//
//  CommentVote.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 25. 12. 2023..
//

import Foundation
import GRDB

enum CommentVoteType: Int, Codable {
    case upvote = 1
    case downvote = 2
}

struct CommentVote: Codable, Identifiable, FetchableRecord, MutablePersistableRecord {
    static var databaseTableName: String = "comment_vote"
    
    var id: Int64? = nil
    var article_id: Int64
    var comment_id: Int64
    var type: CommentVoteType
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

extension CommentVote {
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let article_id = Column(CodingKeys.article_id)
        static let comment_id = Column(CodingKeys.comment_id)
        static let listArticleJSON = Column(CodingKeys.type)
    }
}
