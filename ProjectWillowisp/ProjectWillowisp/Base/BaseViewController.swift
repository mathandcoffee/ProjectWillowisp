//
//  BaseViewController.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 8/6/22.
//

import UIKit
import Combine

typealias BaseViewController = UIViewController & StateViewController

protocol StateViewController: UIViewController {
    
    associatedtype STATE: State
    
    associatedtype EVENT: Event
    
    associatedtype VIEWMODEL: BaseViewModel<STATE, EVENT>
    
    var stateSubscription: AnyCancellable? { get set }
    var eventSubscription: AnyCancellable? { get set }
    
    var viewModel: VIEWMODEL { get }
    
    func renderState(state: STATE)
    
    func handleEvent(event: EVENT)
}

extension StateViewController {
    
    func setupViewModelObservers() {
        stateSubscription = viewModel.state.receive(on: DispatchQueue.main).sink(
            receiveValue: { [unowned self] state in
                self.renderState(state: state)
            })
        eventSubscription = viewModel.eventPublisher.receive(on: DispatchQueue.main).sink(
            receiveValue: { [unowned self] event in
                self.handleEvent(event: event)
            })
    }
}
