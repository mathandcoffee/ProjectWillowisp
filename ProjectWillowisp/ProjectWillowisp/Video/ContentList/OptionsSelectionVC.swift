//
//  OptionsSelectionVC.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 3/23/23.
//

import UIKit
import Combine

protocol OptionsSelectionDelegate: UIViewController {
    
    func didSelectOption(_ option: OptionsSelectionVC.OptionAction)
}

class OptionsSelectionVC: UIViewController {
    
    weak var delegate: OptionsSelectionDelegate?
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(OptionsCollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: OptionsCollectionViewCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .background
        return collectionView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(.back, for: .normal)
        button.backgroundColor = .background
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        button.tintColor = .onBackground
        return button
    }()
    
    enum OptionAction {
        case loopOn
        case loopOff
        case loopInterval
        case report
        case addToPlaylist
        case createPlaylist
    }
    
    func imageForAction(_ action: OptionAction) -> UIImage {
        switch (action) {
        case .loopOn:
            return .loop
        case .loopOff:
            return .loop
        case .loopInterval:
            return .loop
        case .report:
            return .report
        case .addToPlaylist:
            return UIImage(systemName: "plus.square.on.square")!
        case .createPlaylist:
            return UIImage(systemName: "list.bullet.rectangle.portrait")!
        }
    }
    
    func stringForAction(_ action: OptionAction) -> String {
        switch (action) {
        case .loopOn:
            return "Loop On "
        case .loopOff:
            return "Loop Off "
        case .report:
            return "Report User "
        case .loopInterval:
            return "Loop Video "
        case .addToPlaylist:
            return "Add to Playlist"
        case .createPlaylist:
            return "Create a Playlist"
        }
    }
    
    func performAction(action: OptionAction) {
        dismiss(animated: true) {
            self.delegate?.didSelectOption(action)
        }
    }
    
    private var availableActions: [OptionAction] {
        var options: [OptionAction] = [
            .addToPlaylist,
            .createPlaylist,
            .report
        ]
        if let delegate = delegate as? VideoPlaybackViewController, delegate.posts.count > 1 {
            options = [.loopInterval, .report]
        } else if let _ = delegate as? VideoPlaybackViewController {
            options = [
                .addToPlaylist,
                .createPlaylist,
                .loopInterval,
                .report
            ]
        } else if let delegate = delegate as? CommentOnPostVC, delegate.isShowingCommentOptions {
            options = [.report]
        } else if let _ = delegate as? ProfileVC {
            options = [.report]
        }
        return options
    }
    
    init() {
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
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(CGFloat.padding)
            make.height.width.equalTo(48)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.width.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalToSuperview().offset(64)
        }
    }
    
    @objc private func back() {
        dismiss(animated: true)
    }
}

extension OptionsSelectionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: 36)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let action = availableActions[indexPath.row]
        performAction(action: action)
    }
}

extension OptionsSelectionVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: OptionsCollectionViewCell.self),
            for: indexPath) as? OptionsCollectionViewCell else { fatalError() }
        
        let action = availableActions[indexPath.row]
        cell.configure(image: imageForAction(action), text: stringForAction(action))
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return availableActions.count
    }
}
