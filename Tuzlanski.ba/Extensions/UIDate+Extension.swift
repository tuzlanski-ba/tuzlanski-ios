//
//  UIDate+Extension.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 12. 11. 2023..
//

import Foundation

extension Date {
    
    static func date(apiDate: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        formatter.formatterBehavior = .default
        
        return formatter.date(from: apiDate)
    }
    
    static func format(apiDate: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        formatter.formatterBehavior = .default
        formatter.locale = Locale(identifier: "bs")
        
        guard let date = formatter.date(from: apiDate) else { return apiDate }
       
        formatter.dateFormat = "dd. MMM • HH:mm"
        
        return formatter.string(from: date)
    }
    
    static func formatToDate(apiDate: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        formatter.formatterBehavior = .default
        formatter.locale = Locale(identifier: "bs")

        guard let date = formatter.date(from: apiDate) else { return apiDate }
       
        formatter.dateFormat = "dd.MM.yyyy."
        
        return formatter.string(from: date)
    }
    
    static func formatToFullDate(apiDate: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        formatter.formatterBehavior = .default
        formatter.locale = Locale(identifier: "bs")

        guard let date = formatter.date(from: apiDate) else { return apiDate }
       
        formatter.dateFormat = "dd.MM.yyyy. HH:mm"
        
        return formatter.string(from: date)
    }
    
    static func formatToTime(apiDate: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        formatter.formatterBehavior = .default
        
        guard let date = formatter.date(from: apiDate) else { return apiDate }
       
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: date)
    }
    
    static func formatRelativeDate(_ date: Date) -> String {
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: currentDate)

        if let dayDifference = components.day, dayDifference > 0 {
            // More than 24 hours, display full date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy. HH:mm"
            dateFormatter.locale = Locale(identifier: "bs")
            return dateFormatter.string(from: date)
        } else if let hourDifference = components.hour, hourDifference > 0 {
            // More than 1 hour, display hours and minutes ago
            let minuteDifference = components.minute ?? 0
            return "prije \(hourDifference) sati i \(minuteDifference) minuta"
        } else if let minuteDifference = components.minute, minuteDifference > 0 {
            // Less than 1 hour, display minutes ago
            return "prije \(minuteDifference) minuta"
        } else {
            // The date is in the future or within the same minute, handle accordingly
            return "prije par sekundi"
        }
    }
}
