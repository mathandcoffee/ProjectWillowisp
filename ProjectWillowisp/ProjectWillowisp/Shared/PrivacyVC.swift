//
//  PrivacyVC.swift
//  mac-dystoria-ios
//
//  Created by Nick Palastro on 1/24/22.
//

import UIKit
import Resolver
import Combine
import SwiftUI
import WebKit
import SnapKit

final class PrivacyVC: UIViewController {
    private let tableView = PrivacyTableView()
    
    private let rows: [PrivacyRow]
    
    weak var containingVC: UIViewController?
    
    enum PrivacyRow {
        case privacyPolicy, termsOfService
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
            make.left.equalTo(self.view.safeAreaLayoutGuide).inset(CGFloat.padding)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        let label = UILabel()
        label.backgroundColor = .surface
        label.font = .headline3
        label.textColor = .onBackground
        label.textAlignment = .center
        label.text = "Privacy"
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalTo(backButton.snp.centerY)
            make.centerX.equalToSuperview()
        }
        
        return view
    }()
    
    init() {
        rows = [ .privacyPolicy, .termsOfService ]
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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .icon
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .background
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(CGFloat.padding)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: UITableViewDataSource
extension PrivacyVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
        switch row {
        case .privacyPolicy:
            return setUpCell(title: "Privacy Policy")
        case .termsOfService:
            return setUpCell(title: "Terms of Service")
        }
    }
    
    private func setUpCell(title: String) -> PrivacyCell {
        let cell = PrivacyCell()
        cell.configure(title: title)
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension PrivacyVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PrivacyCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch rows[indexPath.row] {
        case .privacyPolicy:
            navigateToWeb(header: "Privacy Policy", url: "https://app.termly.io/document/privacy-policy/b2f96da6-a4d0-42d4-ad02-2efec38f93fa" )
        case .termsOfService:
            navigateToWeb(header: "Terms of Service", url: "https://app.termly.io/document/terms-of-use-for-ios-app/09ff914e-3a3c-425f-afa8-5c723de466af")
        }
    }
}

