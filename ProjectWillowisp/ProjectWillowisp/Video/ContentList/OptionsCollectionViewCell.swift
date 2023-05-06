//
//  OptionsCollectionViewCell.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 3/23/23.
//

import UIKit

class OptionsCollectionViewCell: UICollectionViewCell {
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .onBackground
        label.font = .body1
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .onBackground
        return imageView
    }()
    
    func configure(image: UIImage?, text: String?) {
        setupIfNeeded()
        imageView.image = image
        label.text = text
    }
    
    func setupIfNeeded() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(CGFloat.padding)
            make.height.width.equalTo(24)
        }
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(CGFloat.padding)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(CGFloat.padding)
            make.height.equalTo(24)
        }
    }
}
