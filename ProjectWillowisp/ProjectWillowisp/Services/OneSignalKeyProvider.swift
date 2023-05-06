//
//  OneSignalKeyProvider.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/21/23.
//

import Foundation

final class OneSignalKeyProvider {
    private static var keysPlist: NSDictionary {
        if
            let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
            let dictionary = NSDictionary(contentsOfFile: path) {
            return dictionary
        }
        fatalError("You must have a Keys.plist file in your application codebase.")
    }
    
    static var appId: String {
        guard let apiKey = keysPlist["one-signal-app-id"] as? String else {
            fatalError("Your Keys.plist must have a key of: giphy-key and a corresponding value of type String.")
        }
        return apiKey
    }
}
