//
//  SettingsTextAttributeVC.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 11/10/21.
//

import UIKit

class SettingsTextAttributeVC: UIViewController {
    private let initialValue: String?
    private let placeholder: String?
    
    private let tableView = SettingsTableView()
    private var textField: UITextField {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SettingsTextFieldCell else {
            fatalError("This text field will not be available until the table view loads")
        }
        
        return cell.textField
    }
    
    private lazy var saveButton: UIBarButtonItem = {
        let saveAction = #selector(saveButtonPressed)
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: saveAction)
        saveButton.setTitleTextAttributes([.foregroundColor: UIColor.onPrimary.withAlphaComponent(0.5)], for: .disabled)
        return saveButton
    }()
    
    init(initialValue: String?, placeholder: String?) {
        self.initialValue = initialValue
        self.placeholder = placeholder
        super.init(nibName: nil, bundle: nil)
        
        // Setup UI
        view.backgroundColor = .background
        setupNavigationItem()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: User Action
    @objc private func saveButtonPressed() {
        saveValue(textField.text)
    }
    
    @objc private func cancelButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func textFieldDidChange() {
        saveButton.isEnabled = isValidValue(textField.text)
    }
    
    // MARK: Setup User Interface
    private func setupNavigationItem() {
        navigationItem.rightBarButtonItem = saveButton
        
        let cancelAction = #selector(cancelButtonPressed)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: cancelAction)
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: Can be overriden
    func saveValue(_ text: String?) { }
    
    func isValidValue(_ text: String?) -> Bool {
        return true
    }
}

// MARK: UITableViewDataSource
extension SettingsTextAttributeVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsTextFieldCell.reuseIdentifier,
            for: indexPath) as? SettingsTextFieldCell
            else {
                fatalError("Invalid Cell Type - Make sure SettingsTextFieldCell is registered")
        }
        
        cell.configure(initialValue: initialValue, placeholder: placeholder)
        cell.textField.removeTarget(nil, action: nil, for: .allEvents)
        cell.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // NOTE: The following two lines require this to only get hit once
        cell.textField.becomeFirstResponder()
        saveButton.isEnabled = isValidValue(cell.textField.text)
        return cell
    }
}

// MARK: UITableViewDelegate
extension SettingsTextAttributeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SettingsTextFieldCell.height
    }
}
