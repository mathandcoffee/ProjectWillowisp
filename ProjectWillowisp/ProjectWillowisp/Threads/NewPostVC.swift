//
//  NewPostVC.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 11/30/21.
//

import UIKit
import Resolver
import Combine
import GiphyUISDK
import ImagePicker

class NewPostVC: UIViewController {
    
    private struct LayoutProfile {
        let profileImageDimension: CGFloat = 36
        let nameLabelHeight: CGFloat = 20
        let iconSizeParam: CGFloat = 48
        let padding: CGFloat = .padding(.normal)
        let spacing: CGFloat = .spacing(.small)
    }
    
    private var mediaImage: UIImage?
    
    private lazy var sendButton: UIButton = {
        let sendButton = UIButton()
        sendButton.setImage(.send, for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
        sendButton.imageView?.tintColor = .onBackground
        return sendButton
    }()
    
    private lazy var navigationView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .background
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.width.leading.trailing.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(56)
        }
        
        view.addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(48)
        }
        
        let backButton = UIButton()
        backButton.setImage(.back, for: .normal)
        backButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        backButton.imageView?.tintColor = .onBackground
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(48)
        }
        
        return view
    }()
    
    private lazy var userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        guard let me = UserProfileService.shared.currentUser else { fatalError() }
        if let profileImageString = me.avatar_url {
            Task {
                imageView.image = await CoreDataManager.shared.downloadOrRetrieveImage(imageUrl: profileImageString)
            }
        } else {
            imageView.image = .profileImageDefault
            imageView.tintColor = .onBackground
        }
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .onBackground
        label.font = .body1
        label.text = UserProfileService.shared.currentUser?.username
        return label
    }()
    
    private lazy var textView: DystoriaTextView = {
        let textView = DystoriaTextView(placeholder: "What's your story?")
        textView.backgroundColor = .background
        return textView
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .surface
        return view
    }()
    
    private lazy var postImageView: GPHMediaView = {
        let imageView = GPHMediaView()
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var giphyPostButton: UIButton = {
        let button = UIButton()
        button.setImage(.gif, for: .normal)
        button.imageView?.tintColor = .primary
        button.backgroundColor = .background
        button.addTarget(self, action: #selector(pickGif), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        
        let layout = LayoutProfile()
        
        view.addSubview(userProfileImageView)
        userProfileImageView.snp.makeConstraints { make in
            make.height.width.equalTo(layout.profileImageDimension)
            make.top.equalTo(navigationView.snp.bottom).offset(layout.padding)
            make.leading.equalToSuperview().offset(layout.padding)
        }
        
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(userProfileImageView.snp.trailing).offset(24)
            make.height.equalTo(layout.nameLabelHeight)
            make.top.equalTo(userProfileImageView)
        }
        
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.equalTo(userProfileImageView.snp.right).offset(layout.spacing - 4)
            make.right.equalToSuperview().inset(layout.spacing)
            make.height.equalTo(96)
            make.top.equalTo(nameLabel.snp.bottom).offset(layout.spacing)
        }
        
        view.addSubview(postImageView)
        postImageView.snp.makeConstraints { make in
            make.left.right.equalTo(textView)
            make.height.width.equalTo(textView.snp.width)
            make.top.equalTo(textView.snp.bottom).offset(layout.spacing)
        }
        
        view.addSubview(giphyPostButton)
        giphyPostButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(layout.padding)
            make.left.equalTo(view).offset(layout.padding)
            make.height.width.equalTo(layout.iconSizeParam)
        }
        
        view.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.bottom.equalTo(giphyPostButton.snp.top).offset(-layout.spacing)
            make.width.left.equalToSuperview()
            make.height.equalTo(2)
        }
    }
    
    @objc private func pickGif() {
        let giphy = GiphyViewController()
        giphy.mediaTypeConfig = [.gifs]
        giphy.theme = GPHTheme(type: .darkBlur)
        giphy.rating = .ratedR
        GiphyViewController.trayHeightMultiplier = 1.0
        giphy.delegate = self
        giphy.modalPresentationStyle = .fullScreen
        present(giphy, animated: true, completion: nil)
    }
    
    @objc private func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func sendButtonPressed() {
        struct PostRequest: JSONCodable {
            let id: UUID
            let title: String?
            var post_text: String?
            let media_url: String?
            let media_type: MediaType?
            let creator_id: UUID
            let media_aspect: Double?
        }
        
        sendButton.isUserInteractionEnabled = false
        let mediaGif = postImageView.media
        Task {
            let _ = try? await SupabaseProvider.shared.postDatabase.insert(
                values: PostRequest(
                    id: UUID(),
                    title: nil,
                    post_text: textView.text,
                    media_url: mediaGif?.id,
                    media_type: mediaGif != nil ? .gif : MediaType.none,
                    creator_id: SocialInteractionService.shared.creator_id,
                    media_aspect: mediaGif?.aspectRatio != nil ? 1.0 / Double(mediaGif!.aspectRatio) : nil
                )
            ).execute().value
            await SocialInteractionService.shared.retrievePosts()
            navigationController?.popViewController(animated: true)
        }
    }
    
    deinit {
        print("\(self) deinited correctly")
    }
}

extension NewPostVC: GiphyDelegate {
    func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia)   {
   
        postImageView.media = media
        // your user tapped a GIF!
        giphyViewController.dismiss(animated: true, completion: nil)
   }
   
   func didDismiss(controller: GiphyViewController?) {
        // your user dismissed the controller without selecting a GIF.
   }
}
