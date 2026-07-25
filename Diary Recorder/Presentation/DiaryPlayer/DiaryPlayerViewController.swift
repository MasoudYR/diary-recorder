//
//  DiaryPlayerViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 5/13/26.
//

import Foundation
import UIKit
import SnapKit
import Combine
import AVFAudio

class DiaryPlayerViewController: UIViewController, UIScrollViewDelegate {
    
    private let viewModel: DiaryPlayerViewModel
    private let router: DiaryPlayerRouter
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let vStackView = UIStackView()
    private let hStackView = UIStackView()
    
    private let diaryImageView = UIImageView()
    
    private let detailsView = UIView()
    private let nameLabel = UILabel()
    private let dateLabel = UILabel()
    private let emojiImageView = UIImageView()
    
    private let progressSliderView = UIView()
    private let progressSlider = UISlider()
    private let minimumTrackTimeLabel = UILabel()
    private let maximumTrackTimeLabel = UILabel()
    private let buttonsGroupView = UIView()
    private let buttonsVStackView = UIStackView()
    private let playButton = UIButton()
    private let pauseButton = UIButton()
    private let stopButton = UIButton()
    private let seekForwardSecondsButton = UIButton()
    private let seekBackwardSecondsButton = UIButton()
    private let nextButton = UIButton()
    private let previousButton = UIButton()
    
    private let diaryTextLabelView = UIView()
    private let diaryTextLabel = UILabel()
    
    private var progressTimer: Timer?

    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: DiaryPlayerViewModel, router: DiaryPlayerRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
        self.router.diaryPlayerViewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            print(">>>", Self.self, #function, "session setActive: false.")
        } catch {
            print(">>>", Self.self, #function, "error: \(error)")
        }
    }
    
    static func make(diaryIndex: Int, diaryListDataCollection: [RecordingFileDetails] ) -> DiaryPlayerViewController {
        let viewModel = DiaryPlayerViewModel(diaryIndex: diaryIndex, diaryListDataCollection: diaryListDataCollection)
        let router = DiaryPlayerRouter()
        let diaryPlayerViewController = DiaryPlayerViewController(viewModel: viewModel, router: router)
        return diaryPlayerViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.prepareToPlay()
        viewModel.play(viewModel.currentlyPlaying)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.audioPlayerService.stop()
        viewModel.audioPlayerService.deactiveAudioSession()
    }
    
    func setupUI() {
        view.backgroundColor = .main
        setupScrollView()
        setupContentView()
        setupViewsMainStackView()
        setupDiaryImageView()
        setupViewsDetailsView()
        setupViewsSliderView()
        setupViewsButtonsGroupView()
        setupViewsButtonsGroupStackViewArrangedSubviews()
        diaryTextView()
        setupActions()
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.bounces = false
        
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupContentView() {
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(view)
        }
    }
    
    private func setupViewsMainStackView() {
        vStackView.axis = .vertical
        vStackView.spacing = 10
        vStackView.alignment = .fill
        vStackView.distribution = .fill
        vStackView.isLayoutMarginsRelativeArrangement = true
        vStackView.layoutMargins = .init(top: 25, left: 15, bottom: 15, right: 15)
        
        contentView.addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupDiaryImageView() {
        diaryImageView.layer.cornerRadius = 20
        diaryImageView.contentMode = .scaleAspectFit
        diaryImageView.clipsToBounds = true
        
        contentView.addSubview(diaryImageView)
        
        diaryImageView.snp.makeConstraints { make in
            make.size.equalTo(80)
        }
        
        vStackView.addArrangedSubview(diaryImageView)
    }
    
    private func setupViewsDetailsView() {
        nameLabel.text = "Name: No Name"
        nameLabel.font = .roundedFont(ofSize: 20, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .left
        nameLabel.numberOfLines = 0
        
        dateLabel.text = "Date: 2026-01-01 10:10:10"
        dateLabel.font = .roundedFont(ofSize: 17, weight: .regular)
        dateLabel.textColor = .secondaryLabel
        dateLabel.textAlignment = .left
        dateLabel.numberOfLines = 0
        
        let textsStackView = UIStackView()
        textsStackView.axis = .vertical
        textsStackView.alignment = .fill
        textsStackView.distribution = .fill
        textsStackView.spacing = 5
        textsStackView.isLayoutMarginsRelativeArrangement = true
        textsStackView.addArrangedSubview(nameLabel)
        textsStackView.addArrangedSubview(dateLabel)
        
        detailsView.addSubview(textsStackView)
        
        textsStackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.left.equalToSuperview().inset(10)
        }
        
        emojiImageView.image = UIImage(resource: .pokerface)
        emojiImageView.contentMode = .scaleAspectFit
        
        detailsView.addSubview(emojiImageView)
        
        emojiImageView.snp.makeConstraints { make in
            make.size.equalTo(60)
            make.top.equalToSuperview()
            make.right.equalToSuperview().inset(10)
            make.left.equalTo(textsStackView.snp.right).offset(10)
        }
    
        vStackView.addArrangedSubview(detailsView)
    }
    
    private func setupViewsSliderView() {
        progressSliderView.backgroundColor = .clear
        
        progressSlider.value = 0.0
        progressSlider.minimumValue = 0.0
        progressSlider.maximumValue = 1.0
        progressSlider.preferredBehavioralStyle = .automatic
        progressSlider.isContinuous = true
        progressSlider.setThumbImage(UIImage(systemName: "music.note"), for: .normal)
        progressSlider.tintColor = .systemPink
        
        progressSliderView.addSubview(progressSlider)
        progressSlider.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(25)
        }
        
        minimumTrackTimeLabel.text = viewModel.minimumTrackTimeString
        minimumTrackTimeLabel.font = .systemFont(ofSize: 10)
        minimumTrackTimeLabel.textColor = .label
        minimumTrackTimeLabel.textAlignment = .left
        
        progressSliderView.addSubview(minimumTrackTimeLabel)
        minimumTrackTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(progressSliderView.snp.bottom).offset(-25)
            make.left.equalTo(progressSliderView.snp.left).inset(5)
        }
        
        maximumTrackTimeLabel.text = viewModel.maximumTrackTimeString
        maximumTrackTimeLabel.font = .systemFont(ofSize: 10)
        maximumTrackTimeLabel.textColor = .label
        maximumTrackTimeLabel.textAlignment = .right
        
        progressSliderView.addSubview(maximumTrackTimeLabel)
        maximumTrackTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(progressSliderView.snp.bottom).offset(-25)
            make.right.equalTo(progressSliderView.snp.right).inset(5)
        }
        
        vStackView.addArrangedSubview(progressSliderView)
    }
    
    private func setupViewsButtonsGroupView() {
        buttonsGroupView.addSubview(hStackView)
        
        hStackView.axis = .horizontal
        hStackView.spacing = 20
        hStackView.distribution = .fill
        hStackView.alignment = .top
        hStackView.snp.makeConstraints { make in
            make.verticalEdges.centerX.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(buttonsGroupView)
    }
    
    private func setupViewsButtonsGroupStackViewArrangedSubviews() {
        
        nextButton.setImage(UIImage(systemName: "forward.end.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
        nextButton.tintColor = .systemBackground
        nextButton.backgroundColor = .label
        nextButton.layer.cornerRadius = 30
        nextButton.snp.makeConstraints { make in
            make.size.equalTo(60)
        }
        
        seekBackwardSecondsButton.setImage(UIImage(systemName: "5.arrow.trianglehead.counterclockwise",withConfiguration: UIImage.SymbolConfiguration(pointSize: 35)), for: .normal)
        seekBackwardSecondsButton.tintColor = .label
        seekBackwardSecondsButton.layer.cornerRadius = 25
        seekBackwardSecondsButton.snp.makeConstraints { make in
            make.size.equalTo(50)
        }
        
        seekForwardSecondsButton.setImage(UIImage(systemName: "5.arrow.trianglehead.clockwise",withConfiguration: UIImage.SymbolConfiguration(pointSize: 35)), for: .normal)
        seekForwardSecondsButton.tintColor = .label
        seekForwardSecondsButton.layer.cornerRadius = 25
        seekForwardSecondsButton.snp.makeConstraints { make in
            make.size.equalTo(50)
        }
        
        previousButton.setImage(UIImage(systemName: "backward.end.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
        previousButton.tintColor = .systemBackground
        previousButton.backgroundColor = .label
        previousButton.layer.cornerRadius = 30
        previousButton.snp.makeConstraints { make in
            make.size.equalTo(60)
        }
        
        
        hStackView.addArrangedSubview(seekBackwardSecondsButton)
        hStackView.addArrangedSubview(previousButton)
        setupViewsButtonsGroupMiddleGroupViews()
        hStackView.addArrangedSubview(nextButton)
        hStackView.addArrangedSubview(seekForwardSecondsButton)
        
    }
    
    private func setupViewsButtonsGroupMiddleGroupViews() {
        buttonsVStackView.axis = .vertical
        buttonsVStackView.spacing = 5
        buttonsVStackView.distribution = .fill
        buttonsVStackView.alignment = .fill
        
        playButton.setImage(UIImage(systemName: "play.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
        playButton.tintColor = .systemGreen
        playButton.backgroundColor = .label
        playButton.layer.cornerRadius = 30
        playButton.snp.makeConstraints { make in
            make.size.equalTo(60)
        }
        
        pauseButton.setImage(UIImage(systemName: "pause.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
        pauseButton.tintColor = .systemBackground
        pauseButton.backgroundColor = .label
        pauseButton.layer.cornerRadius = 30
        pauseButton.snp.makeConstraints { make in
            make.size.equalTo(60)
        }
        
        stopButton.setImage(UIImage(systemName: "stop.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
        stopButton.tintColor = .systemBackground
        stopButton.backgroundColor = .label
        stopButton.layer.cornerRadius = 30
        stopButton.snp.makeConstraints { make in
            make.size.equalTo(60)
        }
        
        buttonsVStackView.addArrangedSubview(playButton)
        buttonsVStackView.addArrangedSubview(pauseButton)
        buttonsVStackView.addArrangedSubview(stopButton)
        
        hStackView.addArrangedSubview(buttonsVStackView)
    }
    
    private func setupActions() {
        let sliderAction = UIAction { [unowned self] _ in
            viewModel.seek(to: Double(progressSlider.value))
        }
        
        progressSlider.addAction(sliderAction, for: .valueChanged)
        
        let playAction = UIAction { [unowned self] _ in
//            guard let diary = viewModel.currentlyPlaying else { return }
            viewModel.play(viewModel.currentlyPlaying)
        }
        let playActionId = UIAction.Identifier("playActionId")
        playButton.removeAction(identifiedBy: playActionId, for: .touchUpInside)
        playButton.addAction(playAction, for: .touchUpInside)
        
        
        let pauseAction = UIAction { [unowned self] _ in
            viewModel.pause()
        }
        
        let pauseActionId = UIAction.Identifier("pauseActionId")
        pauseButton.removeAction(identifiedBy: pauseActionId, for: .touchUpInside)
        pauseButton.addAction(pauseAction, for: .touchUpInside)
    
        let stopAction = UIAction { [unowned self] _ in
            viewModel.stop()
        }
        
        let stopActionId = UIAction.Identifier("stopActionId")
        stopButton.removeAction(identifiedBy: stopActionId, for: .touchUpInside)
        stopButton.addAction(stopAction, for: .touchUpInside)
        
        let seekForwardSecondsActionId = UIAction.Identifier("seekForwardSecondsActionId")
        
        let seekForwardSecondsAction = UIAction { [unowned self] _ in
            viewModel.seekForward(to: 5)
        }
        seekForwardSecondsButton.removeAction(identifiedBy: seekForwardSecondsActionId, for: .touchUpInside)
        seekForwardSecondsButton
            .addAction(seekForwardSecondsAction, for: .touchUpInside)
        
        let seekBackwardSecondsActionId = UIAction.Identifier("seekBackwardSecondsActionId")
        
        let seekBackwardSecondsAction = UIAction { [unowned self] _ in
            viewModel.seekBackward(to: 5)
        }
        seekBackwardSecondsButton.removeAction(identifiedBy: seekBackwardSecondsActionId, for: .touchUpInside)
        seekBackwardSecondsButton
            .addAction(seekBackwardSecondsAction, for: .touchUpInside)
        
        let nextDiaryActionId = UIAction.Identifier("nextDiaryActionId")
        
        let nextDiaryAction = UIAction { [unowned self] _ in
            viewModel.playNextDiary()
        }
        nextButton.removeAction(identifiedBy: nextDiaryActionId, for: .touchUpInside)
        nextButton
            .addAction(nextDiaryAction, for: .touchUpInside)
        
        
        let previousDiaryActionId = UIAction.Identifier("previousDiaryActionId")
        
        let previousDiaryAction = UIAction { [unowned self] _ in
            viewModel.playPreviousDiary()
        }
        previousButton.removeAction(identifiedBy: previousDiaryActionId, for: .touchUpInside)
        previousButton
            .addAction(previousDiaryAction, for: .touchUpInside)
    }
    
    private func diaryTextView() {
        diaryTextLabelView.backgroundColor = .systemBackground
        diaryTextLabelView.layer.cornerRadius = 20
        
        diaryTextLabel.text = ""
        diaryTextLabel.font = .roundedFont(ofSize: 17, weight: .regular)
        diaryTextLabel.textColor = .label
        diaryTextLabel.numberOfLines = 0
        diaryTextLabel.textAlignment = .left
        
        diaryTextLabelView.addSubview(diaryTextLabel)
        
        diaryTextLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        
        vStackView.addArrangedSubview(diaryTextLabelView)
    }
    
    private func bindViewModel() {
        viewModel.$currentlyPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentlyPlaying in
                guard let self else { return }
                self.diaryImageView.image = viewModel.getImageOfDiary(diary: currentlyPlaying)
                self.nameLabel.text = currentlyPlaying.name
                self.dateLabel.text = viewModel.changeDateAndTime(currentlyPlaying.date)
                self.emojiImageView.image = viewModel.getEmojiOfDiary(diary: currentlyPlaying)
//                if !currentlyPlaying.text.isEmpty {
//                    self.diaryTextLabelView.isHidden = false
//                    self.diaryTextLabel.text = currentlyPlaying.text
//                } else {
//                    self.diaryTextLabelView.isHidden = true
//                }
                self.diaryTextLabel.text = currentlyPlaying.text
                print("~~~~~~~~~~", currentlyPlaying.text)
                
            }
            .store(in: &cancellables)
        
        viewModel.$currentTime
            .combineLatest(viewModel.$duration)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] current, total in
                guard let self, total > 0 else { return }
                
                let progress = Float(current / total)
                self.progressSlider.value = progress
            }
            .store(in: &cancellables)
        
        viewModel
            .audioPlayerService
            .$playingStateDescriptor
            .compactMap { $0 }
            .map(\.playingState)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .idle:
                    playButton.isHidden = false
                    pauseButton.isHidden = true
                    stopButton.isHidden = true
                case .playing:
                    playButton.isHidden = true
                    pauseButton.isHidden = false
                    stopButton.isHidden = false
                case .paused:
                    playButton.isHidden = false
                    pauseButton.isHidden = true
                    stopButton.isHidden = true
                case .finished:
                    playButton.isHidden = false
                    pauseButton.isHidden = true
                    stopButton.isHidden = true
                }
//                playButton.isHidden = !(state == .idle || state == .paused)
//                pauseButton.isHidden = !(state == .playing)
//                stopButton.isHidden = !(state == .paused || state == .playing)
            }
            .store(in: &cancellables)
        
        viewModel.$minimumTrackTimeString
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self else { return }
                self.minimumTrackTimeLabel.text = text
            }
            .store(in: &cancellables)
        
        viewModel.$maximumTrackTimeString
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self else { return }
                self.maximumTrackTimeLabel.text = text
            }
            .store(in: &cancellables)
    }
}

