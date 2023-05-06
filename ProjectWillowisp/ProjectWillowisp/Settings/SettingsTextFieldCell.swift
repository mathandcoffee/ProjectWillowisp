//
//  SettingsTextFieldCell.swift
//  Strive
//
//  Created by Tommy Martin on 6/24/21.
//  Copyright © 2021 Strive. All rights reserved.
//

import UIKit

class SettingsTextFieldCell: UITableViewCell {
    static let height: CGFloat = 44
    static let reuseIdentifier = "settings_text_field_cell"
    
    let textField = UITextField()
    
    func configure(initialValue: String? = nil, placeholder: String? = nil) {
        setupIfNeeded(initialValue: initialValue, placeholder: placeholder)
    }
    
    private func setupIfNeeded(initialValue: String?, placeholder: String?) {
        guard textField.superview == nil else {
            return
        }
        
        backgroundColor = .background
        contentView.backgroundColor = .background
        selectionStyle = .none
        
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.placeholder = placeholder
        textField.text = initialValue
        textField.font = .subtitle1
        textField.textColor = .onPrimary
        textField.overrideUserInterfaceStyle = .light
        contentView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
    }
}
