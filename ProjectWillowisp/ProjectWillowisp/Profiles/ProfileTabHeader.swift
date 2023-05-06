//
//  ProfileTabHeader.swift
//  Strive
//
//  Created by Bryan Malumphy on 5/4/21.
//  Copyright © 2021 Dystoria. All rights reserved.
//

import UIKit

class ProfileTabHeader: UICollectionReusableView {
    static let reuseIdentifier = "profile_tab_header"
    static let preferredHeight: CGFloat = 40
    
    private var tabView = ProfileTabView(titles: ["Favorite Content"])

    func configure() {
        setupIfNeeded(selectAction: { index in
            if index == 0 {
                
            } else {
                
            }
        })
    }
    
    func setupIfNeeded(selectAction: @escaping (Int) -> Void) {
        guard tabView.superview == nil else {
            return
        }
        
        tabView.selectAction = selectAction
        addSubview(tabView)
        tabView.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
    }
}
