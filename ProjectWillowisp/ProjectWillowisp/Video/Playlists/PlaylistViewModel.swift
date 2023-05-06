//
//  PlaylistViewModel.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/18/23.
//

import Foundation

final class PlaylistViewModel {

    private var useCreatorPlaylists = true
    
    private var filters: String? = nil
    
    var currentPlaylists: [Playlist] {
        return SocialInteractionService.shared.currentPlaylists.filter { if let filters = filters {
            return $0.name.lowercased().contains(filters) && (useCreatorPlaylists ? $0.user_id == SocialInteractionService.shared.creator_id : $0.user_id != SocialInteractionService.shared.creator_id)
            }
            return (useCreatorPlaylists ? $0.user_id == SocialInteractionService.shared.creator_id : $0.user_id != SocialInteractionService.shared.creator_id)
        }
    }
    
    func fetchPlaylists() async {
        await SocialInteractionService.shared.fetchPlaylists()
    }
    
    func filter(text: String) {
        if text.isEmpty {
            filters = nil
            return
        }
        filters = text.lowercased()
    }
    
    func setUseCreatedPlaylistsOnly(_ value: Bool) {
        useCreatorPlaylists = value
    }
}
