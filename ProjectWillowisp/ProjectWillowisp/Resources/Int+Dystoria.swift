//
//  Int+Dystoria.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 12/17/21.
//

import Foundation

extension Int {
    func toPostViewableString() -> String {
        if self < 1000 {
            return "\(self)"
        } else if self < 10000 {
            let mod1000 = self % 1000
            let mod100 = self % 100
            if mod1000 < 100 {
                return "\((self - mod1000) / 1000)k"
            } else {
                return "\(Double(self - mod100) / 1000)k"
            }
        } else if self < 100000 {
            return "10k"
        } else if self < 1000000 {
            return "\(self / 1000)k"
        } else {
            return "\(self / 1000000)M"
        }
    }
}
