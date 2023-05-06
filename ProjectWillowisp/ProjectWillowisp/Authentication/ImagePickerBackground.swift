//
//  ImagePickerBackground.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 12/18/21.
//

import UIKit
import ImagePicker

class ImagePickerBackground: UIView {
    
    private let pickImageAction: (() -> Void)
    
    let imageView = UIImageView()
    
    var currentImage: UIImage? {
        return imageView.image
    }
    
    init(completion: @escaping () -> Void) {
        self.pickImageAction = completion
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func pickImage() {
        pickImageAction()
    }
    
    private func setupView() {
        backgroundColor = .lightBackground
        layer.masksToBounds = true
        
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.snp.makeConstraints { make in
            make.top.height.width.leading.equalToSuperview()
        }
        
        let imageView = UIImageView()
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(32)
            make.top.right.equalToSuperview().inset(16)
        }
        imageView.tintColor = .onBackground
        imageView.image = .edit
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickImage)))
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
}
