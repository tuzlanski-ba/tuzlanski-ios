//
//  NotificationCenter+Extension.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 17. 11. 2023..
//

import Foundation

extension Notification.Name {
    static let menuCategoryPressed = Notification.Name("menuCategoryPressed")
}

extension NotificationCenter {
    
    static func dispatch(notification: Notification.Name, payload: [AnyHashable : Any]?) {
        self.default.post(name: notification, object: nil, userInfo: payload)
    }
    
    static func observe(notification: Notification.Name, handler: @escaping (Notification) -> Void) {
        self.default.addObserver(forName: notification, object: nil, queue: .main, using: handler)
    }
}
