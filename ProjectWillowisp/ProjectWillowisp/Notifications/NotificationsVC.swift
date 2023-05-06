//
//  NotificationsVC.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 1/5/22.
//

import UIKit

final class NotificationsVC: UIViewController {
    
    private var notifications: [WillowNotification] = []
    
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
        backButton.addTarget(self, action: #selector(done), for: .touchUpInside)
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
        label.text = "Notifications"
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.height.equalTo(backButton)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().dividedBy(1.5)        }
        
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(NotificationsCollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.cellIdentifierForType(type: NotificationsCollectionViewCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .background
        return collectionView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupView()
        Task {
            do {
                let response: [WillowNotification] = try await SupabaseProvider.shared.supabaseClient.database.from("notifications").select(columns: "*,post:posts(*,user:profiles(*))").execute().value
                notifications = response
                collectionView.reloadData()
            } catch {
                print(error)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        view.backgroundColor = .background
        
        view.addSubview(navigationView)
        navigationView.snp.makeConstraints { make in
            make.top.width.centerX.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(56)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc private func done() {
        navigationController?.popViewController(animated: true)
    }
}

extension NotificationsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        
        return CGSize(width: collectionView.frame.width, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let post = notifications[indexPath.row].post else { return }
        navigateToPostBasedVC(.commentOnPost, false, post, nil)
    }
}

extension NotificationsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UICollectionViewCell.cellIdentifierForType(
                type: NotificationsCollectionViewCell.self
            ),
            for: indexPath
        ) as? NotificationsCollectionViewCell else { fatalError() }
        
        cell.configure(notification: notifications[indexPath.row])
        
        return cell
    }
}
