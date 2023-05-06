//
//  SettingsVC.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 11/9/21.
//

import UIKit
import Resolver
import Combine

class AccountSettingsVC: UIViewController {
    private let viewModel = SettingsViewModel()
    private let tableView = SettingsTableView()
    
    private let rows: [[SettingsRow]]
    private var subscriptions = Set<AnyCancellable>()
    
    weak var containingVC: UIViewController?
    
    enum SettingsRow {
        case username, email, password, logout, deleteAccount
        
        var displayName: String {
            switch self {
            case .username: return "Username"
            case .email: return "Email"
            case .password: return "Password"
            case .deleteAccount: return "Delete Account"
            case .logout: return "Log Out"
            }
        }
        
        func value(me: User) async -> String? {
            switch self {
            case .username: return me.username
            case .email: return await AuthenticationService.shared.currentUserEmail()
            case .password: return "*********"
            case .deleteAccount: return ""
            case .logout: return nil
            }
        }
    }
    
    private lazy var navigationView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .background
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.width.leading.trailing.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(56)
        }
        
        let backButton = UIButton()
        backButton.setImage(.back, for: .normal)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        backButton.imageView?.tintColor = .onPrimary
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(48)
        }
        
        let label = UILabel()
        label.font = .body1
        label.textColor = .onPrimary
        label.textAlignment = .center
        label.text = "Account Settings"
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.height.equalTo(backButton)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().dividedBy(1.5)        }
        
        return view
    }()
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
    
    init() {
        rows = [[.email, .password], [.logout], [.deleteAccount]]
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .background
        setupView()
        
        subscriptions.insert(
            viewModel.eventManager
                .sink(receiveValue: { [weak self] event in
                    switch event {
                    case .logout:
                        DispatchQueue.main.async {
                            self?.dismiss(animated: true)
                        }
                    }
                }
            )
        )
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
        tableView.separatorColor = .icon
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .background
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: UITableViewDataSource
extension AccountSettingsVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = rows[indexPath.section]
        let row = section[indexPath.row]
        if row == .logout {
            return actionCell(title: "Log Out", indexPath: indexPath)
        }
        else if row == .deleteAccount {
            return actionCell(title: "Delete Account", indexPath: indexPath)
        }
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsCell.reuseIdentifier,
            for: indexPath) as? SettingsCell
            else {
                fatalError("Invalid Cell Type - Make sure SettingsCell is registered")
        }
        
        let showDisclosure = indexPath.section == 0

        guard let me = viewModel.getCurrentUser() else { fatalError() }
        Task {
            cell.configure(title: row.displayName, value: await row.value(me: me), showDisclosure: showDisclosure)
        }
        return cell
    }
    
    private func actionCell(title: String, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsDestructiveActionCell.reuseIdentifier,
            for: indexPath) as? SettingsDestructiveActionCell
            else {
                fatalError("Invalid Cell Type - Make sure SettingsDestructiveActionCell is registered")
        }
        
        cell.configure(title: title)
        return cell
    }
}

// MARK: UITableViewDelegate
extension AccountSettingsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SettingsCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch rows[indexPath.section][indexPath.row] {
        case .username:
            return
        case .email:
            let alertController = UIAlertController(title: "Change Email Address", message: "", preferredStyle: .alert)
            
            let saveEmail = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
                let newEmail = alertController.textFields![0]
                guard var _ = UserProfileService.shared.currentUser else { fatalError() }
                if newEmail.text?.count ?? 0 == 0 { return }
                if newEmail.text?.count ?? 51 > 50 { return }
                Task {
                    let success = await AuthenticationService.shared.updateEmail(email: newEmail.text!)
                    if !success {
                        let alert = UIAlertController(title: "Server Error", message: "There was a problem with your request. Please check your connection and try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter New Email Address"
                textField.keyboardType = .emailAddress
            }
            alertController.addAction(saveEmail)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            //Update view to show new email
            return
            
        case .password:
            let alertController = UIAlertController(title: "Change Password", message: "", preferredStyle: .alert)
            
            let changePassword = UIAlertAction(title: "Change", style: .default, handler: { alert -> Void in
                let currentPassword = alertController.textFields![0].text
                let newPassword = alertController.textFields![1].text
                let confirmPassword = alertController.textFields![2].text
                if newPassword != confirmPassword {
                    let alert = UIAlertController(title: "Different Passwords", message: "The two passwords do not match; please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    return
                }
                
                if newPassword == nil || newPassword!.isEmpty {
                    return
                }
                
                Task {
                    let success = await AuthenticationService.shared.updatePassword(password: newPassword!)
                    if !success {
                        let alert = UIAlertController(title: "Server Error", message: "There was a problem with your request. Please check your connection and try again.", preferredStyle: .alert)
                        self.present(alert, animated: true)
                    }
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter Current Password"
                textField.isSecureTextEntry = true
            }
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter New Password"
                textField.isSecureTextEntry = true
            }
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Confirm New Password"
                textField.isSecureTextEntry = true
            }
            alertController.addAction(changePassword)
            alertController.addAction(cancelAction)
                
            self.present(alertController, animated: true, completion: nil)
            return
            
        case .deleteAccount:
            let alertController = UIAlertController(title: "Delete Account?", message: "You cannot undo this action!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] action in
                guard let self = self else { return }
                self.viewModel.deleteUser(presentingVC: self)
            })
            alertController.addAction(action)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        case .logout:
            self.viewModel.logout(presentingVC: self)
        }
    }
}
