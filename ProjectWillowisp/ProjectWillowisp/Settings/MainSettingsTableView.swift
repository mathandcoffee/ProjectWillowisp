//
//  MainSettingsTableView.swift
//  mac-dystoria-ios
//
//  Created by Nick Palastro on 1/21/22.
//

import UIKit

class MainSettingsTableView: UITableView {
    init() {
        super.init(frame: .zero, style: .plain)
        backgroundColor = .background
        separatorInset.left = 0
        register(MainSettingsCell.self, forCellReuseIdentifier: MainSettingsCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
