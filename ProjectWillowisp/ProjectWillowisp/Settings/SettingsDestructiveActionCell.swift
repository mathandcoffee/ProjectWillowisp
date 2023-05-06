//
//  SettingsDestructiveActionCell.swift
//  Strive
//
//  Created by Tommy Martin on 6/24/21.
//  Copyright © 2021 Strive. All rights reserved.
//

import UIKit

class SettingsDestructiveActionCell: SettingsCell {
    override class var reuseIdentifier: String {
        return "settings_destructive_action_cell"
    }
    
    func configure(title: String) {
        super.configure(title: title, value: nil)
    }
    
    override func setupIfNeeded() {
        super.setupIfNeeded()
        titleLabel.textColor = .red
        titleLabel.font = .button
        titleLabel.snp.removeConstraints()
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
