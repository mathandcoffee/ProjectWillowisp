//
//  DashboardCollectionViewCells.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 3/23/23.
//

import UIKit
import Resolver
import Combine
import GiphyUISDK
import AVFoundation
import Nuke
import NukeExtensions

class ImagePostCollectionViewCell: UICollectionViewCell {
    
    struct LayoutProfile {
        let profileImageDimension: CGFloat = 36
        let nameLabelHeight: CGFloat = 20
        let padding: CGFloat = .padding(.normal)
        let spacing: CGFloat = .spacing(.normal)
    }
    
    var likeAction: ((UUID) -> Void)?
    var commentAction: ((UUID) -> Void)?
    var profileAction: ((UUID) -> Void)?
    var moreAction: ((Post) -> Void)?
    var optionsAction: ((Post) -> Void)?
    var reportAction: ((Reply) -> Void)?
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var post: Post?
    var reply: Reply?
    
    private var imageTask: Task<Void, Never>?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        post = nil
        reply = nil
        userPostImageView.image = nil
        userPostImageView.media = nil
        userProfileImageView.image = nil
        userPostImageView.backgroundColor = .surface
        imageTask?.cancel()
        imageTask = nil
    }
    
    private(set) lazy var durationlabel: UILabel = {
        let label = UILabel()
        label.font = .headline5
        label.textColor = .onBackground
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = .background.withAlphaComponent(0.6)
        label.layer.cornerRadius = 8
        label.layer.maskedCorners = [.layerMinXMinYCorner]
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()

    private(set) lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .background
        return view
    }()
    
    private(set) lazy var userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.isUserInteractionEnabled = true
        imageView.isHidden = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfile)))
        return imageView
    }()
    
    private(set) lazy var nameDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .onBackground
        label.font = .body1
        return label
    }()
    
    private(set) lazy var pinImageView: UIImageView = {
        let pinnedImageView = UIImageView()
        pinnedImageView.contentMode = .scaleAspectFill
        pinnedImageView.clipsToBounds = true
        pinnedImageView.layer.cornerRadius = 4
        pinnedImageView.layer.borderColor = UIColor.surface.cgColor
        pinnedImageView.layer.borderWidth = 1
        pinnedImageView.image = UIImage(systemName: "pin.fill")
        pinnedImageView.tintColor = .onBackground
        pinnedImageView.isHidden = true
        return pinnedImageView
    }()
    
    private(set) lazy var userPostLabel: UILabel = {
        let label = UILabel()
        label.font = .body2
        label.addURLGestureRecognizer()
        return label
    }()
    
    private(set) lazy var userPostImageView: GPHMediaView = {
        let imageView = GPHMediaView()
        imageView.backgroundColor = .background(.dark)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.isHidden = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showContent)))
        
        imageView.addSubview(durationlabel)
        durationlabel.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview()
            make.height.equalTo(24)
            make.width.equalTo(72)
        }
        return imageView
    }()
    
    private(set) lazy var userPostSubscriptionOnlyLabel: UIView = {
        let view = UIView()
        view.backgroundColor = .background.withAlphaComponent(0.3)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showContent)))
        
        let label = UILabel()
        label.text = "Subscriber Only Content"
        label.font = .headline3
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .onBackground
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.centerY.width.equalToSuperview()
            make.height.equalTo(48)
        }
        
        let imageView = UIImageView()
        imageView.tintColor = .onBackground
        imageView.image = UIImage(systemName: "lock.fill")
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.bottom.equalTo(label.snp.top).offset(-CGFloat.padding)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(48)
        }
        
        let label2 = UILabel()
        label2.text = "Subscribe to Unlock this Content"
        label2.font = .headline5
        label2.adjustsFontSizeToFitWidth = true
        label2.textAlignment = .center
        label2.textColor = .onBackground
        
        view.addSubview(label2)
        label2.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(48)
        }
        return view
    }()
    
    private(set) lazy var likesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .icon
        label.font = .subtitle1
        label.textAlignment = .center
        return label
    }()
    
    private(set) lazy var likeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(like), for: .touchUpInside)
        return button
    }()
    
    private(set) lazy var optionsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.square.on.square"), for: .normal)
        button.addTarget(self, action: #selector(optionsActionPressed), for: .touchUpInside)
        button.tintColor = .icon
        return button
    }()
    
    private(set) lazy var sizeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .icon
        label.font = .subtitle1
        label.textAlignment = .center
        return label
    }()
    
    private(set) lazy var commentButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(comment), for: .touchUpInside)
        button.setImage(.comment.withRenderingMode(.alwaysTemplate), for: .normal)
        return button
    }()
    
    private(set) lazy var buttonStackView: UIView = {
        let stackView = UIView()
        stackView.isUserInteractionEnabled = true
        stackView.addSubview(likeButton)
        likeButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(CGFloat.spacing(.small))
            make.height.equalTo(24)
            make.width.equalTo(24)
        }
        
        stackView.addSubview(likesLabel)
        likesLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(likeButton.snp.trailing).offset(CGFloat.spacing(.small))
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        stackView.addSubview(commentButton)
        commentButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(likesLabel.snp.trailing).offset(CGFloat.spacing(.normal))
            make.height.equalTo(24)
            make.width.equalTo(24)
        }
        
        stackView.addSubview(sizeLabel)
        sizeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(commentButton.snp.trailing).offset(CGFloat.spacing(.small))
            make.height.equalTo(24)
            make.width.equalTo(24)
        }
        
        stackView.addSubview(optionsButton)
        optionsButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(sizeLabel.snp.trailing).offset(CGFloat.spacing(.normal))
            make.height.equalTo(24)
            make.width.equalTo(24)
        }
        
        return stackView
    }()
    
    @objc private func tap() {
        print("TAPPED")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .background
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func like() {
        if post?.is_subscriber_only_content == true, UserProfileService.shared.currentUser?.is_subscribed == false {
            return
        }
        if let post = post {
            likeAction?(post.id)
            likesLabel.text = "\(((post.likes?.count ?? 0) + 1).toPostViewableString())"
            likeButton.setImage(.likeFilled, for: .normal)
        } else if let reply = reply {
            likeAction?(reply.id)
            likesLabel.text = "\(((reply.likes?.count ?? 0) + 1).toPostViewableString())"
            likeButton.setImage(.likeFilled, for: .normal)
        }
    }
    
    @objc private func comment() {
        if let post = post {
            commentAction?(post.id)
        }
    }
    
    @objc private func showProfile() {
        if let post = post {
            profileAction?(post.user.id)
        }
    }
    
    @objc private func showContent() {
        guard let post = post else { return }
        moreAction?(post)
    }
    
    @objc private func optionsActionPressed() {
        if let post = post {
            optionsAction?(post)
        } else if let reply = reply {
            reportAction?(reply)
        }
        
    }
    
    func configure(post: Post, uniqueId: Int, image: UIImage?) {
        setupIfNeeded()
                
        self.post = post
        
        guard let userId = UserProfileService.shared.currentUser?.id else { return }

        if post.is_pinned {
            pinImageView.image = UIImage(systemName: "pin.fill")
            pinImageView.isHidden = false
            backgroundColor = .highlight
            layer.borderWidth = 2
            layer.borderColor = UIColor.primary.cgColor
        } else {
            pinImageView.image = nil
            pinImageView.isHidden = true
            backgroundColor = .background
            layer.borderWidth = 0
        }
        
        if let duration = post.duration {
            durationlabel.text = duration
            durationlabel.isHidden = false
        } else {
            durationlabel.text = ""
            durationlabel.isHidden = true
        }
        
        if post.is_subscriber_only_content, UserProfileService.shared.currentUser?.is_subscribed == false {
            userPostSubscriptionOnlyLabel.isHidden = false
            commentButton.tintColor = .icon.withAlphaComponent(0.5)
            likeButton.tintColor = .icon.withAlphaComponent(0.5)
            optionsButton.tintColor = .icon.withAlphaComponent(0.5)
            durationlabel.isHidden = true
        } else {
            userPostSubscriptionOnlyLabel.isHidden = true
            commentButton.tintColor = .icon
            likeButton.tintColor = .icon
            optionsButton.tintColor = .icon
            durationlabel.isHidden = false
        }
        
        if let imageUrl = post.media_thumbnail_url {
            imageTask = Task {
                do {
                    guard let url = try await SupabaseProvider.shared.storageClient()?.createSignedURL(path: imageUrl, expiresIn: 3600)
                    else { return }
                    let imageRequest: ImageRequest
                    if post.is_subscriber_only_content, UserProfileService.shared.currentUser?.is_subscribed == false {
                        imageRequest = ImageRequest(url: url, processors: [
                            ImageProcessors.GaussianBlur(radius: 50)
                        ])
                    } else {
                        imageRequest = ImageRequest(url: url)
                    }
                    
                    let image = try await ImagePipeline.shared.image(for: imageRequest)
                    if tag != uniqueId { return }
                    userPostImageView.image = image
                    userPostImageView.isHidden = false
                } catch {
                    print(error)
                }
            }
        } else if let imageUrl = post.media_url {
            if post.media_type == .image {
                imageTask = Task {
                    do {
                        guard let url = try await SupabaseProvider.shared.storageClient()?.createSignedURL(path: imageUrl, expiresIn: 3600)
                        else { return }
                        let imageRequest: ImageRequest
                        if post.is_subscriber_only_content, UserProfileService.shared.currentUser?.is_subscribed == false {
                            imageRequest = ImageRequest(url: url, processors: [
                                ImageProcessors.GaussianBlur(radius: 50)
                            ])
                        } else {
                            imageRequest = ImageRequest(url: url)
                        }
                        
                        let image = try await ImagePipeline.shared.image(for: imageRequest)
                        if tag != uniqueId { return }
                        userPostImageView.image = image
                        userPostImageView.isHidden = false
                    } catch {
                        print(error)
                    }
                }
            } else if post.media_type == .gif {
                imageTask = Task {
                    if tag != uniqueId { return }
                    let id = String(imageUrl.split(separator: "-").last!)
                    GiphyCore.shared.gifByID(id) { (response, error) in
                        if let media = response?.data {
                            DispatchQueue.main.async {
                                if self.tag != uniqueId { return }
                                self.userPostImageView.media = media
                                self.userPostImageView.isHidden = false
                            }
                        }
                    }
                }
            }
        }
        
        nameDateLabel.text = post.title?.count ?? 0 > 0 ? post.title : post.user.username
        if post.is_subscriber_only_content, UserProfileService.shared.currentUser?.is_subscribed == false {
            userPostLabel.text = "Subscribe to see this content!"
        } else {
            userPostLabel.attributedText = userPostLabel.getAttributedString(input: post.post_text ?? "")
        }
        if post.likes?.count ?? 0 > 0 {
            likesLabel.text = post.likes?.count.toPostViewableString()
            likeButton.setImage(post.likes?.first(where: {
                $0.user_id == userId
            }) != nil ? .likeFilled.withRenderingMode(.alwaysTemplate) : .like.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            likesLabel.text = "0"
            likeButton.setImage(.like, for: .normal)
        }
        
        if post.comments?.count ?? 0 > 0 {
            sizeLabel.text = post.comments?.count.toPostViewableString()
        } else {
            sizeLabel.text = "0"
        }
        
        DispatchQueue.main.async {
            self.updateLabelConstraints(for: post.post_text, imageAspect: post.media_aspect == nil ? nil : CGFloat(post.media_aspect!))
        }
        
        if let imageUrl = post.user.avatar_url {
            Task {
                guard let url = try await SupabaseProvider.shared.storageClient()?.createSignedURL(path: imageUrl, expiresIn: 3600)
                else { return }
                let imageRequest: ImageRequest
                if post.is_subscriber_only_content, UserProfileService.shared.currentUser?.is_subscribed == false {
                    imageRequest = ImageRequest(url: url, processors: [
                        ImageProcessors.GaussianBlur(radius: 50)
                    ])
                } else {
                    imageRequest = ImageRequest(url: url)
                }
                
                let image = try await ImagePipeline.shared.image(for: imageRequest)
                if tag != uniqueId { return }
                userProfileImageView.image = image
                userProfileImageView.isHidden = false
            }
        }
    }
    
    func setupIfNeeded() {
        guard userProfileImageView.superview == nil else {
            return
        }
        
        let layout = LayoutProfile()
        backgroundColor = .background
        
        likeButton.setImage(.like.withRenderingMode(.alwaysTemplate), for: .normal)
        likeButton.imageView?.tintColor = .icon
        likeButton.addTarget(self, action: #selector(like), for: .touchUpInside)
        
        addSubview(userPostImageView)
        userPostImageView.snp.makeConstraints { make in
            make.width.equalTo(self)
            make.leading.trailing.top.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(userPostImageView.snp.width)
        }
        
        addSubview(userPostSubscriptionOnlyLabel)
        userPostSubscriptionOnlyLabel.snp.makeConstraints { make in
            make.centerY.centerX.width.height.equalTo(userPostImageView)
        }
        
        addSubview(userProfileImageView)
        userProfileImageView.snp.makeConstraints { make in
            make.height.width.equalTo(layout.profileImageDimension)
            make.leading.equalToSuperview().offset(layout.padding)
            make.top.equalTo(userPostImageView.snp.bottom).offset(CGFloat.padding)
        }
        
        addSubview(nameDateLabel)
        nameDateLabel.snp.makeConstraints { make in
            make.leading.equalTo(userProfileImageView.snp.trailing).offset(layout.spacing)
            make.height.equalTo(layout.nameLabelHeight)
            make.top.equalTo(userProfileImageView)
        }
        
        addSubview(pinImageView)
        pinImageView.snp.makeConstraints { make in
            make.trailing.equalTo(self).inset(CGFloat.padding)
            make.centerY.equalTo(nameDateLabel)
            make.height.width.equalTo(24)
        }
        
        userPostLabel.textColor = .onBackground
        userPostLabel.font = .body2
        userPostLabel.numberOfLines = 0
        addSubview(userPostLabel)
        userPostLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameDateLabel)
            make.trailing.equalToSuperview().offset(-layout.padding)
            make.top.equalTo(nameDateLabel.snp.bottom).offset(CGFloat.spacing(.normal))
        }
        
        addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(CGFloat.padding)
            make.leading.trailing.equalToSuperview()
        }
        
        separatorView.backgroundColor = .surface
        addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.bottom.width.centerX.equalToSuperview()
            make.height.equalTo(2)
        }
    }
    
    func updateLabelConstraints(for message: String?, imageAspect: CGFloat?) {
        let layout = LayoutProfile()
        
        addSubview(userPostLabel)
        userPostLabel.snp.remakeConstraints { make in
            make.leading.equalTo(nameDateLabel)
            make.trailing.equalToSuperview().offset(-layout.padding)
            make.top.equalTo(nameDateLabel.snp.bottom).offset(CGFloat.spacing(.normal))
        }
        updateImageConstraints(imageAspect: imageAspect, topConstraintView: userPostLabel)
    }
    
    private func updateImageConstraints(imageAspect: CGFloat?, topConstraintView: UIView) {
        let layout = LayoutProfile()

        if imageAspect == nil || imageAspect == 0 {
            userPostImageView.removeFromSuperview()
            userPostImageView.snp.removeConstraints()
            
            userProfileImageView.snp.makeConstraints { make in
                make.height.width.equalTo(layout.profileImageDimension)
                make.left.equalToSuperview().offset(layout.padding)
                make.top.equalTo(safeAreaLayoutGuide).offset(CGFloat.padding)
            }
            return
        }
        
        addSubview(userPostImageView)
        userPostImageView.snp.remakeConstraints { make in
            make.width.equalTo(self)
            make.trailing.leading.equalToSuperview()
            make.top.equalTo(self)
            make.height.equalTo(userPostImageView.snp.width).multipliedBy(imageAspect!)
        }
        
        userProfileImageView.snp.makeConstraints { make in
            make.height.width.equalTo(layout.profileImageDimension)
            make.left.equalToSuperview().offset(layout.padding)
            make.top.equalTo(userPostImageView.snp.bottom).offset(CGFloat.padding)
        }
        
        if userPostSubscriptionOnlyLabel.superview != nil {
            userPostSubscriptionOnlyLabel.snp.remakeConstraints { make in
                make.centerX.centerY.height.width.equalTo(userPostImageView)
            }
            bringSubviewToFront(userPostSubscriptionOnlyLabel)
        }
    }
    
    static func height(post: Post, tableViewWidth: CGFloat) -> CGFloat {
        let layout = LayoutProfile()
        let textWidth = tableViewWidth - layout.padding * 3 - layout.profileImageDimension
        let textHeight = post.post_text?.height(withConstrainedWidth: textWidth, font: .body2) ?? 0
        var imageHeight: CGFloat = 0
        if let mediaAspect = post.media_aspect {
            imageHeight += (tableViewWidth - CGFloat.padding) * mediaAspect + layout.spacing
        }
        return textHeight + imageHeight + layout.padding * (textHeight == 0 ? 1 : 2) + layout.nameLabelHeight + 88
    }
    
    static func height(reply: Reply, tableViewWidth: CGFloat) -> CGFloat {
        let layout = LayoutProfile()
        let textWidth = tableViewWidth - layout.padding * 3 - layout.profileImageDimension
        let textHeight = reply.message?.height(withConstrainedWidth: textWidth, font: .body2) ?? 0
        var imageHeight: CGFloat = 0
        if let _ = reply.gif_id {
            imageHeight += (tableViewWidth) / CGFloat(reply.gif_aspect_ratio ?? 1.0) + layout.spacing
        }
        return textHeight + imageHeight + layout.padding * (textHeight == 0 ? 1 : 2) + layout.nameLabelHeight + 88
    }
}
