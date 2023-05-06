//
//  NewPlaylistViewController.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/19/23.
//

import UIKit

protocol PlaylistCreationDelegate: UIViewController {
    
    func playlistWasCreated(playlist: Playlist)
}

final class NewPlaylistViewController: UIViewController {

    private let viewModel: NewPlaylistViewModel
    
    weak var playlistCreationDelegate: PlaylistCreationDelegate?
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.tintColor = .onBackground
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        button.backgroundColor = .background
        return button
    }()
    
    private lazy var playlistNameTextField: DystoriaTextField = {
        let textField = DystoriaTextField(placeholder: "Playlist Name")
        textField.delegate = self
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkPrimary
        button.imageView?.tintColor = .onPrimary
        button.layer.cornerRadius = 28
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(savePlaylist), for: .touchUpInside)
        return button
    }()
    
    init(post: Post) {
        viewModel = NewPlaylistViewModel(post: post)
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func backButtonClicked() {
        dismiss(animated: true)
    }
    
    private func setupView() {
        view.backgroundColor = .background
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.height.width.equalTo(58)
            make.leading.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(playlistNameTextField)
        playlistNameTextField.snp.makeConstraints { make in
            make.centerY.trailing.leading.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(58)
        }
        
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(48)
            make.height.equalTo(58)
        }
    }
    
    @objc private func savePlaylist() {
        guard let name = playlistNameTextField.text, !name.isEmpty else { return }
        Task {
            await viewModel.savePlaylist(name: name)
            dismiss(animated: true)
        }
    }
}

extension NewPlaylistViewController: DystoriaTextFieldDelegate {
    func textDidUpdate(_ textField: DystoriaTextField) {
        return
    }
    
    func textFieldShouldReturn(_ textField: DystoriaTextField) {
        view.endEditing(true)
    }
}
