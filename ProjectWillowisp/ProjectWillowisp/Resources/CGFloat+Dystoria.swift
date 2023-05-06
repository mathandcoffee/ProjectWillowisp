//
//  CGFloat+Dystoria.swift
//  mac-dysto-ios
//
//  Created by Bryan Malumphy on 10/22/21.
//

import SwiftUI

extension CGFloat {
    enum Variant {
        case small, normal, large
    }
    
    static func padding(_ variant: Variant) -> CGFloat {
        switch variant {
        case .small: return 8
        case .normal: return 16
        case .large: return 24
        }
    }
    
    static var padding: CGFloat {
        return padding(.normal)
    }
    
    static func spacing(_ variant: Variant) -> CGFloat {
        switch variant {
        case .small: return 8
        case .normal: return 16
        case .large: return 32
        }
    }
    
    static var spacing: CGFloat {
        return spacing(.large)
    }
    
    static var barSectionHeight: CGFloat {
        return 56
    }
    
    static var iconSize: CGFloat {
        return 24
    }
}
