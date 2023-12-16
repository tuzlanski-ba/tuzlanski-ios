//
//  String+Extension.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 15. 12. 2023..
//

import Foundation

extension String {
    
    func cleaned() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var initials: String {
        return self.components(separatedBy: " ")
            .reduce("") {
                ($0.isEmpty ? "" : "\($0.first?.lowercased() ?? "")") +
                ($1.isEmpty ? "" : "\($1.first?.lowercased() ?? "")")
            }
    }
}
