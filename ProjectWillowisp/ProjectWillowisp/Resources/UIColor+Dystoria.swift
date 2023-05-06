//
//  Colors+Dystoria.swift
//  mac-dysto-ios
//
//  Created by Bryan Malumphy on 10/22/21.
//

import SwiftUI

extension UIColor {
    enum Variant {
        case normal, dark
    }
    
    static func background(_ variant: Variant) -> UIColor {
        switch variant {
        case .normal:
            return UIColor(red: 250, green: 250, blue: 250)
        case .dark:
            return UIColor(red: 0xFF, green: 0xE0, blue: 0xFF)
        }
    }
    
    static let lightPrimary: UIColor = UIColor(red: 0xE0, green: 0xB7, blue: 0x00)
    
    static let darkPrimary: UIColor = UIColor(red: 0xE0, green: 0xB7, blue: 0x00)
    
    static let primary: UIColor = UIColor(red: 0xE0, green: 0xB7, blue: 0x00)
    
    static let onPrimary: UIColor = UIColor(red: 0x0F, green: 0x0F, blue: 0x0F)
    
    static let surface: UIColor = UIColor(red: 0xF4, green: 0xEB, blue: 0xEB)
    
    static let highlight: UIColor = UIColor(red: 0xF0, green: 0xF0, blue: 0xF0)
    
    static let background: UIColor = UIColor(red: 0xFE, green: 0xFE, blue: 0xFE)
    
    static let lightBackground: UIColor = UIColor(red: 0xFF, green: 0xFF, blue: 0xFF)
    
    static let midBackground: UIColor = UIColor(red: 0xFF, green: 0xFF, blue: 0xFF)
    
    static let onBackground: UIColor = UIColor(red: 0x10, green: 0x10, blue: 0x12)
    
    static let icon: UIColor = UIColor(red: 0x1F, green: 0x1F, blue: 0x1F)
    
    static let discordBlurple: UIColor = UIColor(red: 0x58, green: 0x65, blue: 0xF2)
    
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red)/0xFF,
            green: CGFloat(green)/0xFF,
            blue: CGFloat(blue)/0xFF,
            alpha: alpha)
    }
}
