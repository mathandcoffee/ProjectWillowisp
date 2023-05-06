//
//  NewPlaylistViewModel.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/19/23.
//

import Foundation

final class NewPlaylistViewModel {
    
    private let postToAdd: Post
    
    init(post: Post) {
        self.postToAdd = post
    }
    
    private let uuid = UUID()
    
    func savePlaylist(name: String) async {
        guard let user = UserProfileService.shared.currentUser else { return }
        let playlistItem =
            PlaylistItemRequestPacket(
                post: postToAdd, playlistId: uuid
            )
        let playlistDatabase = SupabaseProvider.shared.playlistsDatabase
        let playlistItemsDatabase = SupabaseProvider.shared.playlistItemsDatabase
        do {
            let _ = try await playlistDatabase.insert(values: PlaylistRequestPacket(id: uuid, name: name, user: user)).execute().value
            
            let _ = try await playlistItemsDatabase.insert(values: playlistItem).execute().value
        } catch {
            print("ERROR CREATING PLAYLIST \(error)")
        }
    }
}
