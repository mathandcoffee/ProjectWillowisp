//
//  PremiumVC.swift
//  mac-dystoria-ios
//
//  Created by Nick Palastro on 1/17/22.
//

import UIKit
import Resolver
import Combine
import SwiftUI
import RevenueCat
import StoreKit

final class PremiumVC: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var label = UILabel()
    private lazy var imageView = UIImageView()
    private lazy var button = AuthButton(style: .fill, text: "")
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .onBackground
        label.font = .headline4
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    @objc fileprivate func buttonPressed() {
        
        //TODO: RevenueCat doesn't have trivial webhook integration with Supabase. We'll need to make an API to target this status on the server.
        Purchases.shared.getProducts([AuthenticationService.productId]) { products in
            guard let skProduct = products.first else { return }
            
            Purchases.shared.purchase(product: skProduct) { [weak self] transaction, purchaseInfo, error, userCancelled in
                if error != nil {
                    let alert = UIAlertController(title: "Server Error", message: "There was a problem with your request. Please check your connection and try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                    return
                } else if !userCancelled {
                    Purchases.shared.getCustomerInfo { (customerInfo, error) in
                        if customerInfo?.activeSubscriptions.contains(AuthenticationService.productId) == true {
                            UserDefaults.standard.set(true, forKey: AuthenticationService.productId)
                        } else {
                            UserDefaults.standard.set(false, forKey: AuthenticationService.productId)
                        }
                    }
                }
            }
        }
    }
}

private extension PremiumVC {
    func setupUI() {
        view.backgroundColor = .background
        
        let lightAttributes = [NSAttributedString.Key.font: UIFont.headline2, NSAttributedString.Key.foregroundColor: UIColor.onBackground]
        let darkAttributes = [NSAttributedString.Key.font: UIFont.headline2, NSAttributedString.Key.foregroundColor: UIColor.lightPrimary]
        let attributedStringFive = NSMutableAttributedString(string: "Premium ", attributes: darkAttributes)
        let normalStringFive = NSMutableAttributedString(string: "Benefits", attributes: lightAttributes)
        attributedStringFive.append(normalStringFive)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(36)
        }
        label.textAlignment = .center
        label.attributedText = attributedStringFive
        label.adjustsFontSizeToFitWidth = true

        view.addSubview(imageView)
        imageView.image = .carouselFive
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(label.snp.bottom).offset(CGFloat.padding(.large))
            make.height.equalTo(225)
            make.width.equalToSuperview()
        }
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        Purchases.shared.getProducts([AuthenticationService.productId]) { products in
            guard let skProduct = products.first else { return }
            
            let price = skProduct.localizedPriceString
            self.view.addSubview(self.button)
            self.button.addTarget(self, action: #selector(self.buttonPressed), for: .touchUpInside)
            self.button.setTitle("\(skProduct.localizedTitle) - \(price)", for: .normal)
            self.button.snp.makeConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-24)
                make.centerX.equalToSuperview()
                make.height.equalTo(54)
                make.width.equalToSuperview().offset(-2 * CGFloat.padding)
            }
            
            self.view.addSubview(self.descriptionLabel)
            self.descriptionLabel.text = "With Premium, you will have broader profile customization options, access to subscriber only content, gain access to a private Discord for Project Willowisp, and gain more controls for video playback!"
            self.descriptionLabel.snp.makeConstraints { make in
                make.top.equalTo(self.imageView.snp.bottom).offset(CGFloat.padding)
                make.bottom.equalTo(self.button.snp.top).offset(-CGFloat.padding)
                make.left.right.equalToSuperview().inset(2 * CGFloat.padding)
            }
        }
    }
}

