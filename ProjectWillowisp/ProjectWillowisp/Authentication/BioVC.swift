//
//  BioVC.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 12/27/21.
//

import UIKit
import Resolver
import Combine
import SwiftUI
import AppTrackingTransparency

class BioVC: UIViewController {
    
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
    
    //This function one shows an alert the first time per device.
    //Switching accounts or creating a new account does not reset the status.
    func finishSignUp() {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                print("App Tracking authorized")
            default:
                //Consider not showing this alert
                let alert = UIAlertController(title: "Tracking Authorization Error", message: "There was a problem with your request. Please check your connection and try again.", preferredStyle: .alert)
                self.present(alert, animated: true)
            }
        }
        navigateTo(.dashboard)
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
        
        view.addSubview(subheaderText)
        subheaderText.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(headerText.snp.bottom).offset(CGFloat.spacing(.small))
            make.height.equalTo(90)
        }
        
        view.addSubview(bioTextView)
        bioTextView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(CGFloat.padding)
            make.trailing.equalToSuperview().offset(-CGFloat.padding)
            make.top.equalTo(subheaderText.snp.bottom).offset(CGFloat.spacing(.large))
            make.height.equalTo(90)
        }
        
        view.addSubview(skipButton)
        skipButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(CGFloat.padding)
            make.trailing.equalToSuperview().offset(-CGFloat.padding)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-28)
            make.height.equalTo(AuthButton.suggestedHeight)
        }
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(CGFloat.padding)
            make.trailing.equalToSuperview().offset(-CGFloat.padding)
            make.bottom.equalTo(skipButton.snp.top).offset(-28)
            make.height.equalTo(AuthButton.suggestedHeight)
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    private lazy var headerText: UILabel = {
        let label = UILabel()
        label.text = "Just one more thing..."
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .onBackground
        label.font = .headline4
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subheaderText: UILabel = {
        let label = UILabel()
        label.text = "Tell people a bit about yourself"
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .onBackground
        label.font = .headline3
        label.textAlignment = .center
        return label
    }()
    
    private lazy var bioTextView: DystoriaTextView = {
        let textView = DystoriaTextView(placeholder: "Bio...")
        textView.backgroundColor = .background
        textView.layer.cornerRadius = 12
        return textView
    }()
    
    private lazy var nextButton: UIButton = {
        let button = AuthButton(style: .fill, text: "Next")
        button.addTarget(self, action: #selector(submit), for: .touchUpInside)
        return button
    }()
    
    @objc private func submit() {
        Task {
            guard let bio = bioTextView.text, !bio.isEmpty else { return }
            let success = await UserProfileService.shared.updateBio(bio: bio)
            if success {
                finishSignUp()
            } else {
                let alert = UIAlertController(title: "Server Error", message: "There was a problem with your request. Please check your connection and try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    private lazy var skipButton: UIButton = {
        let button = AuthButton(style: .border, text: "Skip")
        button.addTarget(self, action: #selector(skip), for: .touchUpInside)
        return button
    }()
    
    @objc private func skip() {
        finishSignUp()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
