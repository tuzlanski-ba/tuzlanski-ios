//
//  Category.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 14. 11. 2023..
//

import Foundation

struct Category: Identifiable, Codable {
    var id: Int64
    var slug: String
    var name: String
    var color: String = ""
    var subcategories: [Category] = []
}
