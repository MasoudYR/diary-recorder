//
//  AboutViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 8/2/26.
//

import Foundation
import UIKit

class AboutViewController: UIViewController, UIScrollViewDelegate {
    
    private let viewModel: AboutViewModel
    private let router: AboutRouter
    
    private let kVersion = "CFBundleShortVersionString"
    private let kBuildNumber = "CFBundleVersion"
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let vStackView = UIStackView()
    private let parentIconImageView = UIView()
    private let iconImageView = UIImageView()
    private let appNameLabel = UILabel()
    private let versionLabel = UILabel()
    
    private let abstractParentView = UIView()
    private let abstractLabel = UILabel()
    
    private let whatItDoesParentView = UIView()
    private let whatItDoesTitleLabel = UILabel()
    private let whatItDoesLabel = UILabel()
    
    private let whyOfflineParentView = UIView()
    private let whyOfflineTitleLabel = UILabel()
    private let whyOfflineLabel = UILabel()
    
    private let developerDetailsLabel = UILabel()
    
    init(viewModel: AboutViewModel, router: AboutRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
        self.router.aboutViewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make() -> AboutViewController {
        let viewModel = AboutViewModel()
        let router = AboutRouter()
        let viewController = AboutViewController(viewModel: viewModel, router: router)
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .main
        setupScrollView()
        setupContentView()
        setupVStackView()
        setupIconImageView()
        setupAppNameLabelView()
        setupVersionLabelView()
        setVersionAndBuildNumberValues()
        setupAbstractView()
        setupWhatItDoesView()
        setupWhyOfflineView()
        setupDeveloperDetailsLabel()
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupContentView() {
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }
    }
    
    private func setupVStackView() {
        vStackView.axis = .vertical
        vStackView.distribution = .fill
        vStackView.alignment = .fill
        vStackView.spacing = 20
        vStackView.isLayoutMarginsRelativeArrangement = true
        vStackView.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        contentView.addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
    }
    
    private func setupIconImageView() {
        iconImageView.image = UIImage(resource: .placeholderimage)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.layer.cornerRadius = 20
        iconImageView.layer.masksToBounds = true
        parentIconImageView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(120)
            make.verticalEdges.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(parentIconImageView)
    }
    
    private func setupAppNameLabelView() {
        appNameLabel.text = "Diary Recorder"
        appNameLabel.font = .roundedFont(ofSize: 22, weight: .semibold)
        appNameLabel.textColor = .label
        appNameLabel.textAlignment = .center
        vStackView.addArrangedSubview(appNameLabel)
        vStackView.setCustomSpacing(5, after: appNameLabel)
    }
    
    private func setupVersionLabelView() {
        versionLabel.text = "Version -.-.-(-)"
        versionLabel.font = .roundedFont(ofSize: 18, weight: .regular)
        versionLabel.textColor = .gray
        versionLabel.textAlignment = .center
        vStackView.addArrangedSubview(versionLabel)
        vStackView.setCustomSpacing(30, after: versionLabel)
    }
    
    private func setupAbstractView() {
        abstractParentView.layer.cornerRadius = 20
        abstractLabel.text = "A private, offline app for your voice diary. No account, no cloud, just you."
        abstractLabel.font = .roundedFont(ofSize: 20, weight: .regular)
        abstractLabel.numberOfLines = 0
        abstractLabel.textColor = .label
        abstractLabel.textAlignment = .center
        abstractParentView.addSubview(abstractLabel)
        abstractLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(10)
            make.verticalEdges.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(abstractParentView)
    }
    
    private func setupWhatItDoesView() {
        whatItDoesParentView.backgroundColor = .blackAndWhite
        whatItDoesParentView.layer.cornerRadius = 20
        whatItDoesTitleLabel.text = "What it does"
        whatItDoesTitleLabel.font = .roundedFont(ofSize: 18, weight: .semibold)
        whatItDoesTitleLabel.textColor = .gray
        whatItDoesTitleLabel.textAlignment = .left
        whatItDoesParentView.addSubview(whatItDoesTitleLabel)
        whatItDoesTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        whatItDoesLabel.text = "Record a voice diary with a photo, a mood, and a story. Play it back anytime from the calendar, revisit its details, or share it through the share sheet. It always stays on this device unless you choose to share it."
        whatItDoesLabel.font = .roundedFont(ofSize: 18, weight: .regular)
        whatItDoesLabel.numberOfLines = 0
        whatItDoesLabel.textColor = .label
        whatItDoesLabel.textAlignment = .left
        whatItDoesParentView.addSubview(whatItDoesLabel)
        whatItDoesLabel.snp.makeConstraints { make in
            make.top.equalTo(whatItDoesTitleLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
        vStackView.addArrangedSubview(whatItDoesParentView)
    }
    
    private func setupWhyOfflineView() {
        whyOfflineParentView.backgroundColor = .blackAndWhite
        whyOfflineParentView.layer.cornerRadius = 20
        whyOfflineTitleLabel.text = "Why offline"
        whyOfflineTitleLabel.font = .roundedFont(ofSize: 18, weight: .semibold)
        whyOfflineTitleLabel.textColor = .gray
        whyOfflineTitleLabel.textAlignment = .left
        whyOfflineParentView.addSubview(whyOfflineTitleLabel)
        whyOfflineTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        whyOfflineLabel.text = "No account, no servers, no tracking. Your diary stays only on your device, and only you decide when to share it."
        whyOfflineLabel.font = .roundedFont(ofSize: 18, weight: .regular)
        whyOfflineLabel.numberOfLines = 0
        whyOfflineLabel.textColor = .label
        whyOfflineLabel.textAlignment = .left
        whyOfflineParentView.addSubview(whyOfflineLabel)
        whyOfflineLabel.snp.makeConstraints { make in
            make.top.equalTo(whyOfflineTitleLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
        vStackView.addArrangedSubview(whyOfflineParentView)
        vStackView.setCustomSpacing(40, after: whyOfflineParentView)
    }
    
    private func setupDeveloperDetailsLabel() {
        developerDetailsLabel.text = """
            Made by Masoud Yazdanirad
            2026
            """
        developerDetailsLabel.font = .roundedFont(ofSize: 18, weight: .regular)
        developerDetailsLabel.numberOfLines = 2
        developerDetailsLabel.textColor = .gray
        developerDetailsLabel.textAlignment = .center
        vStackView.addArrangedSubview(developerDetailsLabel)
    }
    
    private func setVersionAndBuildNumberValues() {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary[kVersion] as! String
        let buildNumber = dictionary[kBuildNumber] as! String
        versionLabel.text = "Version \(version) (\(buildNumber))"
    }
}
