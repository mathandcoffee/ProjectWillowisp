//
//  BaseTabBarController.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 3/22/23.
//

import UIKit
import Combine

final class BaseTabBarController: UITabBarController {
    
    private var subscription: AnyCancellable?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let videoListVC = ContentListViewController()
        videoListVC.tabBarItem = UITabBarItem(
            title: "Content",
            image: UIImage(systemName: "video"),
            selectedImage: UIImage(systemName: "video.fill"))
        
        let dashboardVC = GalleryVC(selectionEnabled: false)
        dashboardVC.tabBarItem = UITabBarItem(
            title: "Gallery",
            image: UIImage(systemName: "photo.stack"),
            selectedImage: UIImage(systemName: "photo.stack.fill"))
        
        let playlistVC = PlaylistViewController()
        playlistVC.tabBarItem = UITabBarItem(
            title: "Playlists",
            image: UIImage(systemName: "list.bullet.rectangle.portrait"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.portrait.fill"))
        
        tabBar.tintColor = .onBackground
        tabBar.unselectedItemTintColor = .onBackground.withAlphaComponent(0.5)
        tabBar.backgroundColor = .surface
        
        viewControllers = [
            videoListVC,
            dashboardVC,
            playlistVC
        ]
        
        if UserProfileService.shared.currentUser?.is_subscribed == false {
            let premiumVC: UIViewController
            premiumVC = PremiumVC()
            premiumVC.tabBarItem = UITabBarItem(
                title: "Premium",
                image: UIImage(systemName: "star.bubble"),
                selectedImage: UIImage(systemName: "star.bubble.fill"))
            viewControllers?.insert(premiumVC, at: 1)
        }
        
        subscription = AuthenticationService.shared.authPublisher.sink(receiveValue: {
            if !$0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.dismiss(animated: true)
                }
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
}
