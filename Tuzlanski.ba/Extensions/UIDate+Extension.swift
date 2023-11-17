//
//  UIDate+Extension.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 12. 11. 2023..
//

import Foundation

extension Date {
    
    static func format(apiDate: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        formatter.formatterBehavior = .default
        
        guard let date = formatter.date(from: apiDate) else { return apiDate }
       
        formatter.dateFormat = "dd. MMM • HH:mm"
        
        return formatter.string(from: date)
    }
}
