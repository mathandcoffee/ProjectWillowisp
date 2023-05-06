//
//  DisplayNameAcquisitionVC.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 11/23/21.
//

import UIKit
import Resolver
import Combine

class DisplayNameAcquisitionVC: UIViewController {
    
    
    private lazy var fewMoreThingsLabel: UILabel = {
        let label = UILabel()
        label.text = "Just a few more things..."
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.textColor = .onBackground
        label.font = .headline4
        label.textAlignment = .center
        return label
    }()
    
    private lazy var displayNameLabel: UILabel = {
        let label = UILabel()
        label.text = "What should people call you?"
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .onBackground
        label.font = .headline2
        label.textAlignment = .center
        return label
    }()
    
    private lazy var nameTextField: DystoriaTextField = {
        let textField = DystoriaTextField(placeholder: "Display Name")
        textField.layer.cornerRadius = 12
        textField.autocorrectEnabled = false
        textField.delegate = self
        return textField
    }()
    
    private let button = AuthButton(style: .fill, text: "Next")
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let _ = nameTextField.becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        //$Stro$
    }
    
    deinit {
        print("\(self) deinited correctly")
    }
    
    private func setupConstraints() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        view.backgroundColor = .background
        
        view.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(CGFloat.padding)
            make.trailing.equalToSuperview().offset(-CGFloat.padding)
            make.height.equalTo(36)
        }
        
        view.addSubview(button)
        button.addTarget(self, action: #selector(saveDisplayName), for: .touchUpInside)
        button.snp.makeConstraints { make in
            make.height.equalTo(AuthButton.suggestedHeight)
            make.leading.trailing.equalToSuperview().inset(CGFloat.padding)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-98)
        }
        
        view.addSubview(fewMoreThingsLabel)
        fewMoreThingsLabel.snp.makeConstraints { make in
            make.width.top.equalTo(view.safeAreaLayoutGuide).offset(CGFloat.spacing)
            make.centerX.equalToSuperview()
            make.height.equalTo(32)
        }
        
        view.addSubview(displayNameLabel)
        displayNameLabel.snp.makeConstraints { make in
            make.width.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(nameTextField.snp.top).offset(-50)
            make.height.equalTo(100)
        }
    }
    
    @objc private func saveDisplayName() {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        Task {
            let success = await UserProfileService.shared.updateDisplayName(name: name)
            if success {
                navigateTo(.profilePicture)
            } else {
                let alert = UIAlertController(title: "Server Error", message: "There was a problem with your request. Please check your connection and try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension DisplayNameAcquisitionVC: DystoriaTextFieldDelegate {
    func textDidUpdate(_ textField: DystoriaTextField) {
        return
    }
    
    func textFieldShouldReturn(_ textField: DystoriaTextField) {
        if textField.text != "" {
            dismissKeyboard()
            saveDisplayName()
        } else {
            return
        }
    }
    
    
}
