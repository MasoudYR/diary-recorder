//
//  RecorderMainPageViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 5/9/26.
//
import Foundation
import UIKit
import SnapKit
import Combine
import DSWaveformImageViews
import DSWaveformImage

class RecorderMainPageViewController: UIViewController {
    private let viewModel: RecorderMainPageViewModel
    private let router: RecorderMainPageRouter
    
    private let vStackView = UIStackView()
    private let voiceRecorderImageViewViewView = UIView()
    private let voiceRecorderImageViewView = UIView()
    private let voiceRecorderImageView = UIImageView()
    private let voiceTimerLabelView = UIView()
    private let voiceTimerLabel = UILabel()
    private let voiceDiagramView = UIView()
    private let waveformLiveView = WaveformLiveView()
    private let buttonsView = UIView()
    private let buttonsVStackView = UIStackView()
    private let recordButton = UIButton()
    private let pauseButton = UIButton()
    private let resumeButton = UIButton()
    private let stopButton = UIButton()
    private var savedDiaryBarButton = UIBarButtonItem()
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: RecorderMainPageViewModel, router: RecorderMainPageRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
        self.router.recorderMainPageViewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make() -> RecorderMainPageViewController {
        let router = RecorderMainPageRouter()
        let viewModel = RecorderMainPageViewModel(
            recordingsDetailsRealmManager: RecordingsDetailsRealmManager.shared,
            audioRecorderService: AudioRecorderService()
        )
        let viewController = RecorderMainPageViewController(viewModel: viewModel, router: router)
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemRed
        navigationBarSetupUI()
        setupUI()
        bindViewModel()
        viewModel.prepareToRecord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.audioRecorderService.setupAudioSession()
    }
    
    private func navigationBarSetupUI() {
        navigationItem.title = "Diary Recorder"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 18)
        ]
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance
        
        let largeConfigue = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        savedDiaryBarButton = UIBarButtonItem(
            image: UIImage(systemName: "list.triangle",withConfiguration: largeConfigue),
            style: .plain,
            target: self,
            action: #selector(diariesListBarButtonTapped(_:))
        )
        navigationItem.rightBarButtonItem = savedDiaryBarButton
        navigationItem.backButtonTitle = ""
    }
    
    @objc func diariesListBarButtonTapped(_ sender: UIBarButtonItem) {
        print("navbutton tapped")
        self.router.navigateToDiaryList()
    }
    
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        setupViewsMainStackView()
        setupVoiceRecorderImageView()
        setupTimerLabelView()
        setupVoiceDiagramView()
        setupViewsButtonsGroupStackView()
        setupActions()
        updateView()
    }
    
    private func setupViewsMainStackView() {
        vStackView.axis = .vertical
        vStackView.spacing = 20
        vStackView.distribution = .fill
        vStackView.alignment = .fill
        vStackView.isLayoutMarginsRelativeArrangement = true
        
        view.addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
    }
    
    private func setupVoiceRecorderImageView() {

        voiceRecorderImageViewView.backgroundColor = .label
        voiceRecorderImageViewView.layer.cornerRadius = 100
        
        voiceRecorderImageViewViewView.addSubview(voiceRecorderImageViewView)
        voiceRecorderImageViewView.snp.makeConstraints { make in
            make.size.equalTo(200)
            make.verticalEdges.equalToSuperview().inset(10)
            make.center.equalToSuperview()
        }
        
        voiceRecorderImageView.image = UIImage(systemName: "microphone")
        voiceRecorderImageView.layer.cornerRadius = 30
        voiceRecorderImageView.tintColor = .systemBackground
        voiceRecorderImageView.backgroundColor = .clear
        
        voiceRecorderImageViewView.addSubview(voiceRecorderImageView)
        voiceRecorderImageView.snp.makeConstraints { make in
            make.height.width.equalTo(60)
            make.center.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(voiceRecorderImageViewViewView)
    }
    
    private func setupTimerLabelView() {
        
        voiceTimerLabel.text = "00:00:00.00"
        voiceTimerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 50, weight: .regular)
        voiceTimerLabel.textAlignment = .center
        voiceTimerLabel.textColor = .label
        
        vStackView.addArrangedSubview(voiceTimerLabel)
    }
    
    private func setupVoiceDiagramView() {
        
        voiceDiagramView.snp.makeConstraints { make in
            make.height.equalTo(120)
        }
        waveformLiveView.shouldDrawSilencePadding = true
        waveformLiveView.configuration = Waveform.Configuration(
            backgroundColor: .systemBackground,
            style: .striped(
                .init(
                    color: .systemRed,
                    width: 1,
                    spacing: 2,
                    lineCap: .round
                )
            ),
            scale: 1.0
        )
        
        voiceDiagramView.addSubview(waveformLiveView)
        waveformLiveView.snp.makeConstraints { make in
            make.height.equalToSuperview().inset(10)
            make.horizontalEdges.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(voiceDiagramView)
    }
    
    private func setupViewsButtonsGroupStackView() {
        buttonsVStackView.axis = .vertical
        buttonsVStackView.spacing = 5
        buttonsVStackView.distribution = .fill
        buttonsVStackView.alignment = .fill
        
        recordButton.backgroundColor = .label
        recordButton.setImage(UIImage(systemName: "circle.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        recordButton.tintColor = .systemRed
        recordButton.layer.cornerRadius = 40
        
        recordButton.snp.makeConstraints { make in
            make.size.equalTo(80)
        }
        
        pauseButton.backgroundColor = .label
        pauseButton.setImage(UIImage(systemName: "pause.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        pauseButton.tintColor = .systemBackground
        pauseButton.layer.cornerRadius = 40
        
        
        pauseButton.snp.makeConstraints { make in
            make.size.equalTo(80)
        }
        
        resumeButton.backgroundColor = .label
        resumeButton.setImage(UIImage(systemName: "circle.righthalf.filled.inverse",withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        resumeButton.tintColor = .systemRed
        resumeButton.layer.cornerRadius = 40
        
        
        resumeButton.snp.makeConstraints { make in
            make.size.equalTo(80)
        }
        
        stopButton.backgroundColor = .label
        stopButton.setImage(UIImage(systemName: "stop.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        stopButton.tintColor = .systemBackground
        stopButton.layer.cornerRadius = 40
        
        stopButton.snp.makeConstraints { make in
            make.size.equalTo(80)
        }
        
        buttonsView.addSubview(buttonsVStackView)
        buttonsVStackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        buttonsVStackView.addArrangedSubview(recordButton)
        buttonsVStackView.addArrangedSubview(pauseButton)
        buttonsVStackView.addArrangedSubview(resumeButton)
        buttonsVStackView.addArrangedSubview(stopButton)
        
        vStackView.addArrangedSubview(buttonsView)
    }

    private func setupActions() {
        let recordButtonActionId = UIAction.Identifier("recordButtonActionId")
        let recordButtonAction = UIAction(identifier: recordButtonActionId) { [unowned self]
            _ in
            viewModel.startRecording()
            print("##### Record Button tapped")
        }
        
        recordButton.removeAction(identifiedBy: recordButtonActionId, for: .touchUpInside)
        recordButton.addAction(recordButtonAction, for: .touchUpInside)
        
        let pauseButtonActionId = UIAction.Identifier("pauseButtonActionId")
        let pauseButtonAction = UIAction(identifier: pauseButtonActionId) { [unowned self]
            _ in
            viewModel.pauseRecording()
        }
        
        pauseButton.removeAction(identifiedBy: pauseButtonActionId, for: .touchUpInside)
        pauseButton.addAction(pauseButtonAction, for: .touchUpInside)
        
        
        let resumeButtonActionId = UIAction.Identifier("resumeButtonActionId")
        let resumeButtonAction = UIAction(identifier: resumeButtonActionId) { [unowned self]
            _ in
            viewModel.resumeRecording()
        }
        
        resumeButton.removeAction(identifiedBy: resumeButtonActionId, for: .touchUpInside)
        resumeButton.addAction(resumeButtonAction, for: .touchUpInside)
        
        let stopButtonActionId = UIAction.Identifier("stopButtonActionId")
        let stopButtonAction = UIAction(identifier: stopButtonActionId) { [unowned self]
            _ in
            viewModel.stopRecording()
            viewModel.saveRecording()
            print("lastSavedDiaryInViewController: \(String(describing: viewModel.lastSavedDiary))")
            waveformLiveView.reset()
            guard let lastSavedDiary = viewModel.lastSavedDiary else { return }
            
            let nameCurrentValueSubject = viewModel.nameCurrentValueSubject
            print("##### Stop Button tapped")
            router.navigateToNameDiary(lastSavedDiary: lastSavedDiary, nameCurrentValueSubject: nameCurrentValueSubject)
        }
        
        stopButton.removeAction(identifiedBy: stopButtonActionId, for: .touchUpInside)
        stopButton.addAction(stopButtonAction, for: .touchUpInside)
    }
    
    private func bindViewModel() {
        
        viewModel
            .audioRecorderService
            .$recordingStateDescriptor
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                guard let self else { return }
                self.voiceTimerLabel.text = viewModel.transformTime(item.currentTime)
                
                recordButton.isHidden =
                item.recordingState == .recording ||
                item.recordingState == .paused
                
                pauseButton.isHidden =
                item.recordingState == .idle ||
                item.recordingState == .paused ||
                item.recordingState == .finished
                
                resumeButton.isHidden =
                item.recordingState == .idle ||
                item.recordingState == .recording ||
                item.recordingState == .finished
                
                stopButton.isHidden =
                item.recordingState == .idle ||
                item.recordingState == .paused ||
                item.recordingState == .finished
                
                navigationItem.rightBarButtonItem =
                item.recordingState == .recording ||
                item.recordingState == .paused
                ? nil : savedDiaryBarButton
                
                voiceRecorderImageViewView.backgroundColor =
                item.recordingState == .idle ||
                item.recordingState == .paused ||
                item.recordingState == .finished
                ? .label : .systemRed
            }
            .store(in: &cancellables)
        
        viewModel.audioRecorderService.$latestSample
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sample in
                guard let self else { return }
                self.waveformLiveView.add(sample: sample)
            }
            .store(in: &cancellables)
    }
    
    private func updateView() {
    }
}



