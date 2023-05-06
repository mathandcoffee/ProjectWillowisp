//
//  ProfileVC.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 12/19/21.
//

import UIKit
import Combine
import Resolver
import ImagePicker
import SupabaseStorage
import GiphyUISDK

enum ProfileImageType {
    case profilePicture
    case coverImage
}

class ProfileVC: UIViewController {
    
    private var user: User?
    
    private var likedPosts: [LikedPosts] = []
    private var postToAdd: Post?
    
    private var canEdit: Bool {
        return user?.id == UserProfileService.shared.currentUser?.id
    }
    
    private var editingIsEnabled = false
    
    private var imagePicker: ImagePickerController?
    private var imageToEdit: ProfileImageType = .profilePicture
    
    private lazy var gifOrProfileImageSelectionView: UIView = {
        let view = UIView()
        
        let gifButton = UIButton()
        gifButton.setImage(.gif, for: .normal)
        gifButton.tintColor = .primary
        gifButton.addTarget(self, action: #selector(showGifSelection), for: .touchUpInside)
        
        let imageButton = UIButton()
        imageButton.setImage(.gif, for: .normal)
        imageButton.tintColor = .primary
        imageButton.addTarget(self, action: #selector(showSelectProfilePicture), for: .touchUpInside)
        
        return view
    }()
    
    private lazy var displayNameLabel: UILabel = {
        let label = UILabel()
        label.text = "\(user?.username ?? "")"
        label.numberOfLines = 1
        label.textColor = .onBackground
        label.font = .headline4
        label.textAlignment = .center
        return label
    }()
    
    private lazy var displayNameTextView: DystoriaTextView = {
        let purple = UIColor.purple
        
        let textView = DystoriaTextView(placeholder: "Display Name...")
        textView.backgroundColor = .background
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 1
        textView.font = .headline4
        textView.textAlignment = .center
        textView.autocorrectEnabled = false
        textView.isHidden = true
        return textView
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "@\(user?.username ?? "")"
        label.numberOfLines = 1
        label.textColor = .onBackground
        label.font = .headline6
        label.textAlignment = .center
        return label
    }()
    
    private lazy var profileImagePicker: GPHMediaView = {
        let imageView = GPHMediaView()
        imageView.layer.cornerRadius = 16
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .background
        imageView.layer.masksToBounds = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSelectProfilePicture)))
        return imageView
    }()
    
    @objc private func showSelectProfilePicture() {
        showImagePickerFor(imageType: .profilePicture)
    }
    
    private lazy var coverImagePickerBackground: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .midBackground
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSelectCoverImage)))
        return imageView
    }()
    
    @objc private func showGifSelection() {
        
    }
    
    @objc private func showSelectCoverImage() {
        showImagePickerFor(imageType: .coverImage)
    }
    
    private func showImagePickerFor(imageType: ProfileImageType) {
        guard canEdit else { return }
        DispatchQueue.main.async {
            let config = ImagePickerConfiguration()
            config.allowMultiplePhotoSelection = false
            config.backgroundColor = .background
            config.galleryOnly = true
            config.gallerySeparatorColor = .surface
            let imagePicker = ImagePickerController(configuration: config)
            self.imagePicker = imagePicker
            self.imageToEdit = imageType
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private lazy var joinedLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.text = "Joined \(user?.created_at.formattedDateString() ?? "")"
        dateLabel.textColor = .icon
        dateLabel.textAlignment = .center
        dateLabel.font = .subtitle1
        dateLabel.snp.makeConstraints { make in
            make.height.equalTo(12)
            make.width.equalTo(dateLabel.text!.width(withConstrainedHeight: 12, font: .subtitle1))
        }
        
        return dateLabel
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(.back, for: .normal)
        button.backgroundColor = .background.withAlphaComponent(0.7)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(done), for: .touchUpInside)
        button.tintColor = .onBackground
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 3
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        gestureRecognizer.direction = .down
        collectionView.addGestureRecognizer(gestureRecognizer)
        return collectionView
    }()
    
    private(set) var selectedTabIndex: Int = 0
    
    private var isScrollingThroughFeed: Bool = false
        
    private lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .onBackground
        label.font = .subtitle1
        label.numberOfLines = 0
        label.attributedText = label.getAttributedString(input: user?.bio ?? "")
        label.addURLGestureRecognizer()
        return label
    }()
    
    private lazy var bioTextView: DystoriaTextView = {
        let purple = UIColor.purple
        
        let textView = DystoriaTextView(placeholder: "Bio...")
        textView.backgroundColor = .background
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 1
        textView.isHidden = true
        textView.textAlignment = .center
        textView.font = .subtitle1
        return textView
    }()
    
    private lazy var editProfileButton: UIButton = {
        let color = UIColor.clear
        
        let button = UIButton()
        button.setImage(.edit, for: .normal)
        button.backgroundColor = .background.withAlphaComponent(0.7)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 3
        button.layer.borderColor = color.cgColor
        button.addTarget(self, action: #selector(toggleEditing), for: .touchUpInside)
        button.tintColor = .onBackground
        return button
    }()
    
    private lazy var settingsButton: UIButton = {
        let color = UIColor.clear
        
        let button = UIButton()
        button.setImage(.settings, for: .normal)
        button.backgroundColor = .background.withAlphaComponent(0.7)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 3
        button.layer.borderColor = color.cgColor
        button.addTarget(self, action: #selector(goToSettings), for: .touchUpInside)
        button.tintColor = .onBackground
        return button
    }()
    
    init(id: UUID) {
        super.init(nibName: nil, bundle: nil)
        Task {
            user = await UserProfileService.shared.getUserWithId(id.uuidString.lowercased())
            likedPosts = await SocialInteractionService.shared.getLikedPosts(userId: id)
            DispatchQueue.main.async {
                self.setupConstraints()
                self.editProfileButton.isHidden = !self.canEdit
                self.settingsButton.isHidden = !self.canEdit
                self.collectionView.reloadData()
            }
            
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(self) deinited correctly")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editProfileButton.isHidden = user?.id != UserProfileService.shared.currentUser?.id
        settingsButton.isHidden = user?.id != UserProfileService.shared.currentUser?.id
    }
    
    @objc private func goToSettings() {
        navigateTo(.accountSettings)
    }
    
    private func setupConstraints() {
        view.backgroundColor = .background
        
        view.addSubview(coverImagePickerBackground)
        coverImagePickerBackground.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(view.snp.width).dividedBy(2)
        }
        
        view.addSubview(profileImagePicker)
        profileImagePicker.layer.masksToBounds = true
        profileImagePicker.contentMode = .scaleAspectFill
        profileImagePicker.layer.cornerRadius = 8
        profileImagePicker.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(coverImagePickerBackground.snp.bottom)
            make.height.width.equalTo(view.snp.width).dividedBy(3)
        }
        
        if let imageUrl = user?.avatar_url {
            Task {
                profileImagePicker.image = await CoreDataManager.shared.downloadOrRetrieveImage(imageUrl: imageUrl)
            }
        }
                
        if let imageUrl = user?.cover_image_url {
            Task {
                coverImagePickerBackground.image = await CoreDataManager.shared.downloadOrRetrieveImage(imageUrl: imageUrl)
            }
        }
        
        view.addSubview(displayNameLabel)
        displayNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImagePicker.snp.bottom).offset(CGFloat.spacing(.small))
            make.width.centerX.equalToSuperview()
            make.height.equalTo(24)
        }
        
        view.addSubview(displayNameTextView)
        displayNameTextView.snp.makeConstraints { make in
            make.top.equalTo(profileImagePicker.snp.bottom).offset(4)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview().offset(-4)
            make.height.equalTo(32)
        }
        
        view.addSubview(usernameLabel)
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(displayNameLabel.snp.bottom)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(24)
        }
        
        view.addSubview(joinedLabel)
        joinedLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(CGFloat.spacing(.small))
            make.width.equalToSuperview().dividedBy(1.7)
            make.height.equalTo(36)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(bioLabel)
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(joinedLabel.snp.bottom)
            make.width.equalTo(view.snp.width).dividedBy(1.3)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(bioTextView)
        bioTextView.snp.makeConstraints { make in
            make.top.equalTo(joinedLabel.snp.bottom).offset(4)
            make.width.equalTo(view.snp.width).dividedBy(1.3)
            make.height.equalTo(50)
            make.centerX.equalToSuperview().offset(-4)
        }
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.left.equalTo(view.safeAreaLayoutGuide).inset(CGFloat.padding)
            make.height.width.equalTo(40)
        }
        
        view.addSubview(editProfileButton)
        editProfileButton.snp.makeConstraints { make in
            make.top.right.equalTo(view.safeAreaLayoutGuide).inset(CGFloat.padding)
            make.height.width.equalTo(40)
        }
        
        view.addSubview(settingsButton)
        settingsButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(CGFloat.padding)
            make.trailing.equalTo(editProfileButton.snp.leading).offset(-CGFloat.padding)
            make.height.width.equalTo(40)
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .background
        collectionView.bounces = false
        collectionView.contentInset.bottom = 56 + .padding + .spacing
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ImagePostCollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: ImagePostCollectionViewCell.self))
        collectionView.register(
            ProfileTabHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ProfileTabHeader.reuseIdentifier)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(bioLabel.snp.bottom).offset(CGFloat.spacing(.large))
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc private func showGallerySelection() {
        cancelEditing()
        if let _ = navigationController {
            navigateTo(.gallerySelection)
        }
    }
    
    @objc private func done() {
        cancelEditing()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func toggleEditing() {
        self.editingIsEnabled = !self.editingIsEnabled
        
        displayNameLabel.isHidden = self.editingIsEnabled
        bioLabel.isHidden = self.editingIsEnabled
        
        profileImagePicker.isUserInteractionEnabled = self.editingIsEnabled
        coverImagePickerBackground.isUserInteractionEnabled = self.editingIsEnabled
        displayNameTextView.isHidden = !self.editingIsEnabled
        bioTextView.isHidden = !self.editingIsEnabled
        
        if self.editingIsEnabled {
            let color = UIColor.purple
            editProfileButton.layer.borderColor = color.cgColor
            bioTextView.text = bioLabel.text
            displayNameTextView.text = displayNameLabel.text
        } else {
            let color = UIColor.clear
            editProfileButton.layer.borderColor = color.cgColor
            
            guard var _ = UserProfileService.shared.currentUser else { fatalError() }
            let bio = bioTextView.text
            
            if bio?.count ?? 0 <= 200 && bio?.count ?? 0 > 0 && bio != bioLabel.text {
                bioLabel.attributedText = bioLabel.getAttributedString(input: bio ?? "")
                Task {
                    await UserProfileService.shared.updateBio(bio: bio)
                }
            }
            
            let displayName = displayNameTextView.text
            
            if displayName?.count ?? 0 <= 20 && displayName?.count ?? 0 > 0 && displayName != displayNameLabel.text  {
                displayNameLabel.text = displayName
                Task {
                    await UserProfileService.shared.updateDisplayName(name: displayName)
                }
            }
            
            dismissKeyboard()
        }
    }
    
    @objc func cancelEditing() {
        if self.editingIsEnabled {
            
            self.editingIsEnabled = false
            
            displayNameLabel.isHidden = false
            bioLabel.isHidden = false
            
            profileImagePicker.isUserInteractionEnabled = true
            coverImagePickerBackground.isUserInteractionEnabled = true
            displayNameTextView.isHidden = true
            bioTextView.isHidden = true
            
            let color = UIColor.clear
            editProfileButton.layer.borderColor = color.cgColor
            
            dismissKeyboard()
            
        } else { return }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ProfileVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likedPosts.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let threadsCount = likedPosts.count
        
        if threadsCount == 0 {
            
        }
        
        let postIndex = indexPath.row
        let content = likedPosts[postIndex]
        
        guard let imageCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UICollectionViewCell.cellIdentifierForType(
                type: ImagePostCollectionViewCell.self),
            for: indexPath) as? ImagePostCollectionViewCell else { fatalError() }
        
        imageCell.commentAction = { [weak self] (threadId: UUID) in
            guard let self = self else { return }
            guard let likedPost = self.likedPosts.first(where: {
                $0.post.id == threadId
            })?.post else { return }
            if likedPost.is_subscriber_only_content, UserProfileService.shared.currentUser?.is_subscribed == false {
                self.tabBarController?.selectedIndex = 1
                self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers?[1]
                return
            }
            self.navigateToPostBasedVC(.commentOnPost, false, likedPost, imageCell.userPostImageView.image)
        }
        
        imageCell.optionsAction = { [weak self] (post: Post?) in
            guard let self = self, let post = post, !post.is_subscriber_only_content || UserProfileService.shared.currentUser?.is_subscribed == true else { return }
            
            let viewController = OptionsSelectionVC()
            viewController.delegate = self
            self.postToAdd = post
            if let presentationController = viewController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium()]
            }
            
            self.present(viewController, animated: true)
        }
        
        imageCell.profileAction = { [weak self] (userId: UUID) in
            guard let self = self else { return }
            let profileVC = ProfileVC(id: userId)
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
        
        imageCell.likeAction = { [weak self] (id: UUID) in
            guard let userId = UserProfileService.shared.currentUser?.id else {
                return
            }
            Task {
                let _ = await SocialInteractionService.shared.likePost(
                    postId: id,
                    replyId: nil,
                    userId: userId)
            }
        }
        
        imageCell.moreAction = { [weak self] (content: Post?) in
            guard let self = self, let path = content?.media_url else { return }
            if content?.is_subscriber_only_content == true, UserProfileService.shared.currentUser?.is_subscribed == false {
                self.tabBarController?.selectedIndex = 1
                self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers?[1]
            } else {
                Task{
                    collectionView.isUserInteractionEnabled = false
                    guard let videoUrl = try? await SupabaseProvider.shared.storageClient(bucketName: "videos")?.createSignedURL(path: path, expiresIn: 3600) else { return }
                    let controller = VideoPlaybackViewController(url: videoUrl, post: content!)
                    collectionView.isUserInteractionEnabled = true
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true)
                }
            }
        }
        
        let uniqueId = Int.random(in: Int.min...Int.max) //<-practically unique
        imageCell.tag = uniqueId
        
        DispatchQueue.main.async {
            imageCell.configure(post: content.post, uniqueId: uniqueId, image: nil)
        }
        
        return imageCell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        return CGSize(width: screenWidth, height: ProfileTabHeader.preferredHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: ProfileTabHeader.reuseIdentifier,
                for: indexPath) as? ProfileTabHeader
        else {
            fatalError()
        }
        
        header.setupIfNeeded { [weak self] index in
            self?.selectedTabIndex = index
            self?.collectionView.reloadData()
        }
        
        return header
    }
    
    @objc fileprivate func handleSwipe() {
        cancelEditing()
        if isScrollingThroughFeed, (collectionView.layer.animationKeys() ?? []).isEmpty, collectionView.contentOffset.y == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.collectionView.snp.remakeConstraints { make in
                    make.top.equalTo(self.bioLabel.snp.bottom).offset(CGFloat.spacing(.large))
                    make.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
                }
                self.view.layoutIfNeeded()
            })
            isScrollingThroughFeed.toggle()
        }
    }
}

// MARK: UICollectionViewDelegate
extension ProfileVC: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isScrollingThroughFeed, collectionView.contentOffset.y == 0, (collectionView.layer.animationKeys() ?? []).isEmpty {
            UIView.animate(withDuration: 0.5, animations: {
                self.collectionView.snp.remakeConstraints { make in
                    make.top.equalTo(self.bioLabel.snp.bottom).offset(CGFloat.spacing(.large))
                    make.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
                }
                self.view.layoutIfNeeded()
            })
            isScrollingThroughFeed.toggle()
        } else if !isScrollingThroughFeed, scrollView.isDragging, (collectionView.layer.animationKeys() ?? []).isEmpty {
            UIView.animate(withDuration: 0.5, animations: {
                self.collectionView.snp.remakeConstraints { make in
                    make.top.equalTo(self.view.safeAreaLayoutGuide).offset(80)
                    make.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
                }
                self.view.layoutIfNeeded()
            })
            isScrollingThroughFeed.toggle()
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ProfileVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let post = likedPosts[indexPath.row].post
        return CGSize(width: collectionView.frame.width, height: ImagePostCollectionViewCell.height(post: post, tableViewWidth: collectionView.frame.width))
    }
}

extension ProfileVC: OptionsSelectionDelegate {
    func didSelectOption(_ option: OptionsSelectionVC.OptionAction) {
        switch option {
        case .report:
            let alert = UIAlertController(title: "Report this Creator?", message: "The creator is the owner of this app. If you'd like to report this content, please contact Apple Support or Math and Coffee at https://mathandcoffee.com.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        default:
            return
        }
    }
}

extension ProfileVC: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        DispatchQueue.main.async {
            imagePicker.dismiss(animated: true, completion: nil)
            if let photo = images.first, let data = photo.pngData() {
                Task {
                    guard let userId = UserProfileService.shared.currentUser?.id.uuidString.lowercased() else { return }
                    let id = UUID().uuidString
                    let filename = "\(id).png"
                    let storageClient = await SupabaseProvider.shared.storageClient()
                    guard let _ = try? await storageClient?.upload(path: "\(userId)/\(filename)", file: File(name: filename, data: data, fileName: filename, contentType: "image/png"), fileOptions: FileOptions(cacheControl: "3600")) else { return }
                    switch(self.imageToEdit) {
                    case .profilePicture:
                        let success = await UserProfileService.shared.updateProfileUrl(url: "\(userId)/\(filename)")
                        if success {
                            self.profileImagePicker.image = photo
                            self.imagePicker = nil
                        } else {
                            let alert = UIAlertController(title: "Server Error", message: "There was a problem with your request. Please check your connection and try again.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                        }
                    case .coverImage:
                        let success = await UserProfileService.shared.updateCoverPhoto(url: "\(userId)/\(filename)")
                        if success {
                            self.coverImagePickerBackground.image = photo
                            self.imagePicker = nil
                        } else {
                            let alert = UIAlertController(title: "Server Error", message: "There was a problem with your request. Please check your connection and try again.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        DispatchQueue.main.async {
            if let photo = images.first, let data = photo.pngData() {
                imagePicker.dismiss(animated: true, completion: nil)
                Task {
                    guard let userId = UserProfileService.shared.currentUser?.id.uuidString.lowercased() else { return }
                    let id = UUID().uuidString
                    let filename = "\(id).png"
                    let storageClient = await SupabaseProvider.shared.storageClient()
                    guard let _ = try? await storageClient?.upload(path: "\(userId)/\(filename)", file: File(name: filename, data: data, fileName: filename, contentType: "image/png"), fileOptions: FileOptions(cacheControl: "3600")) else { return }
                    switch(self.imageToEdit) {
                    case .profilePicture:
                        let success = await UserProfileService.shared.updateProfileUrl(url: "\(userId)/\(filename)")
                        if success {
                            self.profileImagePicker.image = photo
                            self.imagePicker = nil
                        } else {
                            let alert = UIAlertController(title: "Server Error", message: "There was a problem with your request. Please check your connection and try again.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                        }
                    case .coverImage:
                        let success = await UserProfileService.shared.updateCoverPhoto(url: "\(userId)/\(filename)")
                        if success {
                            self.coverImagePickerBackground.image = photo
                            self.imagePicker = nil
                        } else {
                            let alert = UIAlertController(title: "Server Error", message: "There was a problem with your request. Please check your connection and try again.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
        self.imagePicker = nil
    }
}
