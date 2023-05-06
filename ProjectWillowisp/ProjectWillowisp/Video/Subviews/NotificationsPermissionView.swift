//
//  NotificationsPermissionView.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/22/23.
//

import UIKit
import OneSignal
import UserNotifications

class NotificationPermissionView: UIView {
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enable Push Notifications", for: .normal)
        button.tintColor = .onBackground
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.font = .headline4
        button.backgroundColor = .background
        button.layer.borderColor = UIColor.darkPrimary.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(handleButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func dismissView() {
        removeFromSuperview()
    }
    
    private func setupView() {
        backgroundColor = .background
        layer.cornerRadius = 16
        let view = UIView()
        view.backgroundColor = .surface
        view.layer.cornerRadius = 16
        addSubview(view)
        view.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview().inset(CGFloat.padding(.large))
        }
        
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.bottom.width.leading.trailing.equalToSuperview().inset(CGFloat.padding(.large))
            make.height.equalTo(58)
        }
    
        let requestLabel = UILabel()
        requestLabel.text = "Get alerts with Evelyn's Reverie when they post content!"
        requestLabel.font = .headline2
        requestLabel.textColor = .onBackground
        requestLabel.adjustsFontSizeToFitWidth = true
        requestLabel.textAlignment = .center
        requestLabel.numberOfLines = 0
        view.addSubview(requestLabel)
        requestLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(CGFloat.padding(.large))
            make.bottom.equalTo(button.snp.top).offset(-CGFloat.padding)
        }
        
    }
    
    @objc private func handleButtonTapped() {
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            DispatchQueue.main.async {
                self.dismissView()
            }
        })
    }
}
