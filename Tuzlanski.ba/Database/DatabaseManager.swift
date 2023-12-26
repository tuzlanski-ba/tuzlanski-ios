//
//  DatabaseManager.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 24. 12. 2023..
//

import Foundation
import GRDB

class DatabaseManager {
    
    static let shared = DatabaseManager()

    private(set) var dbQueue: DatabaseQueue!

    private init() {
        guard let dbPath = try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("db.sqlite")
            .path else { return }
        
        var config = Configuration()
#if DEBUG
        config.prepareDatabase { db in
            db.trace { print($0) }
        }
#endif
        
        dbQueue = try! DatabaseQueue(path: dbPath, configuration: config)
        migrate()
    }

    private func migrate() {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("Bookmark") { db in
            try db.create(table: "bookmark") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("article_id", .integer).notNull().unique()
                t.column("list_article_json", .jsonText).notNull()
                t.column("added_at", .integer).notNull().indexed()
            }
        }
        
        migrator.registerMigration("CommentVote") { db in
            try db.create(table: "comment_vote") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("article_id", .integer).notNull()
                t.column("comment_id", .integer).notNull()
                t.column("type", .integer).notNull()
                t.uniqueKey(["article_id", "comment_id"])
            }
        }
        
        do {
            try migrator.migrate(dbQueue)
        } catch {
            print("Migration error:", error)
        }
    }
}
