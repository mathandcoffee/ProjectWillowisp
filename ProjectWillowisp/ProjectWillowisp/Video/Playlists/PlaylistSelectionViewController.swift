//
//  PlaylistSelectionViewController.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/18/23.
//

import UIKit

protocol PlaylistSelectionDelegate: UIViewController {
    func selectedItem(_ playlistItem: Post, _ index: Int)
}

final class PlaylistSelectionViewController: UIViewController {
    
    private let playlist: [Post]
    
    weak var delegate: PlaylistSelectionDelegate?
    
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
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(.back, for: .normal)
        button.backgroundColor = .background
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        button.tintColor = .onBackground
        return button
    }()
    
    init(playlist: [Post]) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        view.backgroundColor = .background
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(CGFloat.padding)
            make.height.width.equalTo(48)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.width.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalToSuperview().offset(64)
        }
    }
    
    @objc private func back() {
        dismiss(animated: true)
    }
}

extension PlaylistSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 90 + CGFloat.padding * 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Task {
            let playlistItem = playlist[indexPath.row]
            dismiss(animated: true) {
                self.delegate?.selectedItem(playlistItem, indexPath.row)
            }
        }
    }
}

extension PlaylistSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlist.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UICollectionViewCell.cellIdentifierForType(
                type: PlaylistCell.self
            ),
            for: indexPath
        ) as? PlaylistCell else { fatalError() }
        
        let playlistItem = playlist[indexPath.row]
        
        cell.configure(playlistItem: playlistItem)
        
        return cell
    }
}
