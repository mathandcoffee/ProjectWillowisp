//
//  SplashVC.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 8/6/22.
//

import UIKit
import Combine

final class SplashVC: BaseViewController {
    typealias STATE = SplashState
    typealias EVENT = SplashEvent
    typealias VIEWMODEL = SplashViewModel
    
    let viewModel = SplashViewModel()
    
    var stateSubscription: AnyCancellable?
    var eventSubscription: AnyCancellable?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupViewModelObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            Task {
                await self.viewModel.handleAutoLogin(with: self)
            }
        }
    }
    
    func renderState(state: SplashState) {
        //setup loading indicator state based on state handed
    }
    
    func handleEvent(event: SplashEvent) {
        switch event {
        case .finishedPreloading:
            if let user = UserProfileService.shared.currentUser {
                if user.username == nil {
                    navigateTo(.displayName, true)
                } else if user.avatar_url == nil {
                    navigateTo(.profilePicture, true)
                } else if user.cover_image_url == nil {
                    navigateTo(.coverPhoto,
                    true)
                } else if user.bio == nil {
                    navigateTo(.bio,true)
                } else {
                    navigateTo(.dashboard, true)
                }
            } else {
                navigateTo(.signUp, true)
            }
        case .logInFailed:
            navigateTo(.signUp, true)
        case .logInSuccess:
            viewModel.preloadContent()
        }
    }
    
    func setupView() {
        view.backgroundColor = .background
        let imageView = UIImageView(image: .logoBanner)
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .onBackground
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(66)
            make.width.equalToSuperview().dividedBy(2)
        }
    }
}
