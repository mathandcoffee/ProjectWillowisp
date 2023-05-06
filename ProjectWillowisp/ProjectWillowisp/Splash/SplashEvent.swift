//
//  SplashEvent.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 8/6/22.
//

import Foundation

enum SplashEvent: Event {
    case finishedPreloading(createdAt: Date = Date())
    case logInSuccess(createdAt: Date = Date())
    case logInFailed(createdAt: Date = Date())
}
