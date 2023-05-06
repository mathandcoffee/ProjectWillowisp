//
//  PlaylistViewController.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/18/23.
//

import UIKit

protocol AddToPlaylistDelegate: UIViewController {
    
    func didSelectPlaylist(_ playlist: Playlist)
}

final class PlaylistViewController: UIViewController {
    
    weak var delegate: AddToPlaylistDelegate?
    
    private lazy var playlistCreatorSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.selectedSegmentTintColor = .darkPrimary
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.onBackground], for: .normal)
        segmentedControl.insertSegment(
            action: UIAction(title: "Creator Playlists", handler: { [weak self] _ in
                self?.viewModel.setUseCreatedPlaylistsOnly(true)
                self?.collectionView.reloadData()
        }), at: 0, animated: false)
        segmentedControl.insertSegment(
            action: UIAction(title: "Your Playlists", handler: { [weak self] _ in
                self?.viewModel.setUseCreatedPlaylistsOnly(false)
                self?.collectionView.reloadData()
        }), at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(PlaylistCell.self, forCellWithReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: PlaylistCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .background
        return collectionView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let controller = UISearchBar()
        let textFieldInsideSearchBar = controller.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .onBackground
        controller.barStyle = UIBarStyle.default
        controller.barTintColor = UIColor.surface
        controller.backgroundColor = UIColor.surface
        controller.tintColor = .onPrimary
        controller.delegate = self
        controller.isHidden = true
        controller.showsCancelButton = true
        return controller
    }()
    
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
    
    private let viewModel = PlaylistViewModel()
    
    init(onlyShowYourLists: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        setupView(onlyShowYourLists)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await viewModel.fetchPlaylists()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if searchBar.searchTextField.isEditing { view.endEditing(true) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(_ onlyShowYourLists: Bool) {
        view.backgroundColor = .background
        
        view.addSubview(navigationView)
        navigationView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(56)
        }
        
        if onlyShowYourLists {
            view.addSubview(collectionView)
            collectionView.snp.makeConstraints { make in
                make.bottom.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            }
            
            viewModel.setUseCreatedPlaylistsOnly(false)
            collectionView.reloadData()
            return
        }
        
        view.addSubview(playlistCreatorSegmentedControl)
        playlistCreatorSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(playlistCreatorSegmentedControl.snp.bottom).offset(CGFloat.padding(.small))
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
        let _ = searchBar.searchTextField.resignFirstResponder()
        searchBar.text = ""
        searchBar(searchBar, textDidChange: "")
    }
}

extension PlaylistViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 90 + CGFloat.padding * 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let delegate = delegate {
            let playlist = viewModel.currentPlaylists[indexPath.row]
            delegate.didSelectPlaylist(playlist)
            dismiss(animated: true)
            return
        }
        Task {
            collectionView.isUserInteractionEnabled = false
            let playlist = viewModel.currentPlaylists[indexPath.row]
            let posts = playlist.playlistItems.map { $0.post! }
            var playlistUrls: [URL] = []
            for playlistItem in playlist.playlistItems {
                guard let mediaUrl = playlistItem.post?.media_url else {
                    continue
                }
                guard let videoUrl = try? await SupabaseProvider.shared.storageClient(bucketName: "videos")?.createSignedURL(path: mediaUrl, expiresIn: 3600) else { return }
                playlistUrls.append(videoUrl)
            }
            collectionView.isUserInteractionEnabled = true
            let controller = VideoPlaybackViewController(urls: playlistUrls, posts: posts)
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true)
        }
    }
}

extension PlaylistViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.currentPlaylists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UICollectionViewCell.cellIdentifierForType(
                type: PlaylistCell.self
            ),
            for: indexPath
        ) as? PlaylistCell else { fatalError() }
        
        let playlist = viewModel.currentPlaylists[indexPath.row]
        
        cell.configure(playlist: playlist)
        
        return cell
    }
}

extension PlaylistViewController: UISearchBarDelegate {
    
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
        logo.isHidden = false
        let _ = searchBar.searchTextField.resignFirstResponder()
        searchBar.text = nil
    }
}
