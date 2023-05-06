//
//  MainSettingsCell.swift
//  mac-dystoria-ios
//
//  Created by Nick Palastro on 1/21/22.
//

import UIKit

class MainSettingsCell: UITableViewCell {
    static let height: CGFloat = 50
    class var reuseIdentifier: String {
        return "main_settings_cell"
    }
    
    let titleLabel = UILabel()
    let imageButton = UIButton()  //Better class than UIButton here?
    
    func configure(title: String, image: String, showDisclosure: Bool = false) {
        guard let useableImage = UIImage(named: image) else {
            fatalError("No image with name \(image)")
        }
        
        setupIfNeeded()
        titleLabel.text = title
        imageButton.setImage(useableImage, for: .normal)
        accessoryType = showDisclosure ? .disclosureIndicator : .none
    }
    
    func setupIfNeeded() {
        guard titleLabel.superview == nil else {
            return
        }
        
        backgroundColor = .background
        contentView.backgroundColor = .background
        selectionStyle = .none
        
        imageButton.backgroundColor = .background
        imageButton.imageView?.tintColor = .onBackground
        contentView.addSubview(imageButton)
        imageButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(40)
            make.left.equalToSuperview().inset(CGFloat.padding)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.font = .headline3
        titleLabel.textColor = .onBackground
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(imageButton.snp.right).offset(CGFloat.padding)
            make.right.equalToSuperview().offset(CGFloat.padding)
            make.centerY.equalToSuperview()
        }
    }
}

