//
//  DashboardVC.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 8/8/22.
//

import UIKit
import Combine

final class FeedVC: BaseViewController {
    
    typealias STATE = FeedState
    
    typealias EVENT = FeedEvent
    
    typealias VIEWMODEL = FeedViewModel
    
    var stateSubscription: AnyCancellable?
    
    var eventSubscription: AnyCancellable?
    
    var viewModel: FeedViewModel = FeedViewModel(initialState: FeedState(createdAt: Date(), posts: []))
    
    private lazy var newPostButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .primary
        button.imageView?.tintColor = .onPrimary
        button.setImage(.plus, for: .normal)
        button.layer.cornerRadius = 28
        button.addTarget(self, action: #selector(showNewPostVC), for: .touchUpInside)
        return button
    }()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupView()
        setupViewModelObservers()
        viewModel.subscribeToRealtime()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        queryPosts()
    }
    
    func renderState(state: FeedState) {
        if state.posts.count != self.collectionView.numberOfItems(inSection: 0) {
            self.collectionView.reloadData()
        }
    }
    
    func handleEvent(event: FeedEvent) {
        switch event {
        case .newPostsAvailable:
            Task {
                await SocialInteractionService.shared.retrievePosts()
            }
        }
    }
    
    private func setupView() {
        view.backgroundColor = .background
        setupNavigationSection()
        setupCollectionView()
    }
    
    // MARK: Navigation Elements
    private let notificationsButton = BadgeButton()
    private let profileButton = UIButton()
    private let logo = UIImageView()
    private let navigationItemBackground = UIView()
    
    // MARK: CollectionView
    
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
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var adRefreshTimer: Timer?
    
    deinit {
        print("\(self) deinited correctly")
    }
    
    @objc private func showNewPostVC() {
        navigateTo(.newPost)
    }
    
    private func queryPosts() {
        activityIndicator.startAnimating()
        Task {
            await viewModel.fetchPosts()
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func setupNavigationSection() {
        view.addSubview(navigationItemBackground)
        navigationItemBackground.backgroundColor = .surface
        navigationItemBackground.snp.makeConstraints { make in
            make.top.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view.frame.width + 24)
            make.height.equalTo(56)
        }
        
        view.addSubview(notificationsButton)
        notificationsButton.setImage(.notifications, for: .normal)
        notificationsButton.tintColor = .onPrimary
        notificationsButton.addTarget(self, action: #selector(goToNotifications), for: .touchUpInside)
        notificationsButton.snp.makeConstraints { make in
            make.centerY.equalTo(navigationItemBackground)
            make.right.equalToSuperview().offset(-CGFloat.padding - 12)
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
        logo.image = .logoBanner.withRenderingMode(.alwaysTemplate)
        logo.contentMode = .scaleAspectFit
        logo.tintColor = .onBackground
        logo.snp.makeConstraints { make in
            make.centerX.equalTo(navigationItemBackground)
            make.centerY.equalTo(navigationItemBackground)
            make.height.equalTo(32)
            make.width.equalTo(88)
        }
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
        
        view.addSubview(newPostButton)
        newPostButton.snp.makeConstraints { make in
            make.bottom.right.equalTo(view.safeAreaLayoutGuide).inset(CGFloat.padding)
            make.height.width.equalTo(56)
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

extension FeedVC: UICollectionViewDelegateFlowLayout {
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
        let post = viewModel.currentState.posts[indexPath.row]
        return CGSize(width: collectionView.frame.width, height: ImagePostCollectionViewCell.height(post: post, tableViewWidth: collectionView.frame.width))
    }
}

extension FeedVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let threadsCount = viewModel.currentState.posts.count
        
        if threadsCount == 0 {
            
        }
        
        let postIndex = indexPath.row
        let post = viewModel.currentState.posts[postIndex]
        
        guard let imageCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UICollectionViewCell.cellIdentifierForType(
                type: ImagePostCollectionViewCell.self),
            for: indexPath) as? ImagePostCollectionViewCell else { fatalError() }
        
        imageCell.commentAction = { [weak self] (threadId: UUID) in
            guard let self = self else { return }
            
            guard let post = SocialInteractionService.shared.currentPremiumPosts.first(where: {
                $0.id == threadId
            }) else { return }
            
        }
        
        imageCell.profileAction = { [weak self] (userId: UUID) in
            guard let self = self else { return }
            let profileVC = ProfileVC(id: userId)
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
        
        imageCell.likeAction = { [weak self] (threadId: UUID?) in
            guard let self = self, let userId = UserProfileService.shared.currentUser?.id, let id = threadId else {
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
        let uniqueId = Int.random(in: Int.min...Int.max) //<-practically unique
        imageCell.tag = uniqueId
        
        return imageCell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel.currentState.posts.count
    }
}
