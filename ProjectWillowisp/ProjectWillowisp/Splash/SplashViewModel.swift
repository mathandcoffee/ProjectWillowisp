//
//  SplashViewModel.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 8/6/22.
//

import UIKit
import RevenueCat

final class SplashViewModel: BaseViewModel<SplashState, SplashEvent> {
    
    init() {
        super.init(initialState: SplashState())
    }
    
    func handleAutoLogin(with viewController: UIViewController) async {
        if await AuthenticationService.shared.hasCredentials() {
            _eventHandler.send(.logInSuccess())
            return
        }
        _eventHandler.send(.logInFailed())
    }
    
    func preloadContent() {
        Task {
            let user = await UserProfileService.shared.getCurrentUserProfile()
            guard let currentUserId = user?.id.uuidString else { return }
            Purchases.shared.logIn(currentUserId) { [weak self] purchaserInfo, created, error in
                guard let self = self else { return }
                if let error = error {
                    print(error)
                }
                
                if purchaserInfo?.activeSubscriptions.contains(AuthenticationService.productId) == true {
                    UserDefaults.standard.set(true, forKey: AuthenticationService.productId)
                } else {
                    UserDefaults.standard.set(false, forKey: AuthenticationService.productId)
                }
                Task {
                    await SocialInteractionService.shared.retrievePosts()
                    for post in SocialInteractionService.shared.currentCreatorPosts + SocialInteractionService.shared.currentPremiumPosts {
                        if let media_url = post.media_url {
                            let _ = await CoreDataManager.shared.downloadOrRetrieveImage(imageUrl: media_url)
                        }
                        if let media_url = post.media_thumbnail_url {
                            let _ = await CoreDataManager.shared.downloadOrRetrieveImage(imageUrl: media_url)
                        }
                        if let media_url = post.user.avatar_url {
                            let _ = await CoreDataManager.shared.downloadOrRetrieveImage(imageUrl: media_url)
                        }
                        if let media_url = post.user.cover_image_url {
                            let _ = await CoreDataManager.shared.downloadOrRetrieveImage(imageUrl: media_url)
                        }
                    }
                    self._eventHandler.send(.finishedPreloading())
                }
            }
        }
    }
}
