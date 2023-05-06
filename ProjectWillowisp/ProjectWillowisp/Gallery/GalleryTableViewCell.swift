//
//  GalleryCollectionViewCell.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/12/23.
//

import UIKit
import GiphyUISDK

final class GalleryCollectionViewCell: UICollectionViewCell {
    
    private var post: Post? = nil
    
    var playlistAction: ((Post) -> Void)?
    
    private(set) lazy var galleryImageView: GPHMediaView = {
        let view = GPHMediaView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performAction)))
        view.layer.cornerRadius = 8
        return view
    }()
    
    private(set) lazy var playlistButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.square.on.square"), for: .normal)
        button.addTarget(self, action: #selector(playlistActionPressed), for: .touchUpInside)
        button.backgroundColor = .surface.withAlphaComponent(0.5)
        button.tintColor = .onBackground
        button.layer.cornerRadius = 4
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return button
    }()
    
    var actionOnSelect: (() -> Void)?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        galleryImageView.image = nil
        galleryImageView.media = nil
    }
    
    private func setupIfNeeded() {
        if galleryImageView.superview != nil { return }
        
        addSubview(galleryImageView)
        galleryImageView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.width.height.equalToSuperview()
        }
        
        addSubview(playlistButton)
        playlistButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.width.equalToSuperview().dividedBy(4.0)
            make.height.equalTo(playlistButton.snp.width)
        }
    }
    
    func configure(post: Post, image: UIImage?, gifId: String?) {
        setupIfNeeded()
        self.post = post
        if let gifId = gifId {
            let id = String(gifId.split(separator: "-").last!)
                GiphyCore.shared.gifByID(id) { (response, error) in
                    if let media = response?.data {
                        DispatchQueue.main.sync { [weak self] in
                            self?.galleryImageView.media = media
                        }
                    }
                }
            return
        }
        galleryImageView.image = image
    }
    
    static func height(tableViewWidth: CGFloat, aspectRatio: CGFloat) -> CGFloat {
        return (tableViewWidth / 3.0) * aspectRatio
    }
    
    @objc private func performAction() {
        actionOnSelect?()
    }
    
    @objc private func playlistActionPressed() {
        guard let post = post else { return }
        playlistAction?(post)
    }
}
