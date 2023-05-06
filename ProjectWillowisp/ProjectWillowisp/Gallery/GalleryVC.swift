//
//  GalleryVC.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/12/23.
//

import UIKit
import Combine
import Nuke

protocol GallerySelectionDelegate: UIViewController {
    func didSelectPost(_ post: Post)
}

final class GalleryVC: UIViewController {
    
    let viewModel = GalleryViewModel()
    
    private lazy var searchBar: UISearchBar = {
        let controller = UISearchBar()
        let textFieldInsideSearchBar = controller.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .onBackground
        controller.barStyle = UIBarStyle.default
        controller.barTintColor = UIColor.surface
        controller.backgroundColor = UIColor.surface
        controller.tintColor = .onBackground
        controller.showsCancelButton = true
        controller.delegate = self
        controller.isHidden = true
        return controller
    }()
    
    private let selectionEnabled: Bool
    
    weak var delegate: GallerySelectionDelegate?
    
    private var extraview : UIView = UIView()
    
    private let logo = UIImageView()
        
    private lazy var navigationView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .background
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.width.leading.trailing.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(56)
        }
        
        let searchButton = UIButton()
        searchButton.setImage(.search, for: .normal)
        searchButton.addTarget(self, action: #selector(showSearch), for: .touchUpInside)
        searchButton.imageView?.tintColor = .onPrimary
        view.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(48)
        }
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(logo)
        logo.image = .logoBanner
        logo.contentMode = .scaleAspectFit
        logo.snp.makeConstraints { make in
            make.leading.equalTo(view).inset(CGFloat.padding)
            make.centerY.equalTo(view)
            make.height.equalTo(56)
            make.width.equalTo(88)
        }
        
        return view
    }()
    
    private lazy var layout = GalleryLayout()
    
    private lazy var collectionView: UICollectionView = {
        layout.delegate = self
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            GalleryCollectionViewCell.self,
            forCellWithReuseIdentifier: UICollectionViewCell.cellIdentifierForType(
                type: GalleryCollectionViewCell.self))
        collectionView.dataSource = self
        collectionView.backgroundColor = .background
        return collectionView
    }()
    
    init(selectionEnabled: Bool) {
        self.selectionEnabled = selectionEnabled
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await viewModel.fetchPosts()
            collectionView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if searchBar.searchTextField.isEditing { view.endEditing(true) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        view.backgroundColor = .background
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissTextField)))
        
        view.addSubview(navigationView)
        navigationView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(56)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(navigationView.snp.bottom).offset(CGFloat.padding(.small))
        }
    }
    
    @objc private func showSearch() {
        searchBar.isHidden = false
        logo.isHidden = true
        searchBar.searchTextField.becomeFirstResponder()
    }
    
    @objc private func dismissTextField() {
        view.endEditing(true)
        searchBar.isHidden = true
        logo.isHidden = false
        let _ = searchBar.searchTextField.resignFirstResponder()
        searchBar.text = ""
        searchBar(searchBar, textDidChange: "")
    }
}

extension GalleryVC: GalleryLayoutDelegate {
    func collectionView(
          _ collectionView: UICollectionView,
          heightForPhotoAtIndexPath indexPath:IndexPath
    ) -> CGFloat {
        return ((collectionView.frame.width / 3.0) - 12) * (viewModel.posts[indexPath.item].media_aspect ?? 1.0)
    }
}

extension GalleryVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = viewModel.posts[indexPath.item]
        
        guard let imageCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UICollectionViewCell.cellIdentifierForType(
                type: GalleryCollectionViewCell.self),
            for: indexPath) as? GalleryCollectionViewCell else { fatalError() }
        
        imageCell.actionOnSelect = { [weak self] in
            guard let self = self else { return }
            if self.selectionEnabled {
                self.delegate?.didSelectPost(post)
                self.navigationController?.popViewController(animated: true)
                return
            }
            self.navigateToPostBasedVC(.commentOnPost, false, post, imageCell.galleryImageView.image)
        }
        
        imageCell.playlistAction = { [weak self] post in
            guard let self = self else { return }
            let viewController = OptionsSelectionVC()
            self.viewModel.postToAdd = post
            viewController.delegate = self
            if let presentationController = viewController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium()]
            }
            
            self.present(viewController, animated: true)
        }
        
        if let imageUrl = post.media_thumbnail_url {
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
                imageCell.configure(post: post, image: image, gifId: nil)
            }
        } else if let imageUrl = post.media_url {
            if post.media_type == .image {
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
                    imageCell.configure(post: post, image: image, gifId: nil)
                }
            } else if post.media_type == .gif {
                imageCell.configure(post: post, image: nil, gifId: imageUrl)
            }
        }
        return imageCell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel.posts.count
    }
}

extension GalleryVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filter(text: searchText)
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutSubviews()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        searchBar.isHidden = true
        logo.isHidden = false
        let _ = searchBar.searchTextField.resignFirstResponder()
        searchBar.text = nil
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.filter(text: "")
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutSubviews()
        view.endEditing(true)
        searchBar.isHidden = true
        logo.isHidden = false
        let _ = searchBar.searchTextField.resignFirstResponder()
        searchBar.text = nil
    }
}

extension GalleryVC: AddToPlaylistDelegate {
    
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

extension GalleryVC: OptionsSelectionDelegate {
    
    func didSelectOption(_ option: OptionsSelectionVC.OptionAction) {
        switch (option) {
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
