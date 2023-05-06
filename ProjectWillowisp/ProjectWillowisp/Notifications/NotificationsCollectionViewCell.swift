//
//  NotificationsCollectionViewCell.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 1/5/22.
//

import UIKit
import Nuke

final class NotificationsCollectionViewCell: UICollectionViewCell {
        
    private lazy var userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private lazy var notificationTypeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private lazy var primaryTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .onBackground
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .surface
        return view
    }()
    
    func configure(notification: WillowNotification) {
        let attrs = [NSAttributedString.Key.font: UIFont.body1]
        let attributedString = NSMutableAttributedString(string: notification.title, attributes: attrs)

        let secondaryAttrs = [NSAttributedString.Key.font: UIFont.body2]
        let normalString = NSMutableAttributedString(string: " " + notification.message, attributes: secondaryAttrs)

        attributedString.append(normalString)
        
        primaryTextLabel.attributedText = attributedString
        
        if let imageUrl = notification.post?.media_thumbnail_url {
            fetchImage(notification: notification, imageUrl: imageUrl)
        } else if let imageUrl = notification.post?.user.avatar_url {
            fetchImage(notification: notification, imageUrl: imageUrl)
        }
        
        setupIfNeeded()
    }
    
    private func fetchImage(notification: WillowNotification, imageUrl: String) {
        Task {
            do {
                guard let url = try await SupabaseProvider.shared.storageClient()?.createSignedURL(path: imageUrl, expiresIn: 3600)
                else { return }
                let imageRequest: ImageRequest
                if notification.post?.is_subscriber_only_content == true, UserProfileService.shared.currentUser?.is_subscribed == false {
                    imageRequest = ImageRequest(url: url, processors: [
                        ImageProcessors.GaussianBlur(radius: 50)
                    ])
                } else {
                    imageRequest = ImageRequest(url: url)
                }
                
                let image = try await ImagePipeline.shared.image(for: imageRequest)
                userProfileImageView.image = image
            } catch {
                print(error)
            }
        }
    }
    
    private func setupIfNeeded() {
        addSubview(userProfileImageView)
        userProfileImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(CGFloat.padding)
            make.height.width.equalTo(48)
        }
        
        addSubview(notificationTypeImageView)
        notificationTypeImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(userProfileImageView.snp.right).offset(CGFloat.padding)
            make.height.width.equalTo(18)
        }
        
        addSubview(primaryTextLabel)
        primaryTextLabel.snp.makeConstraints { make in
            make.height.centerY.equalTo(userProfileImageView)
            make.left.equalTo(notificationTypeImageView.snp.right).offset(CGFloat.padding)
            make.right.equalToSuperview().inset(CGFloat.padding)
        }
        
        addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.width.left.bottom.equalToSuperview()
            make.height.equalTo(2)
        }
    }
    
    static func height(for notification: WillowNotification, collectionView: UICollectionView) -> CGFloat {
        let textWidth = collectionView.frame.width - 80
        let textHeight = notification.message.height(withConstrainedWidth: textWidth, font: .body2)
        return textHeight + 72
    }
}
