//
//  CommentReport.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 26. 12. 2023..
//

import Foundation
import GRDB

struct CommentReport: Codable, Identifiable, FetchableRecord, MutablePersistableRecord {
    static var databaseTableName: String = "comment_report"
    
    var id: Int64? = nil
    var article_id: Int64
    var comment_id: Int64
    var type: CommentReportType
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

extension CommentReport {
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let article_id = Column(CodingKeys.article_id)
        static let comment_id = Column(CodingKeys.comment_id)
        static let type = Column(CodingKeys.type)
    }
}
