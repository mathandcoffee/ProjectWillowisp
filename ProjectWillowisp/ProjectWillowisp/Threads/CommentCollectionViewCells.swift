//
//  CommentCollectionViewCells.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 12/16/21.
//

import UIKit
import Resolver
import Combine
import GiphyUISDK

class CommentCollectionViewCell: ImagePostCollectionViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(reply: Reply, uniqueId: Int) {
        self.reply = reply
        super.setupIfNeeded()
        separatorView.removeFromSuperview()
        setupView(reply: reply, uniqueId: uniqueId)
        
        optionsButton.setImage(.more, for: .normal)
        
        if commentAction == nil {
            commentButton.removeFromSuperview()
            sizeLabel.removeFromSuperview()
            optionsButton.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalTo(likesLabel.snp.trailing).offset(CGFloat.spacing)
                make.height.equalTo(24)
                make.width.equalTo(24)
            }
        }
        
        if reply.likes?.count ?? 0 > 0 {
            likesLabel.text = reply.likes?.count.toPostViewableString()
            likeButton.imageView?.image = reply.likes?.first(where: {
                $0.user_id == UserProfileService.shared.currentUser?.id
            }) != nil ? .likeFilled : .like
        } else {
            likesLabel.text = "0"
            likeButton.setImage(.like, for: .normal)
        }
    }
    
    func setupView(reply: Reply, uniqueId: Int) {
        nameDateLabel.text = reply.user?.username
        userPostLabel.attributedText = userPostLabel.getAttributedString(input: reply.message ?? "")
        userPostSubscriptionOnlyLabel.removeFromSuperview()

        if let imageUrl = reply.user?.avatar_url {
            Task {
                let image = await CoreDataManager.shared.downloadOrRetrieveImage(imageUrl: imageUrl)
                DispatchQueue.main.async {
                    self.userProfileImageView.image = image
                    self.userProfileImageView.isHidden = false
                }
            }
        }
        
        if let imageUrl = reply.gif_id {
            let id = String(imageUrl.split(separator: "-").last!)
                GiphyCore.shared.gifByID(id) { (response, error) in
                    if let media = response?.data {
                        DispatchQueue.main.sync {
                            if self.tag != uniqueId { return }
                            self.userPostImageView.media = media
                            self.userPostImageView.isHidden = false
                        }
                    }
                }
            DispatchQueue.main.async {
                self.updateLabelConstraints(for: reply.message, imageAspect: 1 / (reply.gif_aspect_ratio ?? 1.0))
            }
        } else {
            DispatchQueue.main.async {
                self.updateLabelConstraints(for: reply.message, imageAspect: nil)
            }
        }
    }
    
    private func updateImageConstraints(reply: Reply) {
        let layout = LayoutProfile()
        
        if reply.gif_id == nil {
            userPostImageView.removeFromSuperview()
            userPostImageView.snp.removeConstraints()
            return
        }
        
        addSubview(userPostImageView)
        userPostImageView.snp.remakeConstraints { make in
            make.leading.trailing.equalTo(userPostLabel)
            make.bottom.equalTo(likeButton.snp.top).offset(-layout.padding)
            make.top.equalTo(userPostLabel.snp.bottom).offset(CGFloat.spacing(.large))
            make.height.equalTo(userPostImageView.snp.width).dividedBy(reply.gif_aspect_ratio ?? 1.0)
        }
    }
}

class CommentWithRepliesCollectionViewCell: CommentCollectionViewCell {
    
    private let commentLineView = UIView(frame: .zero)
    
    override func configure(reply: Reply, uniqueId: Int) {
        super.configure(reply: reply, uniqueId: uniqueId)
                
        if commentAction == nil {
            commentButton.removeFromSuperview()
            sizeLabel.removeFromSuperview()
        }
        
        addSubview(commentLineView)
        commentLineView.backgroundColor = .icon
        commentLineView.snp.makeConstraints { make in
            make.top.equalTo(userProfileImageView.snp.bottom)
            make.bottom.equalToSuperview()
            make.centerX.equalTo(userProfileImageView)
            make.width.equalTo(2)
        }
        
        
    }
}
