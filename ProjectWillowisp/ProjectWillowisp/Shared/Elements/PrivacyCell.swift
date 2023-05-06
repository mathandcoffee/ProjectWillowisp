//
//  PrivacyCell.swift
//  mac-dystoria-ios
//
//  Created by Nick Palastro on 1/24/22.
//

import UIKit

final class PrivacyCell: UITableViewCell {
    static let height: CGFloat = 50
    class var reuseIdentifier: String {
        return "privacy_cell"
    }
    
    let titleLabel = UILabel()
    
    func configure(title: String, showDisclosure: Bool = false) {
        setupIfNeeded()
        titleLabel.text = title
        accessoryType = showDisclosure ? .disclosureIndicator : .none
    }
    
    func setupIfNeeded() {
        guard titleLabel.superview == nil else {
            return
        }
        
        backgroundColor = .background
        contentView.backgroundColor = .background
        selectionStyle = .none
        
        titleLabel.font = .subtitle1
        titleLabel.textColor = .onBackground
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
    }
}
