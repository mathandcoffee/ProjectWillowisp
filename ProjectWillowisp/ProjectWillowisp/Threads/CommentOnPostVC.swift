//
//  CommentOnPostVC.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 12/14/21.
//

import UIKit
import Combine
import Resolver
import GiphyUISDK
import ImagePicker

class CommentOnPostVC: UIViewController {
    
    private let postId: UUID
    
    private(set) var isShowingCommentOptions = false
    
    private var user: User {
        didSet {
            guard let displayName = user.username else { return }
            replyTextField.placeholder = "Replying to \(displayName)'s Post"
            let _ = replyTextField.becomeFirstResponder()
        }
    }
    
    private let post: Post
    
    private var replies: [Reply] {
        return post.comments ?? []
    }
    
    private var imagePicker: ImagePickerController?
    
    fileprivate var media: GPHMedia?
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let image: UIImage?
    
    private lazy var navigationView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .background
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.width.leading.trailing.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(56)
        }
        
        let backButton = UIButton()
        backButton.setImage(.back, for: .normal)
        backButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        backButton.imageView?.tintColor = .onPrimary
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(48)
        }
        
        let label = UILabel()
        label.font = .body1
        label.textColor = .onPrimary
        label.text = "@\(user.username ?? "A Banned Deucer")'s Post"
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.height.equalTo(backButton)
            make.leading.equalTo(backButton.snp.trailing)
            make.trailing.equalToSuperview()
        }
        
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(ImagePostCollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: ImagePostCollectionViewCell.self))
        collectionView.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: CommentCollectionViewCell.self))
        collectionView.register(CommentWithRepliesCollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: CommentWithRepliesCollectionViewCell.self))
        collectionView.register(ImageReplyWithAdditionalRepliesCollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: ImageReplyWithAdditionalRepliesCollectionViewCell.self))
        collectionView.register(ImageReplyCollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: ImageReplyCollectionViewCell.self))
        collectionView.register(ImageInitialReplyCollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: ImageInitialReplyCollectionViewCell.self))
        collectionView.register(ImageInitialReplyWithAddtionalRepliesCollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: ImageInitialReplyWithAddtionalRepliesCollectionViewCell.self))

        collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissTextField)))
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .background
        return collectionView
    }()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @objc private func dismissTextField() {
        let _ = replyTextField.resignFirstResponder()
    }
    
    private lazy var replyTextField: DystoriaTextField = {
        let field = DystoriaTextField(placeholder: "Replying to \(user.username!)'s Post")
        field.layer.cornerRadius = 8
        return field
    }()
    
    private lazy var sendButton: UIButton = {
        let sendButton = UIButton()
        sendButton.setImage(.send.withRenderingMode(.alwaysTemplate), for: .normal)
        sendButton.imageView?.tintColor = .primary
        sendButton.backgroundColor = .background
        sendButton.addTarget(self, action: #selector(sendReply), for: .touchUpInside)
        return sendButton
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.tintColor = .onBackground
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(64)
        }
        return view
    }()
    
    private lazy var replyView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .background
        
        view.addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.height.width.equalTo(48)
        }
        
        let giphyButton = UIButton()
        giphyButton.setImage(.gif, for: .normal)
        giphyButton.imageView?.tintColor = .primary
        giphyButton.backgroundColor = .background
        giphyButton.addTarget(self, action: #selector(pickGif), for: .touchUpInside)
        view.addSubview(giphyButton)
        giphyButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.height.width.equalTo(32)
        }
        
//        let giphyImageView = UIImageView(image: .poweredByGiphy)
//        giphyImageView.contentMode = .scaleAspectFit
//        giphyImageView.tintColor = .onBackground
//        view.addSubview(giphyImageView)
//        giphyImageView.snp.makeConstraints { make in
//            make.bottom.equalTo(giphyButton.snp.top).offset(-4)
//            make.centerX.equalTo(giphyButton)
//            make.height.equalTo(25)
//            make.width.equalTo(giphyButton).multipliedBy(2.0)
//        }
        
        view.addSubview(replyTextField)
        replyTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(giphyButton.snp.right).offset(8)
            make.right.equalTo(sendButton.snp.left)
            make.height.equalTo(48)
        }
        
        return view
    }()
    
    private lazy var imageView: GPHMediaView = {
        let imageView = GPHMediaView()
        imageView.tintColor = .background(.dark)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private lazy var removeImageButton: UIButton = {
        let button = UIButton()
        button.setImage(.closeCircle, for: .normal)
        button.layer.masksToBounds = true
        button.backgroundColor = .background
        button.isHidden = true
        button.layer.cornerRadius = 21
        button.tintColor = .onBackground
        button.addTarget(self, action: #selector(removeImage), for: .touchUpInside)
        return button
    }()
    
    init(post: Post, image: UIImage?) {
        self.post = post
        self.user = post.user
        self.postId = post.id
        self.image = image
        super.init(nibName: nil, bundle: nil)
        setupView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.replyView.snp.updateConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-keyboardSize.height)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.replyView.snp.updateConstraints { make in
            if imageView.image == nil {
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-self.view.frame.width / 1.5)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(self) deinited correctly")
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
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
    
    private func setUpImageOnImageView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.replyView.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-self.view.frame.width / 1.5)
            }
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func removeImage() {
        guard imageView.image != nil || media != nil else { return }
        imageView.image = nil
        media = nil
        removeImageButton.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.replyView.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            }
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func sendReply() {
        guard replyTextField.text != nil || imageView.image != nil else { return }
        sendButton.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        Task {
            await SocialInteractionService.shared.postReply(
                postId: post.id,
                message: replyTextField.text,
                levelToIncrementTo: 1,
                media: media)
            refreshView()
        }
    }
    
    private func refreshView() {
        guard let user = UserProfileService.shared.currentUser else { return }
        DispatchQueue.main.async {
            self.post.comments?.append(Reply(id: UUID(), post_id: UUID(), message: self.replyTextField.text, gif_id: self.media?.id, user_id: user.id, level: 1, gif_aspect_ratio: Double(self.media?.aspectRatio ?? 1.0), user: user, likes: []))
            self.removeImage()
            self.replyTextField.text = ""
            self.sendButton.isUserInteractionEnabled = true
            self.collectionView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func setupView() {
        view.backgroundColor = .background
        
        view.addSubview(replyView)
        replyView.snp.makeConstraints { make in
            make.bottom.width.left.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(54)
        }
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(view.safeAreaLayoutGuide.snp.width).dividedBy(1.5)
            make.centerX.equalToSuperview()
            make.top.equalTo(replyView.snp.bottom).offset(16)
        }
        
        view.addSubview(removeImageButton)
        removeImageButton.snp.makeConstraints { make in
            make.height.width.equalTo(42)
            make.top.right.equalTo(imageView).inset(8)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.width.leading.equalToSuperview()
            make.bottom.equalTo(replyView.snp.top).offset(-8)
        }
    }
}

extension CommentOnPostVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat

        if indexPath.row == 0 {
            let post = self.post
            height = ImagePostCollectionViewCell.height(post: post, tableViewWidth: collectionView.frame.width)
        } else {
            let reply = post.comments![indexPath.row - 1]
            if reply.level > 1 {
                height = ImagePostCollectionViewCell.height(reply: reply, tableViewWidth: collectionView.frame.width)
            } else {
                height = CommentCollectionViewCell.height(reply: reply, tableViewWidth: collectionView.frame.width)
            }
        }
        
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismissTextField()
    }
}

extension CommentOnPostVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell?
        
        if indexPath.row == 0 {
            let postCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: ImagePostCollectionViewCell.self),
                for: indexPath) as? ImagePostCollectionViewCell
            let uniqueId = Int.random(in: Int.min...Int.max) //<-practically unique
            postCell?.tag = uniqueId
            postCell?.configure(post: post, uniqueId: uniqueId, image: postCell?.userPostImageView.image)
            postCell?.likeAction = { [weak self] (threadId: UUID?) in
                guard
                    let self = self,
                    let userId = UserProfileService.shared.currentUser?.id,
                    let id = threadId else {
                    return
                }
                Task {
                    let success = await SocialInteractionService.shared.likePost(
                        postId: id,
                        replyId: nil,
                        userId: userId)
                    if success {
                        self.collectionView.reloadData()
                    }
                }
            }
            
            postCell?.optionsAction = { [weak self] post in
                self?.isShowingCommentOptions = false
                let viewController = OptionsSelectionVC()
                viewController.delegate = self
                if let presentationController = viewController.presentationController as? UISheetPresentationController {
                    presentationController.detents = [.medium()]
                }
                
                self?.present(viewController, animated: true)
            }
            
            postCell?.moreAction = { [weak self] (content: Post?) in
                guard let self = self, let path = content?.media_url else { return }
                if content?.is_subscriber_only_content == true, UserProfileService.shared.currentUser?.is_subscribed == false {
                    return
                }
                Task{
                    collectionView.isUserInteractionEnabled = false
                    guard let videoUrl = try? await SupabaseProvider.shared.storageClient(bucketName: "videos")?.createSignedURL(path: path, expiresIn: 3600) else { return }
                    let controller = VideoPlaybackViewController(url: videoUrl, post: content!)
                    controller.modalPresentationStyle = .fullScreen
                    collectionView.isUserInteractionEnabled = true
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true)
                }
            }

            postCell?.profileAction = { [weak self] (userId: UUID) in
                guard let self = self else { return }
                let profileVC = ProfileVC(id: userId)
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
            
            cell = postCell
        } else {
            let reply = replies[indexPath.row - 1]
            let level = reply.level
            let subsequentReply = indexPath.row < replies.count ? replies[indexPath.row] : nil
            if level == 1 && (subsequentReply?.level == 1 || subsequentReply == nil) {
                
                guard let postCell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: CommentCollectionViewCell.self),
                    for: indexPath) as? CommentCollectionViewCell else { fatalError() }
                let uniqueId = Int.random(in: Int.min...Int.max) //<-practically unique
                postCell.tag = uniqueId
                postCell.configure(reply: reply, uniqueId: uniqueId)

                postCell.likeAction = { [weak self] (threadId: UUID?) in
                    guard
                        let self = self,
                        let userId = UserProfileService.shared.currentUser?.id,
                        let id = threadId else {
                        return
                    }
                    Task {
                        let success = await SocialInteractionService.shared.likePost(
                            postId: nil,
                            replyId: id,
                            userId: userId)
                        if success {
                            self.collectionView.reloadData()
                        }
                    }
                }
                
                postCell.reportAction = { [weak self] post in
                    self?.isShowingCommentOptions = true
                    let viewController = OptionsSelectionVC()
                    viewController.delegate = self
                    if let presentationController = viewController.presentationController as? UISheetPresentationController {
                        presentationController.detents = [.medium()]
                    }
                    
                    self?.present(viewController, animated: true)
                }
                
                postCell.profileAction = { [weak self] (userId: UUID) in
                    guard let self = self else { return }
                    let profileVC = ProfileVC(id: userId)
                    self.navigationController?.pushViewController(profileVC, animated: true)
                }
                
                cell = postCell
                
            } else if level == 1 {
                let reply = replies[indexPath.row - 1]
                let postCell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: CommentWithRepliesCollectionViewCell.self),
                    for: indexPath) as? CommentWithRepliesCollectionViewCell
                let uniqueId = Int.random(in: Int.min...Int.max) //<-practically unique
                postCell?.tag = uniqueId
                postCell?.configure(reply: reply, uniqueId: uniqueId)

                postCell?.profileAction = { [weak self] (userId: UUID) in
                    guard let self = self else { return }
                    let profileVC = ProfileVC(id: userId)
                    self.navigationController?.pushViewController(profileVC, animated: true)
                }
                postCell?.likeAction = { [weak self] (threadId: UUID?) in
                    guard
                        let self = self,
                        let userId = UserProfileService.shared.currentUser?.id,
                        let id = threadId else {
                        return
                    }
                    Task {
                        let success = await SocialInteractionService.shared.likePost(
                            postId: nil,
                            replyId: id,
                            userId: userId)
                        if success {
                            self.collectionView.reloadData()
                        }
                    }
                }
                
                postCell?.reportAction = { [weak self] post in
                    self?.isShowingCommentOptions = true
                    let viewController = OptionsSelectionVC()
                    viewController.delegate = self
                    if let presentationController = viewController.presentationController as? UISheetPresentationController {
                        presentationController.detents = [.medium()]
                    }
                    
                    self?.present(viewController, animated: true)
                }
                
                cell = postCell
                
            } else {
                var showSequenceLine: Bool = false
                if let nextReply = subsequentReply {
                    showSequenceLine = nextReply.level > 1
                }
                
                var showStartingLines: Bool = false
                if indexPath.row > 1 {
                    let previousPost = replies[indexPath.row - 2]
                    showStartingLines = previousPost.level == 1
                }
                if showStartingLines, showSequenceLine {
                    let reply = replies[indexPath.row - 1]
                    let postCell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: ImageInitialReplyWithAddtionalRepliesCollectionViewCell.self),
                        for: indexPath) as? ImageInitialReplyWithAddtionalRepliesCollectionViewCell
                    postCell?.configure(post: post)

                    postCell?.profileAction = { [weak self] (userId: UUID) in
                        guard let self = self else { return }
                        let profileVC = ProfileVC(id: userId)
                        self.navigationController?.pushViewController(profileVC, animated: true)
                    }
                    postCell?.likeAction = { [weak self] (threadId: UUID) in
                        guard
                            let self = self,
                            let userId = UserProfileService.shared.currentUser?.id else {
                            return
                        }
                        Task {
                            let success = await SocialInteractionService.shared.likePost(
                                postId: nil,
                                replyId: threadId,
                                userId: userId)
                            if success {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                    
                    cell = postCell
                } else if showStartingLines {
                    let postCell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: ImageInitialReplyCollectionViewCell.self),
                        for: indexPath) as? ImageInitialReplyCollectionViewCell
                    postCell?.configure(post: post)
                    
                    postCell?.profileAction = { [weak self] (userId: UUID) in
                        guard let self = self else { return }
                        let profileVC = ProfileVC(id: userId)
                        self.navigationController?.pushViewController(profileVC, animated: true)
                    }
                    postCell?.likeAction = { [weak self] (threadId: UUID) in
                        guard
                            let self = self,
                            let userId = UserProfileService.shared.currentUser?.id else {
                            return
                        }
                        Task {
                            let success = await SocialInteractionService.shared.likePost(
                                postId: threadId,
                                replyId: nil,
                                userId: userId)
                            if success {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                    
                    cell = postCell
                } else if showSequenceLine {
                    let postCell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: ImageReplyWithAdditionalRepliesCollectionViewCell.self),
                        for: indexPath) as? ImageReplyWithAdditionalRepliesCollectionViewCell
                    postCell?.configure(post: post)
                    
                    postCell?.profileAction = { [weak self] (userId: UUID) in
                        guard let self = self else { return }
                        let profileVC = ProfileVC(id: userId)
                        self.navigationController?.pushViewController(profileVC, animated: true)
                    }
                    postCell?.likeAction = { [weak self] (threadId: UUID) in
                        guard
                            let self = self,
                            let userId = UserProfileService.shared.currentUser?.id else {
                            return
                        }
                        Task {
                            let success = await SocialInteractionService.shared.likePost(
                                postId: nil,
                                replyId: threadId,
                                userId: userId)
                            if success {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                    
                    cell = postCell
                } else {
                    let postCell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: ImageReplyCollectionViewCell.self),
                        for: indexPath) as? ImageReplyCollectionViewCell
                    postCell?.configure(post: post)
                    
                    postCell?.profileAction = { [weak self] (userId: UUID) in
                        guard let self = self else { return }
                        let profileVC = ProfileVC(id: userId)
                        self.navigationController?.pushViewController(profileVC, animated: true)
                    }
                    postCell?.likeAction = { [weak self] (threadId: UUID) in
                        guard
                            let self = self,
                            let userId = UserProfileService.shared.currentUser?.id else {
                            return
                        }
                        Task {
                            let success = await SocialInteractionService.shared.likePost(
                                postId: nil,
                                replyId: threadId,
                                userId: userId)
                            if success {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                    
                    cell = postCell
                }
            }
        }

        guard let collectionViewCell = cell else { fatalError() }

        return collectionViewCell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post.getSize()
    }
}

extension CommentOnPostVC: GiphyDelegate {
    func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia)   {
   
        imageView.media = media
        self.media = media
        removeImageButton.isHidden = false
        setUpImageOnImageView()
        giphyViewController.dismiss(animated: true, completion: nil)
   }
   
   func didDismiss(controller: GiphyViewController?) {
        
   }
}

extension CommentOnPostVC: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        DispatchQueue.main.async {
            if let photo = images.first {
                self.removeImageButton.isHidden = false
                self.imageView.image = photo
                self.setUpImageOnImageView()
            }
            imagePicker.dismiss(animated: true, completion: nil)
            self.imagePicker = nil
        }
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        DispatchQueue.main.async {
            if let photo = images.first {
                self.removeImageButton.isHidden = false
                self.imageView.image = photo
                self.setUpImageOnImageView()
            }
            imagePicker.dismiss(animated: true, completion: nil)
            self.imagePicker = nil
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
        self.imagePicker = nil
    }
}

extension CommentOnPostVC: AddToPlaylistDelegate {
    func didSelectPlaylist(_ playlist: Playlist) {
        let playlistItemsDatabase = SupabaseProvider.shared.playlistItemsDatabase
        Task {
            do {
                let _ = try await playlistItemsDatabase.insert(
                    values: PlaylistItemRequestPacket(
                        post: post,
                        playlistId: playlist.id)
                ).execute().value
            } catch {
                print(error)
            }
        }
    }
}

extension CommentOnPostVC: OptionsSelectionDelegate {
    func didSelectOption(_ option: OptionsSelectionVC.OptionAction) {
        switch option {
        case .addToPlaylist:
            let viewController = PlaylistViewController(onlyShowYourLists: true)
            viewController.delegate = self
            if let presentationController = viewController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium()]
            }
            present(viewController, animated: true)
        case .createPlaylist:
            let viewController = NewPlaylistViewController(post: post)
            if let presentationController = viewController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium()]
            }
            present(viewController, animated: true)
        case .report:
            if isShowingCommentOptions {
                let alert = UIAlertController(title: "Report this User?", message: "Would you like to report this comment? This will block this user.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                    //TODO: Add reports here
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(alert, animated: true)
                return
            }
            let alert = UIAlertController(title: "Report this Creator?", message: "The creator is the owner of this app. If you'd like to report this content, please contact Apple Support or Math and Coffee at https://mathandcoffee.com.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        default:
            return
        }
    }
}
