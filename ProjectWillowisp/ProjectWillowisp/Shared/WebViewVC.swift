//
//  PolicyWebView.swift
//  mac-dystoria-ios
//
//  Created by Nick Palastro on 1/24/22.
//

import UIKit
import Resolver
import Combine
import SwiftUI
import WebKit

final class WebViewVC: UIViewController, WKUIDelegate {
    
    private let displayUrl: String
    private let headerText: String
    
    init(header: String, url: String) {
        headerText = header
        displayUrl = url
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(self) deinited correctly")
    }
    
    private func setupView() {
        view.backgroundColor = .background
        view.addSubview(navigationView)
        navigationView.snp.makeConstraints { make in
            make.top.width.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(privacyView)
        privacyView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(navigationView.snp.bottom)
        }
        
    }
    
    private lazy var navigationView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .background
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.width.left.right.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(CGFloat.padding + 50)
        }
        
        let backButton = UIButton()
        backButton.setImage(.back, for: .normal)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        backButton.imageView?.tintColor = .onBackground
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.left.equalTo(self.view.safeAreaLayoutGuide).inset(CGFloat.padding)
            make.width.height.equalTo(40)
        }
        
        let label = UILabel()
        label.backgroundColor = .surface
        label.font = .headline3
        label.textColor = .onBackground
        label.textAlignment = .left
        label.text = headerText
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalTo(backButton.snp.centerY)
            make.left.equalTo(backButton.snp.right).offset(CGFloat.padding)
            make.right.equalToSuperview()
        }
        
        return view
    }()

    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
    
    private lazy var privacyView: WKWebView = {
        var webView = WKWebView()
        let webConfiguration = WKWebViewConfiguration()
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        
        let myURL = URL(string: displayUrl)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
        return webView
    }()
}

