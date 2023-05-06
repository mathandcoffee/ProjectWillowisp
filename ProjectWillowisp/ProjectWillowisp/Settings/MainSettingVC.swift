//
//  MainSettingVC.swift
//  mac-dystoria-ios
//
//  Created by Nick Palastro on 1/20/22.
//

import UIKit
import Combine
import SwiftUI

class MainSettingsVC: UIViewController {
    private let tableView = MainSettingsTableView()
    
    private let rows: [MainSettingsRow]
    
    weak var containingVC: UIViewController?
    
    enum MainSettingsRow {
        case account, privacy, security, notifications, accessibility, resources
    }
    
    private lazy var navigationView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .background
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.width.left.right.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(CGFloat.padding + 50)
        }
        
        let label = UILabel()
        label.backgroundColor = .surface
        label.font = .headline3
        label.textColor = .onPrimary
        label.textAlignment = .left
        label.text = "Settings"
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalTo(view.snp.centerY)
            make.centerX.equalTo(view.snp.centerX).offset(CGFloat.padding)
        }
        
        return view
    }()
    
    init() {
        rows = [.account, .notifications]
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .background
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(self) deinited correctly")
    }
    
    private func setupView() {
        view.addSubview(navigationView)
        navigationView.snp.makeConstraints { make in
            make.top.width.centerX.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(56)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .background
        tableView.separatorStyle = .none
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
extension MainSettingsVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
        switch row {
        case .account:
            return setUpCell(title: "Account", image: "account")
        case .notifications:
            return setUpCell(title: "Notifications", image: "notifications")
        default:
            return setUpCell(title: "UNKNOWN", image: "notifications")
        }
    }
    
    private func setUpCell(title: String, image: String) -> MainSettingsCell {
        let cell = MainSettingsCell()
        cell.configure(title: title, image: image)
        return cell
    }
}

// MARK: UITableViewDelegate
extension MainSettingsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return MainSettingsCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch rows[indexPath.row] {
        case .account:
            navigationController?.pushViewController(AccountSettingsVC(), animated: true)
        case .notifications:
            navigationController?.pushViewController(NotificationsSettingsVC(), animated: true)
        default:
            return
        }
    }
}

