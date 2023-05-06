//
//  PrivacyTableView.swift
//  mac-dystoria-ios
//
//  Created by Nick Palastro on 1/24/22.
//

import UIKit

final class PrivacyTableView: UITableView {
    init() {
        super.init(frame: .zero, style: .grouped)
        backgroundColor = .background
        separatorInset.left = 0
        register(PrivacyCell.self, forCellReuseIdentifier: PrivacyCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
