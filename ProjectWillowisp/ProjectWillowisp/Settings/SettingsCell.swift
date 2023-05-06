//
//  SettingsCell.swift
//  Strive
//
//  Created by Tommy Martin on 6/24/21.
//  Copyright © 2021 Strive. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    static let height: CGFloat = 44
    class var reuseIdentifier: String {
        return "settings_cell"
    }
    
    let titleLabel = UILabel()
    let valueLabel = UILabel()
    
    func configure(title: String, value: String?, showDisclosure: Bool = false) {
        DispatchQueue.main.async {
            self.setupIfNeeded()
            self.titleLabel.text = title
            self.valueLabel.text = value
            self.accessoryType = showDisclosure ? .disclosureIndicator : .none
        }
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
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        valueLabel.font = .body1
        valueLabel.textColor = UIColor.onBackground.withAlphaComponent(0.6)
        contentView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
    }
}
