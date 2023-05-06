//
//  NotificationSettingsVC.swift
//  mac-dystoria-ios
//
//  Created by Nick Palastro on 1/25/22.
//

import UIKit
import Resolver
import Combine
import SwiftUI

class NotificationsSettingsVC: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(self) deinited correctly")
    }
    
    private func setupView() {
        view.backgroundColor = .background
        
        view.addSubview(headerText)
        headerText.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(CGFloat.padding)
            make.trailing.equalToSuperview().offset(-CGFloat.padding)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(CGFloat.spacing(.normal))
            make.height.equalTo(90)
        }
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.left.equalTo(view.safeAreaLayoutGuide).inset(CGFloat.padding)
            make.height.width.equalTo(40)
        }
        
        view.addSubview(constructionLabel)
        constructionLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    private lazy var headerText: UILabel = {
        let label = UILabel()
        label.text = "NotificationsSettingsVC Placeholder"
        label.numberOfLines = 1
        label.textColor = .onBackground
        label.font = .headline4
        label.textAlignment = .center
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(.back, for: .normal)
        button.backgroundColor = .surface
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        button.tintColor = .onBackground
        return button
    }()
    
    private lazy var constructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Under construction"
        return label
    }()
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
}
