//
//  ProfileImagePickerVC.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 11/23/21.
//

import UIKit
import Supabase
import SupabaseStorage
import Combine
import ImagePicker

class ProfileImagePickerVC: UIViewController {
    
    private let userProfileService = UserProfileService.shared
    
    private let activityIndicator = UIActivityIndicatorView()
    private let saveImageButton = AuthButton(style: .fill, text: "Next")
    private var imagePicker: ImagePickerController?
    
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var imagePickerBackground: ImagePickerBackground = {
        let background = ImagePickerBackground() { [weak self] in
            DispatchQueue.main.async {
                let config = ImagePickerConfiguration()
                config.allowMultiplePhotoSelection = false
                config.backgroundColor = .background
                config.gallerySeparatorColor = .surface
                config.galleryOnly = true
                let imagePicker = ImagePickerController(configuration: config)
                self?.imagePicker = imagePicker
                imagePicker.delegate = self
                self?.present(imagePicker, animated: true, completion: nil)
            }
        }
        background.layer.cornerRadius = 16
        return background
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupConstraints()
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(self) deinited correctly")
    }
    
    private func setupConstraints() {
        view.backgroundColor = .background
        
        view.addSubview(imagePickerBackground)
        imagePickerBackground.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(view.snp.width).dividedBy(1.3)
        }
        
        let label = UILabel()
        label.text = "Choose a profile image to represent you"
        label.numberOfLines = 2
        label.textColor = .onBackground
        label.adjustsFontSizeToFitWidth = true
        label.font = .headline2
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.width.equalToSuperview().dividedBy(1.2)
            make.height.equalTo(120)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(imagePickerBackground.snp.top).offset(-56)
        }
    }
    
    @objc private func saveProfileImage() {
        guard let image = imagePickerBackground.currentImage?.pngData() else { return }
        activityIndicator.startAnimating()
        saveImageButton.isUserInteractionEnabled = false
        saveImageButton.alpha = 0.7
        guard let userId = userProfileService.currentUser?.id.uuidString.lowercased() else { return }
        let id = UUID().uuidString
        let filename = "\(id).png"
        Task {
            let storageClient = await SupabaseProvider.shared.storageClient()
            guard let _ = try? await storageClient?.upload(path: "\(userId)/\(filename)", file: File(name: filename, data: image, fileName: filename, contentType: "image/png"), fileOptions: FileOptions(cacheControl: "3600")) else { return }
            let success = await UserProfileService.shared.updateProfileUrl(url: "\(userId)/\(filename)")
            if success {
                showCoverImageVC()
            } else {
                let alert = UIAlertController(title: "Server Error", message: "There was a problem with your request. Please check your connection and try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc private func showCoverImageVC() {
        navigateTo(.coverPhoto)
    }
    
    private func setupButtons() {
        
        let skipButton = AuthButton(style: .border, text: "Skip")
        skipButton.addTarget(self, action: #selector(showCoverImageVC), for: .touchUpInside)
        view.addSubview(skipButton)
        skipButton.snp.makeConstraints { make in
            make.height.equalTo(AuthButton.suggestedHeight)
            make.leading.trailing.equalToSuperview().inset(CGFloat.padding)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        saveImageButton.addTarget(self, action: #selector(saveProfileImage), for: .touchUpInside)
        view.addSubview(saveImageButton)
        saveImageButton.snp.makeConstraints { make in
            make.height.equalTo(AuthButton.suggestedHeight)
            make.leading.trailing.equalToSuperview().inset(CGFloat.padding)
            make.bottom.equalTo(skipButton.snp.top).offset(-CGFloat.spacing)
        }
        
        activityIndicator.color = .onBackground
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.centerY.centerX.equalTo(saveImageButton)
        }
    }
}

extension ProfileImagePickerVC: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        DispatchQueue.main.async {
            if let photo = images.first {
                self.imagePickerBackground.imageView.image = photo
            }
            imagePicker.dismiss(animated: true, completion: nil)
            self.imagePicker = nil
        }
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        DispatchQueue.main.async {
            if let photo = images.first {
                self.imagePickerBackground.imageView.image = photo
            }
            imagePicker.dismiss(animated: true, completion: nil)
            self.imagePicker = nil
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
        self.imagePicker = nil
    }
}
