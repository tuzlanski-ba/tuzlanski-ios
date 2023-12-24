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
    
    @Storage(key: "article_font_size", defaultValue: 15)
    static var articleFontSize: Int
    
    @Storage(key: "categories", defaultValue: [])
    static var categories: [Category]
}
