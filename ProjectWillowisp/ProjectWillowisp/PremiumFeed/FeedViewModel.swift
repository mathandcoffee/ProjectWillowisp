//
//  DashboardViewModel.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 8/8/22.
//

import Foundation
import Combine
import Realtime

final class FeedViewModel: BaseViewModel<FeedState, FeedEvent> {
    
    private lazy var realtimeSubject = CurrentValueSubject<Message?, Never>(nil)
    lazy var realtimePublisher = realtimeSubject.eraseToAnyPublisher()
    
    private var realtimeSubscription: AnyCancellable?
    
    func subscribeToRealtime() {
        SupabaseProvider.shared.realtimePostChanges.on(.insert, callback: { [weak self] callbackEvent in
            print(callbackEvent)
            
            self?.realtimeSubject.send(callbackEvent)
        })
        SupabaseProvider.shared.realtimePostChanges.subscribe()
        
        realtimeSubscription = realtimePublisher.sink(receiveValue: { _ in
            self._eventHandler.send(.newPostsAvailable)
        })
    }
    
    func fetchPosts() async {
        await SocialInteractionService.shared.retrievePosts()
        let posts = SocialInteractionService.shared.currentPremiumPosts
        _currentState.send(FeedState(createdAt: Date(), posts: posts))
    }
    
    func likePost(post: Post) async {
        
    }
    
    func unsubscribeFromRealtime() {
        SupabaseProvider.shared.realtimePostChanges.unsubscribe()
    }
    
    deinit {
        realtimeSubscription?.cancel()
    }
}
