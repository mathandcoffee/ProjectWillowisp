//
//  SettingsViewModel.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 11/9/21.
//

import Foundation
import Resolver
import Combine
import UIKit

class SettingsViewModel {
    
    enum Event {
        case logout
    }
    
    private var subscribers = Set<AnyCancellable>()
    
    private var _eventManager = PassthroughSubject<Event, Never>()
    
    var eventManager: AnyPublisher<Event, Never> {
        return _eventManager.eraseToAnyPublisher()
    }
    
    func logout(presentingVC: UIViewController) {
        Task {
            await AuthenticationService.shared.logout(presentingVC: presentingVC)
        }
    }
    
    func deleteUser(presentingVC: UIViewController) {
        Task {
            let success = await AuthenticationService.shared.deleteUser()
            if success {
                await AuthenticationService.shared.logout(presentingVC: presentingVC)
                DispatchQueue.main.async {
                    self._eventManager.send(.logout)
                }
            }
        }
    }
    
    func getCurrentUser() -> User? {
        return UserProfileService.shared.currentUser
    }
}
