//
//  Logging.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import OSLog

struct Log {
    fileprivate static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs Network API related operations.
    static let api = Logger(subsystem: subsystem, category: "api")
}
