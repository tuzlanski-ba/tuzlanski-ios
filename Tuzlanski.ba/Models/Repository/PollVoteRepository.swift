//
//  PollVoteRepository.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 21. 2. 2024..
//

import Foundation
import GRDB

class PollVoteRepository {
    
    private let dbQueue = DatabaseManager.shared.dbQueue
    
    func pollVote(articleID: Int64, pollID: Int64) -> PollVote? {
        return try? dbQueue?.read({ db in
            try PollVote.filter(PollVote.Columns.articleID == articleID && PollVote.Columns.pollID == pollID).fetchOne(db)
        })
    }
    
    func save(poll: PollVote) throws {
        var poll = poll
        try dbQueue?.write({ db in
            try poll.insert(db)
        })
    }
}
