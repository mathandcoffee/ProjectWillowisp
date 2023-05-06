//
//  DystoriaTextView.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 12/13/21.
//

import UIKit
import SnapKit

public protocol DystoriaTextViewDelegate: AnyObject {
    func textDidUpdate(_ textView: DystoriaTextView)
}

public class DystoriaTextView: UIView {
    public static let suggestedHeight: CGFloat = 55
    
    public weak var delegate: DystoriaTextViewDelegate?
    private let placeholder: String
    
    private let textView = UITextView()
    private lazy var overlineLabel: UILabel = {
        UILabel(text: placeholder, textColor: .icon.withAlphaComponent(0.5), font: .boldSystemFont(ofSize: 12))
    }()
    
    public init(placeholder: String) {
        self.placeholder = placeholder
        super.init(frame: .zero)
        
        backgroundColor = .surface
        tintColor = .onBackground
        
        textView.backgroundColor = .background
        textView.textColor = .onBackground
        textView.font = .body2
        textView.returnKeyType = .done

        textView.textColor = .icon
        textView.delegate = self
        addSubview(textView)
        textView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
            make.leading.equalToSuperview().offset(CGFloat.padding)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        addSubview(overlineLabel)
        overlineLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.top.equalToSuperview().offset(4)
            make.leading.equalToSuperview().offset(CGFloat.padding + 4)
            make.trailing.equalToSuperview().offset(-CGFloat.padding)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Text Field Simplification
    public override func becomeFirstResponder() -> Bool {
        textView.becomeFirstResponder()
    }
    
    public var text: String? {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
            if newValue != nil && newValue != "" {
                overlineLabel.textColor = .clear
            } else {
                overlineLabel.textColor = .icon.withAlphaComponent(0.5)
            }
        }
    }
    
    public var autocorrectEnabled: Bool {
        get {
            return textView.autocorrectionType != .no
        }
        
        set {
            if newValue {
                textView.autocorrectionType = .default
                textView.autocapitalizationType = .allCharacters
            } else {
                textView.autocorrectionType = .no
                textView.autocapitalizationType = .none
            }
        }
    }
    
    public var textAlignment: NSTextAlignment {
        get {
            return textView.textAlignment
        }
        
        set {
            textView.textAlignment = newValue
            overlineLabel.textAlignment = newValue
        }
    }
    
    public var isPassword: Bool {
        get {
            return textView.isSecureTextEntry
        }
        
        set {
            if (isPassword) {
                textView.textContentType = .password
            }
            textView.isSecureTextEntry = newValue
        }
    }
    
    public var keyboardType: UIKeyboardType {
        get {
            return textView.keyboardType
        }
        
        set {
            textView.keyboardType = newValue
        }
    }
    
    public var font: UIFont? {
        get {
            return textView.font
        }
        
        set {
            textView.font = newValue
            overlineLabel.font = newValue
        }
    }
}

// MARK: UITextFieldDelegate
extension DystoriaTextView: UITextViewDelegate {
    public func textViewDidBeginEditing(_ textView: UITextView) {
        overlineLabel.textColor = .clear
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text?.count ?? 0 == 0 {
            overlineLabel.textColor = .icon.withAlphaComponent(0.5)
            delegate?.textDidUpdate(self)
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 470
    }
}

