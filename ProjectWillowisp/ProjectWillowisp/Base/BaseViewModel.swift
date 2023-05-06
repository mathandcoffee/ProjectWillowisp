//
//  BaseViewModel.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 8/6/22.
//

import Foundation
import Combine

class BaseViewModel<STATE: State, EVENT: Event> {
    
    init(initialState: STATE){
        _currentState = CurrentValueSubject<STATE, Never>(initialState)
    }
    
    let _currentState: CurrentValueSubject<STATE, Never>
    let _eventHandler: PassthroughSubject<EVENT, Never> = PassthroughSubject<EVENT, Never>()
    
    var state: AnyPublisher<STATE, Never> {
        return _currentState.eraseToAnyPublisher()
    }
    
    var currentState: STATE {
        return _currentState.value
    }
    
    var eventPublisher: AnyPublisher<EVENT, Never> {
        return _eventHandler.eraseToAnyPublisher()
    }
    
    final func setState(_ update: STATE) {
        _currentState.send(update)
    }
    
    final func sendEvent(_ event: EVENT) {
        _eventHandler.send(event)
    }
}
