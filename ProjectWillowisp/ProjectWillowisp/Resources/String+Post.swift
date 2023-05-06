//
//  String+Post.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 11/21/21.
//

import UIKit

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        if count == 0 { return "a".height(withConstrainedWidth: width, font: font) }
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil)
        
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil)
        return ceil(boundingBox.width)
    }
    
    func isGifMediaUrl() -> Bool {
        return self.contains("https://giphy.com")
    }
    
    func formattedDateString() -> String? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        guard let date = formatter.date(from: self) else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        let month = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: date)

        return "\(month) \(year)"
    }
    
    func date() -> Date? {
        return ISO8601DateFormatter().date(from: self)
    }
}

