//
//  IntroductionViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 8/17/26.
//

import Foundation
import UIKit

class IntroductionViewController: UIViewController {
    
    private let viewModel: IntroductionViewModel
    private let router: IntroductionRouter
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let vStackView = UIStackView()
    private let iconImageParent = UIView()
    private let iconImageView = UIImageView()
    private let appNameLabel = UILabel()
    private let taglineLabel = UILabel()
    private let continueButton = UIButton()
    
    
    init(viewModel: IntroductionViewModel, router: IntroductionRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
        self.router.introductionViewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make() -> IntroductionViewController {
        let viewModel = IntroductionViewModel()
        let router = IntroductionRouter()
        let viewController = IntroductionViewController(viewModel: viewModel, router: router)
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
        setupIconImage()
        setupAppNameLabel()
        setupTaglineLabel()
        setupContinueButton()
        setupActions()
    }
    
    private func setupScrollView() {
        scrollView.alwaysBounceVertical = true
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
            make.edges.equalToSuperview()
        }
    }
    
    private func setupIconImage() {
        vStackView.addArrangedSubview(iconImageParent)
        
        iconImageView.image = UIImage(resource: .placeholderimage)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.layer.cornerRadius = 20
        iconImageView.clipsToBounds = true
        iconImageParent.addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(250)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupAppNameLabel() {
        appNameLabel.text = "Diary Recorder"
        appNameLabel.font = .roundedFont(ofSize: 27, weight: .semibold)
        appNameLabel.textColor = .label
        appNameLabel.textAlignment = .center
        vStackView.addArrangedSubview(appNameLabel)
        //vStackView.setCustomSpacing(5, after: appNameLabel)
    }
    
    private func setupTaglineLabel() {
        taglineLabel.text = "Your diary, your voice, your world."
        taglineLabel.font = .roundedFont(ofSize: 22, weight: .regular)
        taglineLabel.numberOfLines = 0
        taglineLabel.textColor = .label
        taglineLabel.textAlignment = .center
        vStackView.addArrangedSubview(taglineLabel)
        
        vStackView.setCustomSpacing(50, after: taglineLabel)
    }
    
    private func setupContinueButton() {
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.blackAndWhite, for: .normal)
        continueButton.backgroundColor = .reverseMain
        continueButton.titleLabel?.font = .roundedFont(ofSize: 20, weight: .semibold)
        continueButton.layer.cornerRadius = 20
        
        view.addSubview(continueButton)
        
        continueButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(50)
        }
    }
    
    private func setupActions() {
        let continueButtonActionId = UIAction.Identifier("continueButtonActionId")
        let continueButtonAction = UIAction(identifier: continueButtonActionId) { [unowned self] _ in
            self.router.navigateToNeedPassword()
        }
        
        continueButton.removeAction(continueButtonAction, for: .touchUpInside)
        continueButton.addAction(continueButtonAction, for: .touchUpInside)
    }
    
    
}
