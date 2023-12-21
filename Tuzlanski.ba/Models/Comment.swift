//
//  Comment.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 16. 12. 2023..
//

import Foundation

enum CommentReportType: Int, CaseIterable, Identifiable {
    case insult = 1
    case ad = 2
    case spam = 3
    
    var id: RawValue {
        rawValue
    }
    
    var name: String {
        switch self {
        case .insult:
            return "Vrijeđanje"
        case .ad:
            return "Reklama"
        case .spam:
            return "Spam"
        }
    }
}

struct Comment: Codable {
    var id: Int64
    var name: String
    var content: String
    var upvotes: Int
    var downvotes: Int
    var created_at: String
    var author_id: Int64
    var thread_id: Int64
    var subcomments: [Comment]?
}
