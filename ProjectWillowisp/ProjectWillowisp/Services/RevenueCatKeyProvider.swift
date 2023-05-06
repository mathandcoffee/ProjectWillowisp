//
//  RevenueCatKeyProvider.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 3/31/23.
//

import Foundation

final class RevenueCatKeyProvider {
    private static var keysPlist: NSDictionary {
        if
            let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
            let dictionary = NSDictionary(contentsOfFile: path) {
            return dictionary
        }
        fatalError("You must have a Keys.plist file in your application codebase.")
    }
    
    static var apiKey: String {
        guard let apiKey = keysPlist["revenuecat-key"] as? String else {
            fatalError("Your Keys.plist must have a key of: giphy-key and a corresponding value of type String.")
        }
        return apiKey
    }
}
