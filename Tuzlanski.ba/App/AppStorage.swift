//
//  AppStorage.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 12. 12. 2023..
//

import Foundation

struct AppStorage {
    
    @Storage(key: "user", defaultValue: nil)
    static var user: User?
}
