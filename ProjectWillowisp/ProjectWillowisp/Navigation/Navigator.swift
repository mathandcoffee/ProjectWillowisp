//
//  NavigationService.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 11/8/21.
//

import UIKit

enum ViewBuilder {
    case splashScreen
    case signUp
    case displayName
    case profilePicture
    case coverPhoto
    case main
    case dashboard
    case accountSettings
    case account
    case notificationsSettings
    case notifications
    case privacy
    case resources
    case newPost
    case gallerySelection
    case giphy
    case commentOnPost
    case webView
    case bio
    case instructions
    case playlistList
    case playlist
    case premium
}

extension UIViewController {
    
    func navigateToWeb(
        header: String,
        url: String,
        containerNavigationController: UINavigationController? = nil
    ){
        DispatchQueue.main.async {
            let viewController: UIViewController
            viewController = WebViewVC(header: header, url: url)
        
            let navigationController = containerNavigationController ?? self.navigationController
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func navigateToPostBasedVC(
        _ viewBuilder: ViewBuilder,
        _ injectIntoNavigationController: Bool = false,
        _ post: Post,
        _ currentImage: UIImage?
    ) {
        DispatchQueue.main.async {
            let viewController: UIViewController
            switch viewBuilder {
            case .commentOnPost:
                viewController = CommentOnPostVC(post: post, image: currentImage)
            default:
                return
            }
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .fullScreen
            if injectIntoNavigationController {
                let navigationController = BaseNavigationController(rootViewController: viewController)
                navigationController.setNavigationBarHidden(true, animated: false)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(
                    navigationController,
                    animated: true)
            } else {
                self.present(viewController, animated: true)
            }
        }
    }
    
    func navigateTo(
        _ viewBuilder: ViewBuilder,
        _ injectIntoNavigationController: Bool = false
    ) {
        DispatchQueue.main.async {
            let viewController: UIViewController
            switch viewBuilder {
            case .splashScreen:
                viewController = SplashVC()
            case .signUp:
                viewController = AuthVC()
            case .dashboard:
                viewController = BaseTabBarController()
            case .displayName:
                viewController = DisplayNameAcquisitionVC()
            case .bio:
                viewController = BioVC()
            case .coverPhoto:
                viewController = CoverImageVC()
            case .profilePicture:
                viewController = ProfileImagePickerVC()
            case .premium:
                viewController = PremiumVC()
            case .notifications:
                viewController = NotificationsVC()
            case .newPost:
                viewController = NewPostVC()
            case .playlistList:
                viewController = PlaylistViewController()
            case .accountSettings:
                viewController = AccountSettingsVC()
            case .gallerySelection:
                let galleryVC = GalleryVC(selectionEnabled: true)
                if let delegate = self as? GallerySelectionDelegate {
                    galleryVC.delegate = delegate
                }
                viewController = galleryVC
            default:
                return
            }
            
            viewController.modalPresentationStyle = .fullScreen
            if let navigationController = self.navigationController {
                
                navigationController.interactivePopGestureRecognizer?.isEnabled = true
                
                navigationController.pushViewController(viewController, animated: true)
            } else if injectIntoNavigationController {
                viewController.modalTransitionStyle = .crossDissolve
                let navigationController = BaseNavigationController(rootViewController: viewController)
                navigationController.setNavigationBarHidden(true, animated: false)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(
                    navigationController,
                    animated: true)
            } else {
                self.present(viewController, animated: true)
            }
        }
    }
}
