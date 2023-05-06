//
//  PostTextField.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 11/8/21.
//

import UIKit
import SnapKit
import SwiftUI

public protocol DystoriaTextFieldDelegate: AnyObject {
    func textDidUpdate(_ textField: DystoriaTextField)
    
    func textFieldShouldReturn(_ textField: DystoriaTextField)
}

public class DystoriaTextField: UIView {
    public static let suggestedHeight: CGFloat = 55
    private static let characterLimit: Int = 470
    
    private func textIsWithinLimit(existingText: String?, newText: String) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= DystoriaTextField.characterLimit
        return isAtLimit
    }
    
    public weak var delegate: DystoriaTextFieldDelegate?
    var placeholder: String? {
        get {
            return overlineLabel.text
        }
        set {
            overlineLabel.text = newValue
        }
    }
    
    private let textField = UITextField()
    private lazy var overlineLabel: UILabel = {
        let label = UILabel()
        label.textColor = .icon.withAlphaComponent(0.5)
        label.font = .boldSystemFont(ofSize: 12)
        return label
    }()
    
    public init(placeholder: String) {
        super.init(frame: .zero)
        self.placeholder = placeholder

        backgroundColor = .highlight
        tintColor = .onBackground
        
        addSubview(overlineLabel)
        overlineLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(CGFloat.padding)
            make.trailing.equalToSuperview().offset(-CGFloat.padding)
        }

        textField.clearButtonMode = .whileEditing
        textField.textColor = .icon
        textField.delegate = self
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(24)
            make.leading.equalToSuperview().offset(CGFloat.padding)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        // Setup for delegate
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Text Field Simplification
    public override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }
    
    public override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }
    
    public var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    public var autocorrectEnabled: Bool {
        get {
            return textField.autocorrectionType != .no
        }
        
        set {
            if newValue {
                textField.autocorrectionType = .default
                textField.autocapitalizationType = .allCharacters
            } else {
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .none
            }
        }
    }
    
    public var isPassword: Bool {
        get {
            return textField.isSecureTextEntry
        }
        
        set {
            if (isPassword) {
                textField.textContentType = .password
            }
            textField.isSecureTextEntry = newValue
        }
    }
    
    public var keyboardType: UIKeyboardType {
        get {
            return textField.keyboardType
        }
        
        set {
            textField.keyboardType = newValue
        }
    }
}

// MARK: UITextFieldDelegate
extension DystoriaTextField: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        overlineLabel.textColor = .clear
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count ?? 0 == 0 {
            overlineLabel.textColor = .icon.withAlphaComponent(0.5)
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.textFieldShouldReturn(self)
        return true
    }
    
    @objc private func textFieldDidChange() {
        delegate?.textDidUpdate(self)
    }
    
    public func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return self.textIsWithinLimit(existingText: textField.text, newText: string)
    }
}
