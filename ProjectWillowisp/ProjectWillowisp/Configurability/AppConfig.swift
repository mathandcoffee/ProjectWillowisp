//
//  AppConfig.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/1/23.
//

import Foundation

final class AppConfig: JSONCodable {
    
    let primary_color_hex_string: String?
    let secondary_color_hex_string: String?
    let revenue_cat_id: String?
    let one_signal_app_id: String?
}
