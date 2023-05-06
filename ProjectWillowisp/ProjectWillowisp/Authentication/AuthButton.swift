//
//  AuthButton.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 10/23/21.
//

import UIKit

public class AuthButton: UIButton {
    public static let suggestedHeight: CGFloat = 56
    private let style: Style
    
    public enum Style {
        case normal, fill, border
    }
    
    public init(style: Style, text: String) {
        self.style = style
        super.init(frame: .zero)
        
        // Generic Setup
        layer.cornerRadius = 12
        layer.masksToBounds = true
        titleLabel?.font = .button
        setTitle(text, for: .normal)
        configureForEnabled()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        //$Stro$
    }
    
    public override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        
        set {
            super.isEnabled = newValue
            if newValue {
                configureForEnabled()
            } else {
                configureForDisabled()
            }
        }
    }
    
    private func configureForEnabled() {
        switch style {
        case .normal:
            setTitleColor(.onBackground, for: .normal)
        case .border:
            layer.borderWidth = 4
            layer.borderColor = UIColor.primary.cgColor
            setTitleColor(.onBackground, for: .normal)
        case .fill:
            backgroundColor = .primary
            setTitleColor(.onPrimary, for: .normal)
        }
    }
    
    private func configureForDisabled() {
        let disabledGray = UIColor(red: 222 / 255, green: 222 / 255, blue: 231 / 255, alpha: 1.0)
        let onDisabledGray = UIColor(red: 72 / 255, green: 72 / 255, blue: 79 / 255, alpha: 1.0)
        
        switch style {
        case .normal:
            setTitleColor(disabledGray, for: .normal)
        case .border:
            layer.borderWidth  = 2
            layer.borderColor = disabledGray.cgColor
        case .fill:
            backgroundColor = disabledGray
            setTitleColor(onDisabledGray, for: .normal)
        }
    }
}
