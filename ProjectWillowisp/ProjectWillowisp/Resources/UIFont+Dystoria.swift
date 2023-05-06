//
//  UIFont+Dystoria.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 10/23/21.
//

import UIKit

extension UIFont {
    // MARK: Headline
    static var headline1: UIFont {
        return .boldFont(ofSize: 34)
    }
    
    static var headline2: UIFont {
        return .boldFont(ofSize: 28)
    }
    
    static var headline3: UIFont {
        return .boldFont(ofSize: 20)
    }
    
    static var headline4: UIFont {
        return .boldFont(ofSize: 17)
    }
    
    static var headline5: UIFont {
        return .font(ofSize: 17)
    }
    
    static var headline6: UIFont {
        return .font(ofSize: 15)
    }
    
    // MARK: Subtitle
    static var subtitle1: UIFont {
        return .font(ofSize: 14)
    }
    
    static var subtitle2: UIFont {
        return .boldFont(ofSize: 12)
    }
    
    // MARK: Body
    static var body1: UIFont {
        return .boldFont(ofSize: 16)
    }
    
    static var body2: UIFont {
        return .font(ofSize: 14)
    }
    
    // MARK: Other
    static var button: UIFont {
        return .boldFont(ofSize: 15)
    }
    
    static var overline: UIFont {
        return .boldFont(ofSize: 10)
    }
    
    static var caption: UIFont {
        return .boldFont(ofSize: 10)
    }
    
    private static func boldFont(ofSize: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Bold", size: ofSize)!
    }
    
    private static func font(ofSize: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Regular", size: ofSize)!
    }
}
