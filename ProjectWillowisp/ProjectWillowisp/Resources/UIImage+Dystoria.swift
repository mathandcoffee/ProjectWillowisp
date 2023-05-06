//
//  UIImage+Dystoria.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 10/23/21.
//

import UIKit
import AVFoundation

extension UIImage {
    
    static func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }

        return nil
    }
}

extension UIImage {
    fileprivate static func imageWithName(_ name: String) -> UIImage {
        guard let image = UIImage(named: name) else {
            fatalError("No image with name \(name)")
        }
        return image
    }
    
    // MARK: Icons
    
    static var discord: UIImage {
        return imageWithName("discord")
    }
    
    static var accessibility: UIImage {
        return imageWithName("accessibility").withRenderingMode(.alwaysTemplate)
    }
    
    static var account: UIImage {
        return imageWithName("account").withRenderingMode(.alwaysTemplate)
    }
    
    static var back: UIImage {
        return imageWithName("back").withRenderingMode(.alwaysTemplate)
    }
    
    static var menu: UIImage {
        return imageWithName("menu").withRenderingMode(.alwaysTemplate)
    }
    
    static var search: UIImage {
        return imageWithName("search").withRenderingMode(.alwaysTemplate)
    }
    
    static var imagePicker: UIImage {
        return imageWithName("imagePicker").withRenderingMode(.alwaysTemplate)
    }
    
    static var plus: UIImage {
        return imageWithName("plus").withRenderingMode(.alwaysTemplate)
    }
    
    static var more: UIImage {
        return imageWithName("more").withRenderingMode(.alwaysTemplate)
    }
    
    static var send: UIImage {
        return imageWithName("send").withRenderingMode(.alwaysTemplate)
    }
    
    static var home: UIImage {
        return imageWithName("home").withRenderingMode(.alwaysTemplate)
    }
    
    static var premium: UIImage {
        return imageWithName("logo").withRenderingMode(.alwaysTemplate)
    }
    
    static var support: UIImage {
        return imageWithName("support").withRenderingMode(.alwaysTemplate)
    }
    
    static var refresh: UIImage {
        return imageWithName("refresh").withRenderingMode(.alwaysTemplate)
    }
    
    static var settings: UIImage {
        return imageWithName("settings").withRenderingMode(.alwaysTemplate)
    }
    
    static var closeCircle: UIImage {
        return imageWithName("closeCircle").withRenderingMode(.alwaysTemplate)
    }
    
    static var gif: UIImage {
        return imageWithName("gif").withRenderingMode(.alwaysTemplate)
    }
    
    static var addFriends: UIImage {
        return imageWithName("addFriend").withRenderingMode(.alwaysTemplate)
    }
    
    static var block: UIImage {
        return imageWithName("block").withRenderingMode(.alwaysTemplate)
    }
    
    static var unfriend: UIImage {
        return imageWithName("unfriend").withRenderingMode(.alwaysTemplate)
    }
    
    static var friends: UIImage {
        return imageWithName("friends").withRenderingMode(.alwaysTemplate)
    }
    
    static var friendsFilled: UIImage {
        return imageWithName("friendsFilled").withRenderingMode(.alwaysTemplate)
    }
    
    static var notifications: UIImage {
        return imageWithName("notifications").withRenderingMode(.alwaysTemplate)
    }
    
    static var mute: UIImage {
        return imageWithName("mute").withRenderingMode(.alwaysTemplate)
    }
    
    static var report: UIImage {
        return imageWithName("report").withRenderingMode(.alwaysTemplate)
    }
    
    static var messages: UIImage {
        return imageWithName("messages").withRenderingMode(.alwaysTemplate)
    }
    
    static var resources: UIImage {
        return imageWithName("resources").withRenderingMode(.alwaysTemplate)
    }
    
    static var security: UIImage {
        return imageWithName("security").withRenderingMode(.alwaysTemplate)
    }
    
    static var logoOutlined: UIImage {
        return imageWithName("logoOutlined").withRenderingMode(.alwaysTemplate)
    }
    
    static var loop: UIImage {
        return UIImage(systemName: "repeat")!
    }
    
    static var loopOne: UIImage {
        return UIImage(systemName: "repeat.1")!
    }
    
    static var loopInterval: UIImage {
        return UIImage(systemName: "repeat.1.circle")!
    }
    
    //MARK: Post Actions
    
    static var delete: UIImage {
        return imageWithName("delete").withRenderingMode(.alwaysTemplate)
    }
    
    static var voteToKick: UIImage {
        return imageWithName("voteToKick").withRenderingMode(.alwaysTemplate)
    }
    
    static var edit: UIImage {
        return imageWithName("edit").withRenderingMode(.alwaysTemplate)
    }
    
    static var comment: UIImage {
        return imageWithName("comment").withRenderingMode(.alwaysTemplate)
    }
    
    static var like: UIImage {
        return imageWithName("like").withRenderingMode(.alwaysTemplate)
    }
    
    static var likeFilled: UIImage {
        return imageWithName("like_filled").withRenderingMode(.alwaysTemplate)
    }
    
    static var profileImageDefault: UIImage {
        return imageWithName("profileDefault").withRenderingMode(.alwaysTemplate)
    }
    
    // MARK: Large Images
    
    static var logoBanner: UIImage {
        return imageWithName("logoBanner")
    }
    
    static var mockPostImage: UIImage {
        return imageWithName("mockPostImage")
    }
    
    static var mockProfileImage: UIImage {
        return imageWithName("mockProfileImage")
    }
    
    static var poweredByGiphy: UIImage {
        return imageWithName("poweredByGiphy")
    }
    
    // MARK: Carousel
    
    static var carouselOne: UIImage {
        return imageWithName("carouselOne")
    }
    
    static var carouselTwo: UIImage {
        return imageWithName("carouselTwo")
    }
    
    static var carouselThree: UIImage {
        return imageWithName("carouselThree")
    }
    
    static var carouselFour: UIImage {
        return imageWithName("carouselFour")
    }
    
    static var carouselFive: UIImage {
        return imageWithName("carouselFive")
    }
}
