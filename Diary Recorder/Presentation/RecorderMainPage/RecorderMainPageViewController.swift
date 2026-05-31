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

    
    private var state: MainState = .idle {
        didSet {
            updateView()
        }
    }
    
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
        let viewModel = RecorderMainPageViewModel()
        let viewController = RecorderMainPageViewController(viewModel: viewModel, router: router)
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemRed
        navigationBarSetupUI()
        setupUI()
        bindViewModel()
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
        let recordButtonAction = UIAction { [unowned self]
            _ in
            viewModel.startRecording()
            state = .recording
            print("##### Record Button tapped")
        }
        
        recordButton.addAction(recordButtonAction, for: .touchUpInside)
        
        let pauseButtonAction = UIAction { [unowned self]
            _ in
            if viewModel.isRecording {
                viewModel.pauseRecording()
                state = .paused
                print("##### Pause Button tapped")
            } else {
                print("there is no recording to pause")
            }
        }
        
        pauseButton.addAction(pauseButtonAction, for: .touchUpInside)
        
        let resumeButtonAction = UIAction { [unowned self]
            _ in
            
            if viewModel.isPaused {
                viewModel.resumeRecording()
                state = .recording
                print("##### Resume Button tapped")
            }
        }
        
        resumeButton.addAction(resumeButtonAction, for: .touchUpInside)
        
        let stopButtonAction = UIAction { [unowned self]
            _ in
            viewModel.stopRecording()
            guard let lastSavedDiary = viewModel.lastSavedDiary else { return }
            let nameCurrentValueSubject = viewModel.nameCurrentValueSubject
            state = .idle
            waveformLiveView.reset()
            print("##### Stop Button tapped")
            router.navigateToNameDiary(lastSavedDiary: lastSavedDiary, nameCurrentValueSubject: nameCurrentValueSubject)
        }
        
        stopButton.addAction(stopButtonAction, for: .touchUpInside)
    }
    
    private func bindViewModel() {
        
        viewModel.$timeString
            .receive(on: RunLoop.main)
            .sink { [weak self] timeString in
                guard let self else { return }
                self.voiceTimerLabel.text = timeString
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
        recordButton.isHidden = !(state == .idle)
        pauseButton.isHidden = !(state == .recording)
        resumeButton.isHidden = !(state == .paused)
        stopButton.isHidden = !(state == .recording)
        
        if state == .recording || state == .paused {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = savedDiaryBarButton
        }
        
        if state == .idle || state == .paused {
            voiceRecorderImageViewView.backgroundColor = .label
        } else {
            voiceRecorderImageViewView.backgroundColor = .systemRed
        }
    }
    
    enum MainState {
        case idle
        case recording
        case paused
    }
    
    
}



