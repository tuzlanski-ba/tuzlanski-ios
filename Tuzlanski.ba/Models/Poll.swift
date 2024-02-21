//
//  Poll.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 10. 2. 2024..
//

import Foundation
import GRDB

struct Poll: Codable {
    var id: Int64
    var question: String
    var user_can_vote: Bool
    var total_votes: Int
    var created_at: String
    var options: [Option]
    struct Option: Codable {
        var id: Int64
        var poll_id: Int64
        var name: String
        var color: String
        var r_votes_count: Int
    }
}

struct PollVote: Codable, Identifiable, FetchableRecord, MutablePersistableRecord, EncodableRecord {
    static var databaseTableName: String = "poll_vote"
    
    var id: Int64? = nil
    var articleID: Int64
    var pollID: Int64
    var addedAt: Int64
    
    enum CodingKeys: String, CodingKey {
        case id
        case articleID = "article_id"
        case pollID = "poll_id"
        case addedAt = "added_at"
    }
    
    init(articleID: Int64, pollID: Int64) {
        self.articleID = articleID
        self.pollID = pollID
        self.addedAt = Int64(Date().timeIntervalSince1970)
    }
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

extension PollVote {
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let articleID = Column(CodingKeys.articleID)
        static let pollID = Column(CodingKeys.pollID)
        static let addedAt = Column(CodingKeys.addedAt)
    }
}
