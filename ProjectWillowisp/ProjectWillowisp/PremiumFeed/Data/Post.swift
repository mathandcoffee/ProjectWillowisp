//
//  Post.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 3/23/23.
//

import Foundation

final class Post: JSONCodable {
    let id: UUID
    let title: String?
    var post_text: String?
    let media_url: String?
    let media_type: MediaType?
    var likes: [Like]?
    var comments: [Reply]?
    let created_at: String
    let creator_id: UUID
    let media_aspect: Double?
    let media_thumbnail_url: String?
    let is_subscriber_only_content: Bool
    let duration: String?
    let is_pinned: Bool
    let user: User
    
    func getSize() -> Int { return (comments?.count ?? 0) + 1 }
}

final class Reply: JSONCodable {
    let id: UUID
    let post_id: UUID
    let message: String?
    let gif_id: String?
    let user_id: UUID
    let level: Int
    let gif_aspect_ratio: Double?
    let user: User?
    var likes: [Like]?
    
    init(id: UUID, post_id: UUID, message: String?, gif_id: String?, user_id: UUID, level: Int, gif_aspect_ratio: Double, user: User?, likes: [Like]?) {
        self.id = id
        self.post_id = post_id
        self.message = message
        self.gif_id = gif_id
        self.user_id = user_id
        self.level = level
        self.user = user
        self.likes = likes
        self.gif_aspect_ratio = gif_aspect_ratio
    }
}

struct Like: JSONCodable {
    let reply_id: UUID?
    let post_id: UUID?
    let user_id: UUID
}

enum MediaType: String, JSONCodable {
    case image
    case gif
    case video
    case none
}

struct Media: JSONCodable {
    let url: String
    let height: Int?
    let width: Int?
    let durationMs: Int?
    let type: MediaType
}
