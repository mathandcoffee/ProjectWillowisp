//
//  AuthVC.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 8/8/22.
//

import UIKit
import Combine
import Lottie
import AuthenticationServices

final class AuthVC: BaseViewController {
    
    typealias STATE = AuthState
    
    typealias EVENT = AuthEvent
    
    typealias VIEWMODEL = AuthViewModel
    
    var stateSubscription: AnyCancellable?
    
    var eventSubscription: AnyCancellable?
    
    var viewModel: AuthViewModel = AuthViewModel(initialState: AuthState())
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private lazy var acceptanceLabel: UITextView = {
        let label = UITextView()
        
        let standardStringAttribute = [
            NSAttributedString.Key.foregroundColor: UIColor.icon]
        
        let firstString = NSMutableAttributedString(string: "By logging in or signing up you agree to our ", attributes: standardStringAttribute)
        
        let tosStringAttribute = [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue,
            NSAttributedString.Key.foregroundColor: UIColor.primary,
            NSAttributedString.Key.link: URL(string: "https://app.termly.io/document/terms-of-use-for-ios-app/09ff914e-3a3c-425f-afa8-5c723de466af")!] as [NSAttributedString.Key : Any]
        let tosAttributedString = NSMutableAttributedString(string: "Terms of Service", attributes: tosStringAttribute)
        firstString.append(tosAttributedString)
        
        firstString.append(NSAttributedString(string: " and ", attributes: standardStringAttribute))
        
        let privacyPolicyStringAttribute = [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue,
            NSAttributedString.Key.foregroundColor: UIColor.primary,
            NSAttributedString.Key.link: URL(string: "https://app.termly.io/document/privacy-policy/b2f96da6-a4d0-42d4-ad02-2efec38f93fa")!] as [NSAttributedString.Key : Any]
        let privacyPolicyAttributedString = NSAttributedString(string: "Privacy Policy.", attributes: privacyPolicyStringAttribute)
        firstString.append(privacyPolicyAttributedString)
        
        label.attributedText = firstString
        label.font = .body1
        label.textAlignment = .center
        label.delegate = self
        label.backgroundColor = .background
        
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Continue with Discord", for: .normal)
        button.addTarget(self, action: #selector(loginWithDiscord), for: .touchUpInside)
        button.setImage(.discord, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .discordBlurple
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 12, left: 30, bottom: 12, right: 215)
        button.titleEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        button.layer.cornerRadius = 6
        button.imageView?.frame = CGRectMake(4, 4, 32, 32);
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private lazy var logoImageView: UIImageView = {
        let logoImageView = UIImageView(image: .logoBanner)
        logoImageView.contentMode = .scaleAspectFit
        return logoImageView
    }()
    
    private func setupLogo() {
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.snp.topMargin).offset(72)
            make.height.equalTo(128)
            make.width.equalToSuperview().dividedBy(1.5)
        }
    }
    
    private lazy var animationView: LottieAnimationView = {
        let animationView = LottieAnimationView()
        animationView.contentMode = .scaleAspectFit
        animationView.animation = LottieAnimation.named("willowWave")
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.layer.shadowPath = UIBezierPath(rect: animationView.bounds).cgPath
        animationView.loopMode = .loop
        return animationView
    }()
    
    private lazy var signInWithAppleButton: ASAuthorizationAppleIDButton = {
        let authorizationButton = ASAuthorizationAppleIDButton(authorizationButtonType: .continue, authorizationButtonStyle: .black)
        authorizationButton.addTarget(self, action: #selector(loginWithApple), for: .touchUpInside)
        return authorizationButton
    }()
    
    private func setupAnimation() {
//        view.addSubview(animationView)
//        animationView.snp.makeConstraints { make in
//            make.width.equalToSuperview().multipliedBy(0.75)
//            make.height.equalTo(animationView.snp.width)
//            make.centerX.equalToSuperview().offset(-8)
//            make.bottom.equalTo(signInWithAppleButton.snp.top).offset(-CGFloat.padding)
//        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupView()
        setupLogo()
        setupAnimation()
        setupViewModelObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Implemented")
    }
    
    func renderState(state: AuthState) {
        
    }
    
    func handleEvent(event: AuthEvent) {
        switch event {
        case .signInSuccessful:
            Task {
                if let user = await UserProfileService.shared.getCurrentUserProfile() {
                    if user.username == nil {
                        navigateTo(.displayName)
                    } else if user.avatar_url == nil {
                        navigateTo(.profilePicture)
                    } else if user.cover_image_url == nil {
                        navigateTo(.coverPhoto)
                    } else if user.bio == nil {
                        navigateTo(.bio)
                    } else {
                        navigateTo(.dashboard)
                    }
                } else {
                    //TODO: Print alert for user failure here
                }
            }
        default:
            return
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationView.play()
    }
    
    private func setupView() {
        view.backgroundColor = .background
        
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(2 * CGFloat.padding + 48)
            make.height.equalTo(48)
        }
        
        view.addSubview(signInWithAppleButton)
        signInWithAppleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
            make.bottom.equalTo(button.snp.top).offset(-CGFloat.padding)
            make.height.equalTo(48)
        }
        
        view.addSubview(acceptanceLabel)
        acceptanceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(CGFloat.padding)
            make.trailing.equalToSuperview().offset(-CGFloat.padding)
            make.top.equalTo(button.snp.bottom).offset(CGFloat.padding)
            make.height.equalTo(48)
        }
    }
    
    @objc private func loginWithApple() {
        Task {
            await viewModel.signInWithApple(with: self)
        }
    }
    
    @objc private func loginWithDiscord() {
        Task {
            await viewModel.signInWithDiscord(with: self)
        }
    }
}

extension AuthVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
