//
//  CommentReportRepository.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 26. 12. 2023..
//

import Foundation
import GRDB

class CommentReportRepository {
    
    private let dbQueue = DatabaseManager.shared.dbQueue
    
    func commentReport(articleID: Int64, commentID: Int64) -> CommentReport? {
        return try? dbQueue?.read({ db in
            try CommentReport.filter(CommentReport.Columns.article_id == articleID && CommentReport.Columns.comment_id == commentID).fetchOne(db)
        })
    }
    
    func save(commentReport: CommentReport) throws {
        var commentReport = commentReport
        try dbQueue?.write({ db in
            try commentReport.insert(db)
        })
    }
}
