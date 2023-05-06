//
//  VideoPlaybackViewController.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/8/23.
//

import UIKit
import SnapKit
import AVFoundation
import AVKit
import Combine

final class VideoPlaybackViewController: UIViewController {
    
    private let worker = VideoPlayerWorker()
    
    let posts: [Post]
    private var postToAdd: Post?
    
    private var looper: AVPlayerLooper?
    
    private let player = AVPlayer()
    private let playerItems: [AVPlayerItem]
    private var currentTrack = -1
    private var shouldLoop = false
    private var maximumTime = CMTime.zero {
        didSet {
            lblIntervalMaximumTime.text = maximumTime.durationText
        }
    }
    private var minimumTime = CMTime.zero {
        didSet {
            lblIntervalMinimumTime.text = minimumTime.durationText
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    func previousTrack() {
        skipForwardButton.isEnabled = false
        skipBackwardButton.isEnabled = false
        if isVideoPlaying { onBtnPlayPause() }
        if shouldLoop {
            player.seek(to: CMTime.zero)
            onBtnPlayPause()
            skipForwardButton.isEnabled = true
            skipBackwardButton.isEnabled = true
            playTrack()
            return
        }
        if currentTrack - 1 <= 0 {
            currentTrack = (playerItems.count - 1) < 0 ? 0 : (playerItems.count - 1)
        } else {
            currentTrack -= 1
        }

        playTrack()
    }

    func nextTrack() {
        skipForwardButton.isEnabled = false
        skipBackwardButton.isEnabled = false
        if isVideoPlaying { onBtnPlayPause() }
        if shouldLoop {
            player.seek(to: CMTime.zero)
            onBtnPlayPause()
            skipForwardButton.isEnabled = true
            skipBackwardButton.isEnabled = true
            playTrack()
            return
        }
        if currentTrack + 1 >= playerItems.count {
            currentTrack = 0
        } else {
            currentTrack += 1;
        }

        playTrack()
    }

    func playTrack() {
        if playerItems.count > 0 {
            player.seek(to: CMTime.zero)
            player.replaceCurrentItem(with: playerItems[currentTrack])
            if !isVideoPlaying { onBtnPlayPause() }
            skipForwardButton.isEnabled = true
            skipBackwardButton.isEnabled = true
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .onBackground
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.font = .headline3
        return label
    }()
    
    private lazy var lblCurrentTime: UILabel = {
        let label = UILabel()
        label.textColor = .onBackground
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.font = .body1
        label.text = "00:00 / "
        return label
    }()
    
    private lazy var lblDurationTime: UILabel = {
        let label = UILabel()
        label.textColor = .onBackground
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.font = .body1
        return label
    }()
    
    private lazy var intervalSlider: DoubledSlider = {
        let slider = DoubledSlider()
        slider.minimumValue = 0
        slider.isHidden = true
        slider.addTarget(self, action: #selector(intervalSliderTappedAction), for: .valueChanged)
        return slider
    }()
    
    private lazy var sliderTime: UISlider = {
        let slider = UISlider()
        slider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sliderTappedAction(sender:))))
        return slider
    }()

    private lazy var btnMute: UIButton = {
        let button = UIButton()
        let muted = UserDefaults.standard.value(forKey: "IS_PLAYER_MUTED") as? Bool ?? false
        button.isSelected = muted
        player.isMuted = muted
        button.addTarget(self, action: #selector(onBtnMute), for: .touchUpInside)
        button.tintColor = .onBackground
        if button.isSelected {
            button.setImage(UIImage(systemName: "speaker.slash"), for: .normal)
        } else {
            button.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)
        }
        return button
    }()
    
    private lazy var shadowView: UIImageView = {
        let shadowView = UIImageView(image: UIImage(named: "shadowBottom")?.withRenderingMode(.alwaysTemplate))
        shadowView.contentMode = .scaleToFill
        shadowView.tintColor = .surface
        return shadowView
    }()
    
    private lazy var showPlaylistButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        button.tintColor = .onBackground
        button.isHidden = playerItems.count <= 1
        button.addTarget(self, action: #selector(showPlaylist), for: .touchUpInside)
        return button
    }()
    
    private lazy var settingsButton: UIButton = {
        let settingsButton = UIButton()
        settingsButton.setImage(.settings, for: .normal)
        settingsButton.addTarget(self, action: #selector(showOptions), for: .touchUpInside)
        settingsButton.imageView?.tintColor = .onPrimary
        settingsButton.backgroundColor = .background.withAlphaComponent(0.4)
        settingsButton.layer.cornerRadius = 4
        return settingsButton
    }()
    
    var imgTopShadow = UIImageView()
    private lazy var viewPlayerDetails: UIView = {
        let view = UIView()
            
        view.addSubview(intervalSlider)
        view.addSubview(backButton)
        view.addSubview(shadowView)
        view.addSubview(lblCurrentTime)
        view.addSubview(lblDurationTime)
        view.addSubview(btnMute)
        view.addSubview(sliderTime)
        view.addSubview(titleLabel)
        view.addSubview(showPlaylistButton)
        view.addSubview(lblIntervalMaximumTime)
        view.addSubview(lblIntervalMinimumTime)
        view.addSubview(intervalSlider)
        
        lblIntervalMinimumTime.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(CGFloat.padding)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(0)
        }
        
        intervalSlider.snp.makeConstraints { make in
            make.bottom.equalTo(lblIntervalMaximumTime).offset(-CGFloat.padding)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(CGFloat.padding)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(48 + CGFloat.padding * 2)
            make.height.equalTo(0)
        }
        
        lblIntervalMaximumTime.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalTo(intervalSlider)
            make.height.equalTo(0)
        }
        
        backButton.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide)
            make.height.width.equalTo(48)
        }
        
        shadowView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().dividedBy(2)
        }
        
        lblCurrentTime.snp.makeConstraints { make in
            make.bottom.equalTo(intervalSlider.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(CGFloat.padding)
            make.height.equalTo(24)
        }
        
        lblDurationTime.snp.makeConstraints { make in
            make.bottom.equalTo(intervalSlider.snp.top)
            make.leading.equalTo(lblCurrentTime.snp.trailing)
            make.height.equalTo(24)
        }
        
        btnMute.snp.makeConstraints { make in
            make.bottom.equalTo(lblCurrentTime.snp.top)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(CGFloat.padding)
            make.width.height.equalTo(48)
        }
        
        sliderTime.snp.makeConstraints { make in
            make.bottom.equalTo(lblCurrentTime.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(CGFloat.padding)
            make.trailing.equalTo(btnMute.snp.leading).offset(-CGFloat.padding)
            make.height.equalTo(48)
        }
        
        showPlaylistButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-CGFloat.padding)
            make.bottom.equalTo(sliderTime.snp.top).offset(CGFloat.padding(.small))
            make.width.height.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(CGFloat.padding)
            make.trailing.equalTo(showPlaylistButton.snp.leading).offset(-CGFloat.padding)
            make.bottom.equalTo(sliderTime.snp.top).offset(CGFloat.padding(.small))
            make.height.equalTo(48)
        }
        
        view.addSubview(settingsButton)
        settingsButton.snp.makeConstraints { make in
            make.trailing.top.equalTo(view.safeAreaLayoutGuide)
            make.height.width.equalTo(48)
        }
        
        return view
    }()

    private var isVideoPlaying = false
    private var isPlayerViewHide = true
    private var pauseTime: CMTime = .zero
    private var timer: Timer?
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        button.tintColor = .onBackground
        button.backgroundColor = .background.withAlphaComponent(0.4)
        button.layer.cornerRadius = 4
        return button
    }()
    
    private lazy var playerVC: AVPlayerViewController = {
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        playerVC.showsPlaybackControls = true
        return playerVC
    }()
    
    private lazy var pausePlayButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "pause.fill")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .onBackground
        button.isHidden = false
        button.addTarget(self, action: #selector(onBtnPlay(_:)), for: .touchUpInside)
        button.backgroundColor = .background.withAlphaComponent(0.4)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private lazy var skipForwardButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "forward.fill")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .onBackground
        button.isHidden = false
        button.addTarget(self, action: #selector(playerSkipForward), for: .touchUpInside)
        button.backgroundColor = .background.withAlphaComponent(0.4)
        button.layer.cornerRadius = 8
        button.isHidden = playerItems.count <= 1
        return button
    }()
    
    private lazy var skipBackwardButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "backward.fill")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .onBackground
        button.isHidden = false
        button.addTarget(self, action: #selector(playerBackStep), for: .touchUpInside)
        button.backgroundColor = .background.withAlphaComponent(0.4)
        button.layer.cornerRadius = 8
        button.isHidden = playerItems.count <= 1
        return button
    }()
    
    private lazy var lblIntervalMinimumTime: UILabel = {
        let label = UILabel()
        label.textColor = .onBackground
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.font = .body1
        label.text = "00:00"
        return label
    }()
    
    private lazy var lblIntervalMaximumTime: UILabel = {
        let label = UILabel()
        label.textColor = .onBackground
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.font = .body1
        return label
    }()
    
    init(url: URL, post: Post) {
        let playerItem = worker.play(with: url)
        posts = [post]
        playerItems = [playerItem]
        super.init(nibName: nil, bundle: nil)
        playerSkipForward()
        setupView()
    }
    
    init(urls: [URL], posts: [Post]) {
        var playerItems: [AVPlayerItem] = []
        for url in urls {
            playerItems.append(worker.play(with: url))
        }
        self.playerItems = playerItems
        self.posts = posts
        super.init(nibName: nil, bundle: nil)
        playerSkipForward()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        player.currentItem?.removeObserver(self, forKeyPath: "duration")
        player.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges")
    }
    
    @objc private func backButtonPressed() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func sliderTappedAction(sender: UITapGestureRecognizer) {
        guard let slider = sender.view as? UISlider else { return }
        if slider.isHighlighted { return }
        player.pause()
        let point = sender.location(in: slider)
        let percentage = Float(point.x / CGRectGetWidth(slider.bounds))
        let delta = percentage * (slider.maximumValue - slider.minimumValue)
        let value = slider.minimumValue + delta
        slider.setValue(value, animated: true)
        let seekingCM = CMTimeMake(value: Int64(slider.value * Float(pauseTime.timescale)), timescale: pauseTime.timescale)
        lblCurrentTime.text = seekingCM.durationText + " / "
        player.seek(to: seekingCM)
        player.play()
        pausePlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    @objc private func intervalSliderTappedAction() {
        let slider = intervalSlider
        if slider.isHighlighted { return }
        player.pause()
        minimumTime = CMTimeMake(value: Int64(slider.minimumValueNow * Float(pauseTime.timescale)), timescale: pauseTime.timescale)
        maximumTime = CMTimeMake(value: Int64(slider.maximumValueNow * Float(pauseTime.timescale)), timescale: pauseTime.timescale)
        lblCurrentTime.text = minimumTime.durationText + " / "
        player.seek(to: minimumTime)
        player.play()
        pausePlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    private func setupView() {
        player.automaticallyWaitsToMinimizeStalling = true
        
        playerVC.view.backgroundColor = .background
        
        view.backgroundColor = .background
        
        view.addSubview(playerVC.view)
        playerVC.view.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalTo(view)
        }
        
        view.addSubview(viewPlayerDetails)
        viewPlayerDetails.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(view)
            make.bottom.equalToSuperview()
        }
        
        setupVideoTimeSlider()
        setupPlayer()
    }
    
    @objc private func showOptions() {
        postToAdd = posts[currentTrack]
        let viewController = OptionsSelectionVC()
        viewController.delegate = self
        
        if let presentationController = viewController.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
        }
        
        present(viewController, animated: true)
    }
    
    @objc private func showPlaylist() {
        let viewController = PlaylistSelectionViewController(playlist: posts)
        viewController.delegate = self
        if let presentationController = viewController.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
        }
        
        present(viewController, animated: true)
    }
    
    private func setupVideoTimeSlider() {
        sliderTime.maximumTrackTintColor = .surface
        sliderTime.minimumTrackTintColor = .primary
        sliderTime.thumbTintColor = .primary
        
        sliderTime.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        sliderTime.isUserInteractionEnabled = false
    }
    
    private func setupPlayer() {
        player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        player.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        
        addTimeObserver()
        addObserverToVideoisEnd()
        
        setupPlayButtonInsideVideoView()
    }
    
    private func addObserverToVideoisEnd() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerSkipForward), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { [weak self] time in
            guard let currentItem = self?.player.currentItem, let self = self else {return}
            if self.player.currentItem?.status == .readyToPlay {
                if self.maximumTime == .zero {
                    self.maximumTime = currentItem.duration
                }
                self.sliderTime.minimumValue = 0
                self.sliderTime.maximumValue = Float(currentItem.duration.seconds)
                self.intervalSlider.maximumValue = Float(currentItem.duration.seconds)
                if time >= self.maximumTime, self.shouldLoop {
                    self.sliderTime.value = Float(self.minimumTime.seconds)
                    self.player.seek(to: self.minimumTime)
                    self.lblCurrentTime.text = self.minimumTime.durationText + " / "
                    self.lblDurationTime.text = currentItem.duration.durationText
                } else {
                    self.sliderTime.value = Float(time.seconds)
                    self.lblCurrentTime.text = time.durationText + " / "
                    self.lblDurationTime.text = currentItem.duration.durationText
                }
            }
        }
    }
    
    private func setupPlayButtonInsideVideoView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.someAction(_:)))
        view.addGestureRecognizer(gesture)
        viewPlayerDetails.addGestureRecognizer(gesture)
        
        view.addSubview(pausePlayButton)
        pausePlayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pausePlayButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        pausePlayButton.widthAnchor.constraint(equalToConstant: 48).isActive = true
        pausePlayButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        view.addSubview(skipForwardButton)
        skipForwardButton.snp.makeConstraints { make in
            make.centerY.equalTo(pausePlayButton)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-CGFloat.padding(.large))
            make.height.width.equalTo(48)
        }
        
        view.addSubview(skipBackwardButton)
        skipBackwardButton.snp.makeConstraints { make in
            make.centerY.equalTo(pausePlayButton)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(CGFloat.padding(.large))
            make.height.width.equalTo(48)
        }
    }
    
    private func onBtnPlayPause() {
        isVideoPlaying.toggle()
        if isVideoPlaying {
            player.pause()
            pausePlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player.play()
            pausePlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    private func handleControls(hidden: Bool) {
        self.pausePlayButton.isHidden = hidden
        self.imgTopShadow.isHidden = hidden
        self.sliderTime.isHidden = hidden
        self.lblCurrentTime.isHidden = hidden
        self.lblDurationTime.isHidden = hidden
        self.btnMute.isHidden = hidden
        self.isPlayerViewHide = hidden
        self.shadowView.isHidden = hidden
        self.backButton.isHidden = hidden
        self.titleLabel.isHidden = hidden
        self.skipForwardButton.isHidden = hidden || playerItems.count <= 1
        self.skipBackwardButton.isHidden = hidden || playerItems.count <= 1
        self.settingsButton.isHidden = hidden
        self.showPlaylistButton.isHidden = hidden || playerItems.count <= 1
        self.intervalSlider.isHidden = hidden || !shouldLoop
        self.lblIntervalMaximumTime.isHidden = hidden || !shouldLoop
        self.lblIntervalMinimumTime.isHidden = hidden || !shouldLoop
    }
    
    private func hideshowPlayerView(isViewTouch: Bool = false) {
        
        if isPlayerViewHide {
            UIView.transition(with: self.viewPlayerDetails, duration: 0.6,
                              options: .transitionCrossDissolve,
                              animations: {
                self.handleControls(hidden: false)
            })
        } else {
            if isViewTouch {
                UIView.transition(with: self.viewPlayerDetails, duration: 0.6,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.handleControls(hidden: true)
                })
            }
            
        }
        self.timer?.invalidate()
        if isPlayerViewHide == false && isVideoPlaying {
            self.timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] timer in
                if self?.isPlayerViewHide == false && self!.isVideoPlaying {
                    UIView.transition(with: self!.viewPlayerDetails, duration: 0.3,
                                      options: .transitionCrossDissolve,
                                      animations: {
                        self?.handleControls(hidden: true)
                    })
                }
            }
        }
    }
    
    @objc private func onBtnMute() {
        if isPlayerViewHide == false {
            timer?.invalidate()
            hideshowPlayerView()
        }
        btnMute.isSelected.toggle()
        player.isMuted = btnMute.isSelected
        UserDefaults.standard.setValue(btnMute.isSelected, forKey: "IS_PLAYER_MUTED")
        if btnMute.isSelected {
            btnMute.setImage(UIImage(systemName: "speaker.slash"), for: .normal)
        } else {
            btnMute.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)
        }
    }
    
    // MARK: - Event
    @objc private func onBtnPlay(_ sender: Any) {
        onBtnPlayPause()
    }
    
    @objc private func onSliderValChanged(slider: UISlider, event: UIEvent) {
        self.timer?.invalidate()
        let seekingCM = CMTimeMake(value: Int64(slider.value * Float(pauseTime.timescale)), timescale: pauseTime.timescale)
        lblCurrentTime.text = seekingCM.durationText + " / "
        player.seek(to: seekingCM)
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                player.pause()
                guard let currentTime = player.currentItem?.currentTime() else {return}
                self.pauseTime = currentTime
            case .moved:
                break
            case .ended:
                if isVideoPlaying {
                    player.play()
                    pausePlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                } else {
                    player.pause()
                    pausePlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                }
                self.hideshowPlayerView()
            default:
                break
            }
        }
        
    }
    
    @objc private func someAction(_ sender: UITapGestureRecognizer) {
        self.hideshowPlayerView(isViewTouch: true)
    }
    
    @objc private func playerSkipForward() {
        nextTrack()
        resetVideoState()
    }
    
    @objc private func playerBackStep() {
        previousTrack()
        resetVideoState()
    }
    
    func resetVideoState() {
        shouldLoop = false
        minimumTime = .zero
        maximumTime = .zero
        titleLabel.text = posts[currentTrack].title
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if !isViewLoaded { return }
        if keyPath == "duration", let duration = player.currentItem?.duration.seconds, duration > 0.0 {
            self.lblDurationTime.text = player.currentItem!.duration.durationText
        }
        
        if keyPath == "currentItem.loadedTimeRanges" {
            sliderTime.isUserInteractionEnabled = true
        }
    }
}

extension VideoPlaybackViewController: PlaylistSelectionDelegate {
    func selectedItem(_ playlistItem: Post, _ index: Int) {
        if index >= playerItems.count { return }
        let playerItem = playerItems[index]
        player.seek(to: CMTime.zero)
        currentTrack = index
        player.replaceCurrentItem(with: playerItem)
        player.play()
        pausePlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
}

extension VideoPlaybackViewController: AddToPlaylistDelegate {
    func didSelectPlaylist(_ playlist: Playlist) {
        guard let postToAdd = postToAdd else { return }
        let playlistItemsDatabase = SupabaseProvider.shared.playlistItemsDatabase
        Task {
            do {
                let _ = try await playlistItemsDatabase.insert(
                    values: PlaylistItemRequestPacket(
                        post: postToAdd,
                        playlistId: playlist.id)
                ).execute().value
            } catch {
                print(error)
            }
            self.postToAdd = nil
        }
    }
}

extension VideoPlaybackViewController: OptionsSelectionDelegate {
    func didSelectOption(_ option: OptionsSelectionVC.OptionAction) {
        switch option {
        case .loopInterval:
            shouldLoop.toggle()
            intervalSlider.snp.updateConstraints { make in
                intervalSlider.isHidden = !shouldLoop
                if shouldLoop {
                    make.height.equalTo(58)
                } else {
                    make.height.equalTo(0)
                }
            }
            lblIntervalMaximumTime.snp.updateConstraints { make in
                lblIntervalMaximumTime.isHidden = !shouldLoop
                if shouldLoop {
                    make.height.equalTo(24)
                } else {
                    make.height.equalTo(0)
                }
            }
            lblIntervalMinimumTime.snp.updateConstraints { make in
                lblIntervalMinimumTime.isHidden = !shouldLoop
                if shouldLoop {
                    make.height.equalTo(24)
                } else {
                    make.height.equalTo(0)
                }
            }
        case .addToPlaylist:
            let viewController = PlaylistViewController(onlyShowYourLists: true)
            viewController.delegate = self
            if let presentationController = viewController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium()]
            }
            present(viewController, animated: true)
        case .createPlaylist:
            guard let post = postToAdd else { return }
            let viewController = NewPlaylistViewController(post: post)
            if let presentationController = viewController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium()]
            }
            present(viewController, animated: true)
        case .report:
            let alert = UIAlertController(title: "Report this Creator?", message: "The creator is the owner of this app. If you'd like to report this content, please contact Apple Support or Math and Coffee at https://mathandcoffee.com.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        default:
            return
        }
    }
}
