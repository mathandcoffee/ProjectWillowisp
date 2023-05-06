import UIKit
import Resolver
import Combine
import GiphyUISDK

class ImageReplyCollectionViewCell: UICollectionViewCell {
    
    private struct LayoutProfile {
        let profileImageDimension: CGFloat = 36
        let nameLabelHeight: CGFloat = 20
        let padding: CGFloat = .padding(.normal)
        let spacing: CGFloat = .spacing(.normal)
        let postPictureSpacing: CGFloat = .spacing(.large)
    }
    
    var likeAction: ((UUID) -> Void)?
    var commentAction: ((UUID) -> Void)?
    var profileAction: ((UUID) -> Void)?
    var voteToKickAction: ((UUID) -> Void)?
    var deleteAction: ((UUID) -> Void)?
    var editAction: ((UUID) -> Void)?
    var moreAction: ((User, Post?) -> Void)?
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var post: Post?
    
    private(set) lazy var startingLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .icon
        return view
    }()
    
    private(set) lazy var userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToProfile)))
        return imageView
    }()
    
    private(set) lazy var nameDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .onBackground
        label.font = .body1
        return label
    }()
    
    private(set) lazy var userPostLabel: UILabel = {
        let label = UILabel()
        label.font = .body2
        label.addURLGestureRecognizer()
        return label
    }()
    
    private(set) lazy var userPostImageView: GPHMediaView = {
        let imageView = GPHMediaView()
        imageView.backgroundColor = .background
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private(set) lazy var likesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .icon
        label.font = .subtitle1
        label.textAlignment = .center
        return label
    }()
    
    private(set) lazy var likeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(like), for: .touchUpInside)
        button.imageView?.tintColor = .icon
        return button
    }()
    
    private(set) lazy var commentButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(comment), for: .touchUpInside)
        button.imageView?.tintColor = .icon
        button.setImage(.comment.withRenderingMode(.alwaysTemplate), for: .normal)
        return button
    }()
    
    private(set) lazy var voteToKickButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(voteToKick), for: .touchUpInside)
        button.imageView?.tintColor = .icon
        return button
    }()
    
    private(set) lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(.delete, for: .normal)
        button.addTarget(self, action: #selector(deletePost), for: .touchUpInside)
        button.imageView?.tintColor = .icon
        button.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.equalTo(90)
        }
        return button
    }()
    
    private(set) lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.addArrangedSubview(likeButton)
        likeButton.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.equalTo(24)
        }
        
        stackView.addArrangedSubview(likesLabel)
        likesLabel.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        stackView.addArrangedSubview(commentButton)
        commentButton.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.equalTo(24)
        }
        
        let spacer1 = UIView(frame: .zero)
        stackView.addArrangedSubview(spacer1)
        spacer1.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.equalTo(24)
        }
        
        stackView.addArrangedSubview(voteToKickButton)
        voteToKickButton.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.equalTo(24)
        }
        
        let spacer2 = UIView(frame: .zero)
        stackView.addArrangedSubview(spacer2)
        spacer2.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.equalTo(24)
        }
        
        return stackView
    }()
    
    
    private(set) lazy var moreButton: UIButton = {
        let button = UIButton()
        button.setImage(.more, for: .normal)
        button.imageView?.tintColor = .onBackground
        button.addTarget(self, action: #selector(showMore), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func tap() {
        print("TAPPED")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .background
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        post = nil
        userPostImageView.image = nil
        userProfileImageView.image = nil
    }
    
    @objc private func like() {
        guard let post = post else {
            return
        }
    }
    
    @objc private func goToProfile() {
        guard let post = post else { return }
        
        profileAction?(post.user.id)
    }
    
    @objc private func comment() {
        guard let post = post else {
            return
        }
        
        commentAction?(post.id)
    }
    
    @objc private func voteToKick() {
        guard let post = post else {
            return
        }
        
        voteToKickAction?(post.id)
    }
    
    @objc private func editPost() {
        guard let post = post else {
            return
        }
        
        editAction?(post.id)
    }
    
    @objc private func deletePost() {
        guard let post = post else {
            return
        }
        
        deleteAction?(post.id)
    }
    
    @objc private func showMore() {
        print("Trying to show more**")
        guard let post = post else { return }
        moreAction?(post.user, post)
    }
    
    func configure(post: Post) {
        setupIfNeeded()
        let username = post.user.username
        let userProfileImageUrl: String? = post.user.avatar_url
        let userId = post.user.id
        
        self.post = post
        nameDateLabel.text = post.user.username
        userPostLabel.attributedText = userPostLabel.getAttributedString(input: post.post_text ?? "")
        if post.likes?.count ?? 0 > 0 {
            likesLabel.text = post.likes?.count.toPostViewableString()
        } else {
            likesLabel.text = "0"
            likeButton.setImage(.like, for: .normal)
        }
        
        if let imageUrl = userProfileImageUrl, let profileImageUrl = URL(string: imageUrl) {
            
        } else {
            userProfileImageView.image = .profileImageDefault
            userProfileImageView.tintColor = .onBackground
        }
        
        if let imageUrl = post.media_url, post.media_type == .gif {
            let id = String(imageUrl.split(separator: "-").last!)
                GiphyCore.shared.gifByID(id) { (response, error) in
                    if let media = response?.data {
                        DispatchQueue.main.sync { [weak self] in
                            self?.userPostImageView.media = media
                        }
                    }
                }
        } else if let imageUrl = post.media_url, let mediaImageUrl = URL(string: imageUrl) {
            
        }
        updateImageConstraints(post: post)

        if post.likes?.contains(where: { $0.user_id == post.user.id }) ?? false {
            likeButton.setImage(.likeFilled.withRenderingMode(.alwaysTemplate), for: .normal)
            likeButton.imageView?.tintColor = .icon
            likeButton.removeTarget(self, action: #selector(like), for: .touchUpInside)
        } else if post.user.id == userId {
            likeButton.setImage(.likeFilled.withRenderingMode(.alwaysTemplate), for: .normal)
            likeButton.imageView?.tintColor = .icon.withAlphaComponent(0.6)
            likeButton.removeTarget(self, action: #selector(like), for: .touchUpInside)
        } else {
            likeButton.setImage(.like.withRenderingMode(.alwaysTemplate), for: .normal)
            likeButton.imageView?.tintColor = .icon
            likeButton.addTarget(self, action: #selector(like), for: .touchUpInside)
        }
        
        if post.user.id == userId {
            moreButton.isHidden = true
            voteToKickButton.setImage(.edit, for: .normal)
            voteToKickButton.imageView?.tintColor = .icon
            voteToKickButton.removeTarget(self, action: #selector(voteToKick), for: .touchUpInside)
            voteToKickButton.addTarget(self, action: #selector(editPost), for: .touchUpInside)
            
            likeButton.tintColor = .icon.withAlphaComponent(0.6)
            
            buttonStackView.addArrangedSubview(deleteButton)
        } else {
            moreButton.isHidden = false
            voteToKickButton.setImage(.voteToKick, for: .normal)
            voteToKickButton.imageView?.tintColor = .icon
            voteToKickButton.removeTarget(self, action: #selector(editPost), for: .touchUpInside)
            voteToKickButton.addTarget(self, action: #selector(voteToKick), for: .touchUpInside)
            deleteButton.removeFromSuperview()
        }
    }
    
    private func setupIfNeeded() {
        guard userProfileImageView.superview == nil else {
            return
        }
        
        let layout = LayoutProfile()
        backgroundColor = .background
        backgroundColor = .background
        
        addSubview(userProfileImageView)
        userProfileImageView.snp.makeConstraints { make in
            make.height.width.equalTo(layout.profileImageDimension)
            make.top.equalToSuperview().offset(layout.padding)
            make.left.equalTo(51.5)
        }
        
        addSubview(nameDateLabel)
        nameDateLabel.snp.makeConstraints { make in
            make.leading.equalTo(userProfileImageView.snp.trailing).offset(layout.spacing)
            make.height.equalTo(layout.nameLabelHeight)
            make.top.equalTo(userProfileImageView)
        }
        
        userPostLabel.textColor = .onBackground
        userPostLabel.numberOfLines = 0
        addSubview(userPostLabel)
        userPostLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameDateLabel)
            make.trailing.equalToSuperview().offset(-layout.padding)
            make.top.equalTo(nameDateLabel.snp.bottom).offset(CGFloat.spacing(.normal))
        }
        
        addSubview(userPostImageView)
        
        addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(CGFloat.spacing * 2)
        }
        
        addSubview(startingLineView)
        startingLineView.snp.makeConstraints { make in
            make.width.equalTo(2)
            make.centerX.equalTo(userProfileImageView)
            make.top.equalToSuperview()
            make.bottom.equalTo(userProfileImageView.snp.top)
        }
        
        addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(layout.padding)
            make.height.width.equalTo(24)
        }
        
        addSubview(userPostImageView)
        userPostImageView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(userPostLabel)
            make.bottom.equalTo(likeButton.snp.top).offset(-layout.padding)
            make.top.equalTo(userPostLabel.snp.bottom).offset(CGFloat.spacing(.large))
            make.height.equalTo(userPostImageView.snp.width)
        }
    }
    
    private func updateImageConstraints(post: Post) {
        let layout = LayoutProfile()
        
        if post.media_aspect == nil {
            userPostImageView.removeFromSuperview()
            userPostImageView.snp.removeConstraints()
            return
        }
        
        addSubview(userPostImageView)
        userPostImageView.snp.remakeConstraints { make in
            make.leading.trailing.equalTo(userPostLabel)
            make.bottom.equalTo(likeButton.snp.top).offset(-layout.padding)
            make.top.equalTo(userPostLabel.snp.bottom).offset(CGFloat.spacing(.large))
            make.height.equalTo(userPostImageView.snp.width).multipliedBy(post.media_aspect!)
        }
    }
}

class ImageReplyWithAdditionalRepliesCollectionViewCell: ImageReplyCollectionViewCell {
    
    private let commentLineView = UIView(frame: .zero)
    
    override func configure(post: Post) {
        super.configure(post: post)
        setupSequenceLine()
    }
    
    fileprivate final func setupSequenceLine() {
        guard commentLineView.superview == nil else { return }
        addSubview(commentLineView)
        commentLineView.backgroundColor = .icon
        commentLineView.snp.makeConstraints { make in
            make.top.equalTo(userProfileImageView.snp.bottom)
            make.bottom.equalToSuperview()
            make.centerX.equalTo(userProfileImageView)
            make.width.equalTo(2)
        }
    }
}

class ImageInitialReplyCollectionViewCell: ImageReplyCollectionViewCell {
    
    private var startingHorizontalView = UIView(frame: .zero)
    private var startingVerticalView = UIView(frame: .zero)
    
    override func configure(post: Post) {
        super.configure(post: post)
        setupStartingLines()
    }
    
    fileprivate final func setupStartingLines() {
        guard startingHorizontalView.superview == nil else { return }
        startingLineView.snp.removeConstraints()
        startingLineView.removeFromSuperview()
        
        addSubview(startingHorizontalView)
        startingHorizontalView.backgroundColor = .icon
        startingHorizontalView.snp.makeConstraints { make in
            make.centerY.equalTo(userProfileImageView)
            make.right.equalTo(userProfileImageView.snp.left)
            make.height.equalTo(2)
            make.leading.equalToSuperview().offset(33)
        }
        
        addSubview(startingVerticalView)
        startingVerticalView.backgroundColor = .icon
        startingVerticalView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(startingHorizontalView.snp.left)
            make.bottom.equalTo(startingHorizontalView.snp.top)
            make.width.equalTo(2)
        }
    }
}

class ImageInitialReplyWithAddtionalRepliesCollectionViewCell: ImageInitialReplyCollectionViewCell {
    
    private let commentLineView = UIView(frame: .zero)
    
    override func configure(post: Post) {
        super.configure(post: post)
        setupSequenceLine()
    }
    
    fileprivate final func setupSequenceLine() {
        guard commentLineView.superview == nil else { return }
        addSubview(commentLineView)
        commentLineView.backgroundColor = .icon
        commentLineView.snp.makeConstraints { make in
            make.top.equalTo(userProfileImageView.snp.bottom)
            make.bottom.equalToSuperview()
            make.centerX.equalTo(userProfileImageView)
            make.width.equalTo(2)
        }
    }
}
