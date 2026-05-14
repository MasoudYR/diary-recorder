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
    private let voiceRecorderLabelView = UIView()
    private let voiceRecorderLabel = UILabel()
    private let voiceRecorderImageViewViewView = UIView()
    private let voiceRecorderImageViewView = UIView()
    private let voiceRecorderImageView = UIImageView()
    private let voiceTimerLabelView = UIView()
    private let voiceTimerLabel = UILabel()
    private let voiceDiagramView = UIView()
//    private let voiceDiagramImageView = UIImageView()
    private let waveformLiveView = WaveformLiveView()
    private let buttonsVStackView = UIStackView()
    private let recordButtonView = UIView()
    private let recordButton = UIButton()
    private let pauseButtonView = UIView()
    private let pauseButton = UIButton()
    private let resumeButtonView = UIView()
    private let resumeButton = UIButton()
    private let stopButtonView = UIView()
    private let stopButton = UIButton()
    @objc private let savedDiaryBarButton = UIBarButtonItem()
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
        let savedDiaryBarButton = UIBarButtonItem(
            image: UIImage(systemName: "list.triangle",withConfiguration: largeConfigue),
            style: .plain,
            target: self,
            action: #selector(closeButtonClicked(_:))
        )
        navigationItem.rightBarButtonItem = savedDiaryBarButton
        navigationItem.backButtonTitle = ""
    }
    
    @objc func closeButtonClicked(_ sender: UIBarButtonItem) {
        print("navbutton tapped")
        self.router.navigateToDiaryList()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(vStackView)
        vStackView.axis = .vertical
        vStackView.spacing = 20
        vStackView.distribution = .fill
        vStackView.alignment = .fill
        vStackView.snp.makeConstraints { make in
            //make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
        }
        
        vStackView.addArrangedSubview(voiceRecorderImageViewViewView)
        voiceRecorderImageViewViewView.backgroundColor = .clear
        
        voiceRecorderImageViewViewView.addSubview(voiceRecorderImageViewView)
        voiceRecorderImageViewView.backgroundColor = .label
        voiceRecorderImageViewView.layer.cornerRadius = 100
        voiceRecorderImageViewView.snp.makeConstraints { make in
            make.height.width.equalTo(200)
            make.verticalEdges.equalToSuperview().inset(10)
            make.center.equalToSuperview()
        }
        
        voiceRecorderImageViewView.addSubview(voiceRecorderImageView)
        voiceRecorderImageView.image = UIImage(systemName: "microphone")
        voiceRecorderImageView.layer.cornerRadius = 30
        voiceRecorderImageView.tintColor = .systemBackground
        voiceRecorderImageView.backgroundColor = .clear
        //voiceRecorderImageView.layer.borderWidth = 1
        //voiceRecorderImageView.layer.backgroundColor = UIColor.label.cgColor
        voiceRecorderImageView.snp.makeConstraints { make in
            make.height.width.equalTo(60)
            make.center.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(voiceTimerLabelView)
        voiceTimerLabelView.backgroundColor = .blue
        voiceTimerLabel.snp.makeConstraints { make in
            //make.width.equalTo(200)
        }
        
        voiceTimerLabelView.addSubview(voiceTimerLabel)
        voiceTimerLabel.text = "00:00:00.00"
        voiceTimerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .regular)
        voiceTimerLabel.textAlignment = .center
        voiceTimerLabel.textColor = .label
        voiceTimerLabel.backgroundColor = .red
        voiceTimerLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(voiceDiagramView)
        voiceDiagramView.backgroundColor = .green
        voiceDiagramView.layer.borderWidth = 3
        voiceDiagramView.layer.borderColor = UIColor.systemPink.cgColor
        voiceDiagramView.layer.cornerRadius = 10
        voiceDiagramView.snp.makeConstraints { make in
            make.height.equalTo(120)
            make.width.equalToSuperview()
        }
        
        voiceDiagramView.addSubview(waveformLiveView)
        waveformLiveView.configuration = Waveform.Configuration(
            //size: CGSize(width: 300, height: 100),
            backgroundColor: .systemBackground,
            style: .striped(
                .init(
                    color: .systemRed,
                    width: 2,
                    spacing: 1,
                    lineCap: .round
                )
            ),
            scale: 1.0
        )
        waveformLiveView.shouldDrawSilencePadding = true
        
//        waveformLiveView.waveformView.configuration = Waveform.Configuration(
//            size: CGSize(width: 300, height: 100),
//            backgroundColor: .clear,
//            style: .striped(.init(color: .systemRed, width: 3, spacing: 2, lineCap: .round)),
//            damping: 0.7,
//            scale: 1.0
//        )
//        waveformLiveView.waveformView.highlightColor = .systemRed
        waveformLiveView.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.horizontalEdges.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(recordButtonView)
        recordButtonView.backgroundColor = .green
        
        recordButtonView.addSubview(recordButton)
        recordButton.backgroundColor = .label
        recordButton.setImage(UIImage(systemName: "circle.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        recordButton.tintColor = .systemRed
        recordButton.layer.cornerRadius = 40
        recordButton.snp.makeConstraints { make in
            make.height.width.equalTo(80)
            make.verticalEdges.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        let recordButtonAction = UIAction { [unowned self]
            _ in
            recordDiary()
            state = .recording
        }
        
        recordButton.addAction(recordButtonAction, for: .touchUpInside)
        
        vStackView.addArrangedSubview(pauseButtonView)
        pauseButtonView.backgroundColor = .purple
        
        pauseButtonView.addSubview(pauseButton)
        pauseButton.backgroundColor = .label
        pauseButton.setTitle("Pause", for: .normal)
        pauseButton.tintColor = .systemBackground
        pauseButton.layer.cornerRadius = 30
        pauseButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo(150)
            make.centerX.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }
        vStackView.setCustomSpacing(10, after: pauseButtonView)
        
        vStackView.addArrangedSubview(resumeButtonView)
        resumeButtonView.backgroundColor = .blue
        
        resumeButtonView.addSubview(resumeButton)
        resumeButton.backgroundColor = .label
        resumeButton.setTitle("Resume", for: .normal)
        resumeButton.tintColor = .systemBackground
        resumeButton.layer.cornerRadius = 30
        resumeButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo(150)
            make.centerX.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }
        vStackView.setCustomSpacing(10, after: resumeButtonView)
        
        vStackView.addArrangedSubview(stopButtonView)
        stopButtonView.backgroundColor = .brown
        
        stopButtonView.addSubview(stopButton)
        stopButton.backgroundColor = .label
        stopButton.setImage(UIImage(systemName: "stop.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        stopButton.tintColor = .systemBackground
        stopButton.layer.cornerRadius = 30
        stopButton.snp.makeConstraints { make in
            make.height.width.equalTo(80)
            make.verticalEdges.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        let stopButtonAction = UIAction { [unowned self]
            _ in
            stopRecordDiary()
            state = .idle
        }
        
        stopButton.addAction(stopButtonAction, for: .touchUpInside)
        
        updateView()
    }
    
    private func bindViewModel() {
        
        viewModel.$timeString
            .receive(on: RunLoop.main)
            .sink { [weak self] timeString in
                guard let self else { return }
                self.voiceTimerLabel.text = timeString
            }
            .store(in: &cancellables)
        
        viewModel.$waveformSamples
            .receive(on: RunLoop.main)
            .sink { [weak self] waveformSamples in
                guard let self else { return }
                let zeroArray: [Float] = .init(repeating: 1.0, count: 999)
                let newWaveformSamples = zeroArray + waveformSamples
                self.waveformLiveView.add(samples: newWaveformSamples)
            }
            .store(in:&cancellables)
    }
    
    private func updateView() {
        switch state {
        case .idle:
            voiceRecorderImageViewView.backgroundColor = .label
            recordButtonView.isHidden = false
            pauseButtonView.isHidden = true
            resumeButtonView.isHidden = true
            stopButtonView.isHidden = true
        case .recording:
            voiceRecorderImageViewView.backgroundColor = .systemRed
            recordButtonView.isHidden = true
            pauseButtonView.isHidden = true
            resumeButtonView.isHidden = true
            stopButtonView.isHidden = false
        case .paused:
            voiceRecorderImageViewView.backgroundColor = .systemRed
            recordButtonView.isHidden = true
            pauseButtonView.isHidden = true
            resumeButtonView.isHidden = false
            stopButtonView.isHidden = false
        }
    }
    
    private func recordDiary() {
        viewModel.getAudioPermissionAndStartRecording()
    }
    
    private func stopRecordDiary() {
        viewModel.stopRecording()
        waveformLiveView.reset()
    }
    
    
    
    enum MainState {
        case idle
        case recording
        case paused
    }
    
    
}



