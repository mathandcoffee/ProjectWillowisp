//
//  VideoPlayerViewController.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/7/23.
//

import UIKit
import AVFoundation
import AVKit
import Combine
import UserNotifications
import OneSignal

final class ContentListViewController: BaseViewController {
    
    typealias STATE = VideoListState
    
    typealias EVENT = VideoListEvent
    
    typealias VIEWMODEL = ContentListViewModel
    
    var stateSubscription: AnyCancellable?
    
    var eventSubscription: AnyCancellable?
    
    let viewModel = ContentListViewModel(initialState: VideoListState(createdAt: Date(), videos: []))
    
    private var isScrolling: Bool = false
    
    private let notificationsButton = BadgeButton()
    private let profileButton = UIButton()
    private let logo = UIImageView()
    private let navigationItemBackground = UIView()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(
            ImagePostCollectionViewCell.self,
            forCellWithReuseIdentifier: UICollectionViewCell.cellIdentifierForType(
                type: ImagePostCollectionViewCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .background
        return collectionView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .onBackground
        view.hidesWhenStopped = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await viewModel.fetchContent()
            collectionView.reloadData()
        }
    }
    
    private func setupView() {
        view.backgroundColor = .background
        setupNavigationSection()
        setupCollectionView()
        setupViewModelObservers()
        
        let current = UNUserNotificationCenter.current()

        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                DispatchQueue.main.async {
                    let notificationsView = NotificationPermissionView()
                    self.view.addSubview(notificationsView)
                    notificationsView.snp.makeConstraints { make in
                        make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(CGFloat.padding(.large))
                        make.top.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(150)
                    }
                }
            }
        })
    }
    
    private func setupNavigationSection() {
        view.addSubview(navigationItemBackground)
        navigationItemBackground.backgroundColor = .background
        navigationItemBackground.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.width.leading.trailing.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(56)
        }
        
        view.addSubview(notificationsButton)
        notificationsButton.setImage(.notifications, for: .normal)
        notificationsButton.tintColor = .onPrimary
        notificationsButton.addTarget(self, action: #selector(goToNotifications), for: .touchUpInside)
        notificationsButton.snp.makeConstraints { make in
            make.centerY.equalTo(navigationItemBackground)
            make.trailing.equalToSuperview().offset(-CGFloat.padding - 12)
            make.height.width.equalTo(CGFloat.iconSize)
        }
        
        view.addSubview(profileButton)
        profileButton.setImage(UIImage(systemName: "person.crop.circle"), for: .normal)
        profileButton.tintColor = .onPrimary
        profileButton.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
        profileButton.snp.makeConstraints { make in
            make.centerY.equalTo(navigationItemBackground)
            make.trailing.equalTo(notificationsButton.snp.leading).offset(-CGFloat.padding - 12)
            make.height.width.equalTo(CGFloat.iconSize)
        }
        
        view.addSubview(logo)
        logo.image = .logoBanner
        logo.contentMode = .scaleAspectFit
        logo.snp.makeConstraints { make in
            make.leading.equalTo(navigationItemBackground).inset(CGFloat.padding)
            make.centerY.equalTo(navigationItemBackground)
            make.height.equalTo(56)
            make.width.equalTo(88)
        }
    }
    
    func renderState(state: VideoListState) {
        if state.videos.count != self.collectionView.numberOfItems(inSection: 0) {
            self.collectionView.reloadData()
        }
    }
    
    func handleEvent(event: VideoListEvent) {
        
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.width.centerX.equalToSuperview()
            make.top.equalTo(navigationItemBackground.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.top.equalTo(collectionView)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(64)
        }
    }
    
    @objc private func goToNotifications() {
        navigateTo(.notifications)
    }
    
    @objc private func goToProfile() {
        guard let id = UserProfileService.shared.currentUser?.id else { return }
        navigationController?.pushViewController(ProfileVC(id: id), animated: true)
    }
}

extension ContentListViewController: UICollectionViewDelegateFlowLayout {
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
        let post = viewModel.currentVideos[indexPath.row]
        return CGSize(width: collectionView.frame.width, height: ImagePostCollectionViewCell.height(post: post, tableViewWidth: collectionView.frame.width))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isScrolling, collectionView.contentOffset.y <= 58.0, (collectionView.layer.animationKeys() ?? []).isEmpty {
            UIView.animate(withDuration: 0.5, animations: {
                self.collectionView.snp.remakeConstraints { make in
                    make.top.equalTo(self.navigationItemBackground.snp.bottom)
                    make.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
                }
                self.view.layoutIfNeeded()
                
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.isScrolling.toggle()
                }
            })
        } else if !isScrolling, (collectionView.layer.animationKeys() ?? []).isEmpty {
            UIView.animate(withDuration: 0.5, animations: {
                self.collectionView.snp.remakeConstraints { make in
                    make.top.equalTo(self.view.safeAreaLayoutGuide)
                    make.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
                }
                self.view.layoutIfNeeded()
            })
            isScrolling.toggle()
        }
    }
}

extension ContentListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let threadsCount = viewModel.currentVideos.count
        
        if threadsCount == 0 {
            
        }
        
        let postIndex = indexPath.row
        let content = viewModel.currentVideos[postIndex]
        
        guard let imageCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UICollectionViewCell.cellIdentifierForType(
                type: ImagePostCollectionViewCell.self),
            for: indexPath) as? ImagePostCollectionViewCell else { fatalError() }
        
        imageCell.commentAction = { [weak self] (threadId: UUID) in
            guard let self = self else { return }
            guard let post = self.viewModel.currentVideos.first(where: {
                $0.id == threadId
            }) else { return }
            if post.is_subscriber_only_content, UserProfileService.shared.currentUser?.is_subscribed == false {
                self.tabBarController?.selectedIndex = 1
                self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers?[1]
                return
            }
            self.navigateToPostBasedVC(.commentOnPost, false, post, imageCell.userPostImageView.image)
        }
        
        imageCell.optionsAction = { [weak self] (post: Post?) in
            guard let self = self, let post = post, !post.is_subscriber_only_content || UserProfileService.shared.currentUser?.is_subscribed == true else { return }
            
            let viewController = OptionsSelectionVC()
            viewController.delegate = self
            self.viewModel.postToAdd = post
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
                    controller.modalPresentationStyle = .fullScreen
                    collectionView.isUserInteractionEnabled = true
                    self.present(controller, animated: true)
                }
            }
        }
        
        let uniqueId = Int.random(in: Int.min...Int.max) //<-practically unique
        imageCell.tag = uniqueId
        
        DispatchQueue.main.async {
            imageCell.configure(post: content, uniqueId: uniqueId, image: nil)
        }
        
        return imageCell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel.currentVideos.count
    }
}

extension ContentListViewController: AddToPlaylistDelegate {
    
    func didSelectPlaylist(_ playlist: Playlist) {
        guard let postToAdd = viewModel.postToAdd else { return }
        let playlistItemsDatabase = SupabaseProvider.shared.playlistItemsDatabase
        Task {
            do {
                let _ = try await playlistItemsDatabase.insert(
                    values: PlaylistItemRequestPacket(
                        post: postToAdd,
                        playlistId: playlist.id)
                ).execute().value
            } catch {
                let alert = UIAlertController(title: "Server Error", message: "There was a problem with your request. Please check your connection and try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
            viewModel.postToAdd = nil
        }
    }
}

extension ContentListViewController: OptionsSelectionDelegate {
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
            guard let post = viewModel.postToAdd else { return }
            let viewController = NewPlaylistViewController(post: post)
            if let presentationController = viewController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium()]
            }
            present(viewController, animated: true)
        case .report:
            let alert = UIAlertController(title: "Report this Creator?", message: "The creator is the owner of this app. If you'd like to report this content, please contact Apple Support or Math and Coffee at https://mathandcoffee.com.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        default:
            return
        }
    }
}
