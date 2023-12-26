//
//  CommentVoteRepository.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 25. 12. 2023..
//

import Foundation
import GRDB

class CommentVoteRepository {
    
    private let dbQueue = DatabaseManager.shared.dbQueue
    
    func commentVote(articleID: Int64, commentID: Int64) -> CommentVote? {
        return try? dbQueue?.read({ db in
            try CommentVote.filter(CommentVote.Columns.article_id == articleID && CommentVote.Columns.comment_id == commentID).fetchOne(db)
        })
    }
    
    func save(commentVote: CommentVote) throws {
        var commentVote = commentVote
        try dbQueue?.write({ db in
            try commentVote.insert(db)
        })
    }
}
