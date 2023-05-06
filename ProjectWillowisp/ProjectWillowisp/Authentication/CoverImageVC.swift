//
//  CoverImageVC.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 12/19/21.
//

import UIKit
import Resolver
import Combine
import ImagePicker
import SupabaseStorage

class CoverImageVC: UIViewController {
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView()
    private let saveImageButton = AuthButton(style: .fill, text: "Next")
    
    private var imagePicker: ImagePickerController?
    
    private lazy var displayNameLabel: UILabel = {
        let label = UILabel()
        label.text = UserProfileService.shared.currentUser?.username
        label.numberOfLines = 1
        label.textColor = .onBackground
        label.font = .headline2
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
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
        
        view.addSubview(imageView)
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(view.snp.width).dividedBy(3)
        }
        
        Task {
            if let profilePhotoUrl = UserProfileService.shared.currentUser?.avatar_url{
                if let data = try? await SupabaseProvider.shared.storageClient()?.download(path: profilePhotoUrl) {
                    imageView.image = UIImage(data: data)
                }
                
            }
        }
        
        view.addSubview(imagePickerBackground)
        imagePickerBackground.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(imageView.snp.centerY)
            make.width.equalToSuperview()
            make.height.equalTo(imageView.snp.height).multipliedBy(1.5)
        }
        
        view.bringSubviewToFront(imageView)
        
        let label = UILabel()
        label.text = "Choose a cover image to spruce up your profile"
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .onBackground
        label.font = .headline2
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.width.equalToSuperview().dividedBy(1.2)
            make.height.equalTo(120)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        
        view.addSubview(displayNameLabel)
        displayNameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(32)
        }
    }
    
    @objc private func saveProfileImage() {
        guard let image = imagePickerBackground.currentImage?.pngData() else { return }
        activityIndicator.startAnimating()
        saveImageButton.isUserInteractionEnabled = false
        saveImageButton.alpha = 0.7
        
        guard let userId = UserProfileService.shared.currentUser?.id.uuidString.lowercased() else { return }
        let id = UUID().uuidString
        let filename = "\(id).png"
        Task {
            let storageClient = await SupabaseProvider.shared.storageClient()
            guard let _ = try? await storageClient?.upload(path: "\(userId)/\(filename)", file: File(name: filename, data: image, fileName: filename, contentType: "image/png"), fileOptions: FileOptions(cacheControl: "3600")) else { return }
            let success = await UserProfileService.shared.updateCoverPhoto(url: "\(userId)/\(filename)")
            if success {
                showBioVC()
            } else {
                let alert = UIAlertController(title: "Server Error", message: "There was a problem with your request. Please check your connection and try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc private func showBioVC() {
        navigateTo(.bio)
    }
    
    private func setupButtons() {
        
        let skipButton = AuthButton(style: .border, text: "Skip")
        skipButton.addTarget(self, action: #selector(showBioVC), for: .touchUpInside)
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

extension CoverImageVC: ImagePickerDelegate {
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
