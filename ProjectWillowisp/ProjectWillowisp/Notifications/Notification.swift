//
//  Notification.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/14/23.
//

import Foundation

enum NotificationType: String, JSONCodable {
    case message
    case like
    case comment
    case app
}

struct WillowNotification: JSONCodable {
    let post_id: UUID?
    let reply_id: UUID?
    let title: String
    let message: String
    let id: UUID
    let post: Post?
}
