//
//  User.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 5. 12. 2023..
//

import Foundation

struct User: Codable {
    var id: Int64
    var name: String
    var email: String
    var has_verified_email: Bool
    var status_code: String
    var created_at: String
    var country: String?
    var city: String?
}
