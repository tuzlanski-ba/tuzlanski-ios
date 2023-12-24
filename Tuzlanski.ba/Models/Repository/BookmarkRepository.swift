//
//  BookmarkRepository.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 24. 12. 2023..
//

import Foundation
import GRDB

class BookmarkRepository {
    
    private let dbQueue = DatabaseManager.shared.dbQueue
    
    func bookmark(articleID: Int64) -> Bookmark? {
        return try? dbQueue?.read({ db in
            try Bookmark.filter(Bookmark.Columns.articleID == articleID).fetchOne(db)
        })
    }
    
    func bookmarks() -> [Bookmark] {
        return (try? dbQueue?.read({ db in
            try Bookmark.order(Bookmark.Columns.addedAt.desc).fetchAll(db)
        })) ?? []
    }
    
    func remove(bookmark: Bookmark) {
        let _ = try? dbQueue?.write({ db in
            try bookmark.delete(db)
        })
    }
    
    func save(bookmark: Bookmark) throws {
        var bookmark = bookmark
        try dbQueue?.write({ db in
            try bookmark.insert(db)
        })
    }
}
