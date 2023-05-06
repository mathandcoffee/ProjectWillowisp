//
//  SettingsTableView.swift
//  Strive
//
//  Created by Tommy Martin on 6/24/21.
//  Copyright © 2021 Strive. All rights reserved.
//

import UIKit

class SettingsTableView: UITableView {
    init() {
        super.init(frame: .zero, style: .grouped)
        backgroundColor = .background
        separatorInset.left = 0
        register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.reuseIdentifier)
        register(SettingsTextFieldCell.self, forCellReuseIdentifier: SettingsTextFieldCell.reuseIdentifier)
        register(SettingsDestructiveActionCell.self, forCellReuseIdentifier: SettingsDestructiveActionCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
