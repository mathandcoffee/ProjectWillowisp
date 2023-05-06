//
//  PlaylistCells.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/18/23.
//

import UIKit

final class PlaylistCell: UICollectionViewCell {
    
    private var imageTask: Task<Void, Never>?
    
    private lazy var playlistThumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        
        imageView.addSubview(durationlabel)
        durationlabel.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview()
            make.height.equalTo(24)
            make.width.equalTo(72)
        }
        
        return imageView
    }()
    
    private(set) lazy var durationlabel: UILabel = {
        let label = UILabel()
        label.font = .headline5
        label.textColor = .onBackground
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = .background.withAlphaComponent(0.6)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        label.layer.maskedCorners = [.layerMinXMinYCorner]
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .onBackground
        label.font = .body1
        label.numberOfLines = 2
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .onBackground
        label.font = .body2
        label.numberOfLines = 1
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override func prepareForReuse() {
        titleLabel.text = nil
        playlistThumbnailImageView.image = nil
        imageTask?.cancel()
        imageTask = nil
    }
    
    func configure(playlist: Playlist) {
        setupIfNeeded()
        titleLabel.text = playlist.name
        durationlabel.isHidden = true
        subTitleLabel.text = "\(playlist.playlistItems.count) Videos"

        if let playlistItemMediaUrl = playlist.playlistItems.first?.post?.media_thumbnail_url {
            
            imageTask = Task {
                let image = await CoreDataManager.shared.downloadOrRetrieveImage(imageUrl: playlistItemMediaUrl)
                DispatchQueue.main.async {
                    self.playlistThumbnailImageView.image = image
                }
            }
        }
    }
    
    func configure(playlistItem: Post) {
        setupIfNeeded()
        titleLabel.text = playlistItem.title
        guard let playlistItemMediaUrl = playlistItem.media_thumbnail_url else {
            return
        }
        
        if let duration = playlistItem.duration {
            durationlabel.text = duration
            durationlabel.isHidden = false
        } else {
            durationlabel.text = ""
            durationlabel.isHidden = true
        }
        
        imageTask = Task {
            let image = await CoreDataManager.shared.downloadOrRetrieveImage(imageUrl: playlistItemMediaUrl)
            DispatchQueue.main.async {
                self.playlistThumbnailImageView.image = image
            }
        }
    }
    
    private func setupIfNeeded() {
        guard playlistThumbnailImageView.superview == nil else { return }
        addSubview(playlistThumbnailImageView)
        addSubview(subTitleLabel)
        addSubview(titleLabel)
        
        playlistThumbnailImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(CGFloat.padding)
            make.width.equalTo(160)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(CGFloat.padding)
            make.leading.equalTo(playlistThumbnailImageView.snp.trailing).offset(CGFloat.padding)
            make.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(CGFloat.padding)
            make.bottom.equalTo(subTitleLabel.snp.top).offset(CGFloat.padding(.small))
            make.leading.equalTo(playlistThumbnailImageView.snp.trailing).offset(CGFloat.padding)
        }
        let view = UIView()
        view.backgroundColor = .surface
        addSubview(view)
        view.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(2.0)
        }
    }
}
