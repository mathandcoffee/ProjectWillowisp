//
//  GalleryViewModel.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/12/23.
//

import Foundation

final class GalleryViewModel {
    
    var postToAdd: Post?
    
    private var creatorPosts: [Post] = []
    
    private var filters: String? = nil
    
    var posts: [Post] {
        return creatorPosts.filter { if let filters = filters {
            return ($0.post_text?.lowercased().contains(filters) ?? false || $0.title?.lowercased().contains(filters) ?? false)
            }
            return true
        }
    }
    
    func fetchPosts() async {
        await SocialInteractionService.shared.retrievePosts()
        creatorPosts = SocialInteractionService.shared.currentCreatorPosts.filter {
            if UserProfileService.shared.currentUser?.is_subscribed == false {
                return $0.media_url != nil && !$0.is_subscriber_only_content
            }
            return $0.media_url != nil
        }
    }
    
    func filter(text: String) {
        if text.isEmpty {
            filters = nil
            return
        }
        filters = text.lowercased()
    }
}
