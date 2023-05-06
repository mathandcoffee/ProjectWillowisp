//
//  JSONCodable.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 11/7/21.
//

import Foundation

protocol JSONCodable: Codable  {}

extension JSONCodable {
    func encode() -> Data {
        try! JSONEncoder().encode(self)
    }
    
    static func decode<T: Codable>(_ type: T.Type, encodedString: String) -> T? {
        guard let data = encodedString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(type, from: data)
    }
}
