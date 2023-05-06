//
//  CGSize+Dystoria.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 12/14/21.
//

import UIKit

// MARK: - UIEdgeInsets + Hashable

extension UIEdgeInsets: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(left)
    hasher.combine(right)
    hasher.combine(top)
    hasher.combine(bottom)
  }
}

// MARK: - CGSize + Hashable

extension CGSize: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(height)
    hasher.combine(width)
  }
}
