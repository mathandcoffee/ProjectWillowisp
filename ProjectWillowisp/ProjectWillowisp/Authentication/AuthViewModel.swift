//
//  AuthViewModel.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 8/8/22.
//

import UIKit
import Combine

final class AuthViewModel: BaseViewModel<AuthState, AuthEvent> {
    
    private var isLoading = false
    
    private var authSubscription: AnyCancellable?
    
    override init(initialState: AuthState) {
        super.init(initialState: initialState)
        
        authSubscription = AuthenticationService.shared.authPublisher.sink(receiveValue: {
            if $0 && !self.isLoading {
                self.isLoading = true
                self._eventHandler.send(.signInSuccessful)
            } else {
                self._eventHandler.send(.signInFailed)
            }
        })
    }
    
    func signInWithDiscord(with presentingVC: UIViewController) async {
        AuthenticationService.shared.loginWithDiscord(with: presentingVC)
    }
    
    func signInWithApple(with presentingVC: UIViewController) async {
        AuthenticationService.shared.loginWithApple(with: presentingVC)
    }
}
