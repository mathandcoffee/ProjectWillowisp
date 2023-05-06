//
//  VideoListViewModel.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/7/23.
//

import Foundation

final class ContentListViewModel: BaseViewModel<VideoListState, VideoListEvent> {
    
    var postToAdd: Post?
    
    var currentVideos: [Post] {
        return SocialInteractionService.shared.currentCreatorPosts
    }
    
    func fetchContent() async {
        await SocialInteractionService.shared.retrievePosts()
        let videos = SocialInteractionService.shared.currentCreatorPosts
        _currentState.send(VideoListState(createdAt: Date(), videos: videos))
    }
    
    func getVideo(path: String) async -> Video? {
        return await CoreDataManager.shared.saveOrRetrieveVideoReference(path: path)
    }
}
