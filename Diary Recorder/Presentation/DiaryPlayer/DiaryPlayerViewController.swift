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

class DiaryPlayerViewController: UIViewController {
    
    private let viewModel: DiaryPlayerViewModel
    private let router: DiaryPlayerRouter
    
    private let vStackView = UIStackView()
    private let hStackView = UIStackView()
    private let detailsView = UIView()
    private let nameLabel = UILabel()
    private let dateLabel = UILabel()
    private let progressSliderView = UIView()
    private let progressSlider = UISlider()
    private let buttonsGroupView = UIView()
    private let buttonsVStackView = UIStackView()
    private let playButton = UIButton()
    private let pauseButton = UIButton()
    private let stopButton = UIButton()
    private let plus15secondsButton = UIButton()
    private let minus15secondsButton = UIButton()
    
    private var progressTimer: Timer?
    
    init(viewModel: DiaryPlayerViewModel, router: DiaryPlayerRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
        self.router.diaryPlayerViewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make() -> DiaryPlayerViewController {
        let viewModel = DiaryPlayerViewModel()
        let router = DiaryPlayerRouter()
        let diaryPlayerViewController = DiaryPlayerViewController(viewModel: viewModel, router: router)
        return diaryPlayerViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        setupViewsMainStackView()
        setupViewsDetailsView()
        setupViewsSliderView()
        setupViewsButtonsGroupView()
        setupViewsButtonsGroupStackViewArrangedSubviews()
    }
    
    private func setupViewsMainStackView() {
        vStackView.axis = .vertical
        vStackView.spacing = 10
        vStackView.alignment = .fill
        vStackView.distribution = .fill
        vStackView.isLayoutMarginsRelativeArrangement = true
        
        view.addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
    }
    
    private func setupViewsDetailsView() {
        nameLabel.text = "Name: No Name"
        nameLabel.font = .systemFont(ofSize: 18)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .left
        nameLabel.numberOfLines = 0
        
        dateLabel.text = "Date: 2026-01-01 10:10:10"
        dateLabel.font = .systemFont(ofSize: 18)
        dateLabel.textColor = .label
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
            make.edges.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(detailsView)
    }
    
    private func setupViewsSliderView() {
        progressSliderView.backgroundColor = .clear
        
        progressSlider.value = 0
        progressSlider.minimumValue = 0
        progressSlider.preferredBehavioralStyle = .automatic
        progressSlider.isContinuous = true
        progressSlider.thumbTintColor = .systemBlue
        progressSlider.tintColor = .systemPink
        
        progressSliderView.addSubview(progressSlider)
        progressSlider.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
        
        vStackView.addArrangedSubview(progressSliderView)
    }
    
    private func setupViewsButtonsGroupView() {
        buttonsGroupView.addSubview(hStackView)
        
        hStackView.axis = .horizontal
        hStackView.spacing = 20
        hStackView.distribution = .fill
        hStackView.alignment = .center
        hStackView.snp.makeConstraints { make in
            make.verticalEdges.centerX.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(buttonsGroupView)
    }
    
    private func setupViewsButtonsGroupStackViewArrangedSubviews() {
        minus15secondsButton.setImage(UIImage(systemName: "15.arrow.trianglehead.counterclockwise",withConfiguration: UIImage.SymbolConfiguration(pointSize: 35)), for: .normal)
        minus15secondsButton.tintColor = .label
        minus15secondsButton.layer.cornerRadius = 25
        minus15secondsButton.snp.makeConstraints { make in
            make.size.equalTo(50)
        }
        
        plus15secondsButton.setImage(UIImage(systemName: "15.arrow.trianglehead.clockwise",withConfiguration: UIImage.SymbolConfiguration(pointSize: 35)), for: .normal)
        plus15secondsButton.tintColor = .label
        plus15secondsButton.layer.cornerRadius = 25
        plus15secondsButton.snp.makeConstraints { make in
            make.size.equalTo(50)
        }
        
        hStackView.addArrangedSubview(minus15secondsButton)
        setupViewsButtonsGroupMiddleGroupViews()
        hStackView.addArrangedSubview(plus15secondsButton)
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
    
}

