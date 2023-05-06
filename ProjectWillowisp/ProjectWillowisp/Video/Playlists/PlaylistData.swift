//
//  PlaylistData.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/18/23.
//

import Foundation

final class PlaylistItemRequestPacket: JSONCodable {
    let id: UUID
    let playlist_id: UUID
    let post_id: UUID
    
    init(post: Post, playlistId: UUID) {
        id = UUID()
        playlist_id = playlistId
        post_id = post.id
    }
}

final class PlaylistRequestPacket: JSONCodable {
    let id: UUID
    let name: String
    let user_id: UUID
    let is_public: Bool
    
    init(id: UUID, name: String, user: User) {
        self.id = id
        user_id = user.id
        is_public = false
        self.name = name
    }
}

struct PlaylistItem: JSONCodable {
    let id: UUID
    let playlist_id: UUID
    let post_id: UUID
    let post: Post?
}

struct Playlist: JSONCodable {
    let name: String
    let id: UUID
    let user_id: UUID
    let is_public: Bool
    var playlistItems: [PlaylistItem]
}
