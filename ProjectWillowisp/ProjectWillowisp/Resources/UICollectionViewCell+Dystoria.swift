//
//  UICollectionViewCell+Dystoria.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 12/16/21.
//

import UIKit

extension UICollectionViewCell {
    static func cellIdentifierForType<T: UICollectionViewCell>(type: T.Type) -> String {
        return String(describing: type)
    }
}
