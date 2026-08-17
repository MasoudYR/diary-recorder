//
//  ContactUsViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 8/6/26.
//

import Foundation
import UIKit

class ContactUsViewController: UIViewController {
    
    private let viewModel: ContactUsViewModel
    private let router: ContactUsRouter
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let vStackView = UIStackView()
    private let explanationParentView = UIView()
    private let explanationLabel = UILabel()
    private let developerParentView = UIView()
    private let developerTilteLabel = UILabel()
    private let developerNameLabel = UILabel()
    private let emailParentView = UIView()
    private let emailButton = ContactUsButton()
    private let linkedInParentView = UIView()
    private let linkedInButton = ContactUsButton()
    private let telegramParentView = UIView()
    private let telegramButton = ContactUsButton()
    
    init(viewModel: ContactUsViewModel, router: ContactUsRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
        self.router.contactUsViewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make() -> ContactUsViewController {
        let viewModel = ContactUsViewModel()
        let router = ContactUsRouter()
        let viewController = ContactUsViewController(viewModel: viewModel, router: router)
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationbarUI()
        setupUI()
    }
    
    private func setupNavigationbarUI() {
        navigationItem.title = "Contact us"
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.roundedFont(ofSize: 25, weight: .semibold)
        ]
        
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.standardAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance
        
        navigationItem.backButtonTitle = ""
    }
    
    private func setupUI() {
        view.backgroundColor = .main
        setupScrollView()
        setupContentView()
        setupVStackView()
        setupExplnationViews()
        setupDeveloperViews()
        setupEmailViews()
        setupLinkedInViews()
        setupTelegramViews()
        setupActions()
    }
    
    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        
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
    
    private func setupExplnationViews() {
//        explanationParentView.backgroundColor = .main
//        explanationParentView.layer.cornerRadius = 20
//        explanationParentView.layer.borderWidth = 2
//        explanationParentView.layer.borderColor = UIColor.presentViewsContents.cgColor
//        
        vStackView.addArrangedSubview(explanationParentView)
        
        explanationLabel.text = """
            Diary Recorder is developed and maintained by Masoud Yazdanirad.
            If you have any questions, feedback, or need support regarding the app, its features, privacy policy, or terms of service, please feel free to contact us using one of the methods below.
            """
        explanationLabel.font = .roundedFont(ofSize: 19, weight: .regular)
        explanationLabel.textColor = .label
        explanationLabel.numberOfLines = 0
        explanationLabel.textAlignment = .left
        
        explanationParentView.addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupDeveloperViews() {
        developerParentView.backgroundColor = .presentViewsContents
        developerParentView.layer.cornerRadius = 20
        
        vStackView.addArrangedSubview(developerParentView)
        
        developerTilteLabel.text = "Developer"
        developerTilteLabel.font = .roundedFont(ofSize: 18, weight: .medium)
        developerTilteLabel.textColor = .systemGray
        developerTilteLabel.textAlignment = .left
        
        developerParentView.addSubview(developerTilteLabel)
        
        developerTilteLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.horizontalEdges.equalToSuperview().inset(15)
        }
        
        developerNameLabel.text = "Masoud Yazdanirad"
        developerNameLabel.font = .roundedFont(ofSize: 18, weight: .regular)
        developerNameLabel.textColor = .label
        developerNameLabel.textAlignment = .left
        
        developerParentView.addSubview(developerNameLabel)
        
        developerNameLabel.snp.makeConstraints { make in
            make.top.equalTo(developerTilteLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(15)
        }
    }
    
    private func setupEmailViews() {
        emailParentView.backgroundColor = .cyan
        //emailParentView.backgroundColor = .presentViewsContents
        emailParentView.layer.cornerRadius = 20
        
        vStackView.addArrangedSubview(emailParentView)
        
        emailButton.confige(title: "Email", text: "myazdanirad@gmail.com", image: UIImage(resource: .emailblack))
        
        emailParentView.addSubview(emailButton)
        
        emailButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupLinkedInViews() {
        linkedInParentView.backgroundColor = .magenta
        //linkedInParentView.backgroundColor = .presentViewsContents
        linkedInParentView.layer.cornerRadius = 20
        
        vStackView.addArrangedSubview(linkedInParentView)
        
        linkedInButton.confige(title: "LinkedIn", text: "masoud-yazdanirad", image: UIImage(resource: .linkedinblack))
        
        linkedInParentView.addSubview(linkedInButton)
        
        linkedInButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTelegramViews() {
        telegramParentView.backgroundColor = .magenta
        //telegramParentView.backgroundColor = .presentViewsContents
        telegramParentView.layer.cornerRadius = 20
        
        vStackView.addArrangedSubview(telegramParentView)
        
        telegramButton.confige(title: "Telegram", text: "masoudyr", image: UIImage(resource: .telegramblack))
        
        telegramParentView.addSubview(telegramButton)
        
        telegramButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupActions() {
        let emailButtonActionId = UIAction.Identifier("emailButtonActionId")
        let emailButtonAction = UIAction(identifier: emailButtonActionId) { [unowned self] _ in
            print("email action button tapped.")

            self.router.sendEmail()
        }
        
        emailButton.removeAction(identifiedBy: emailButtonActionId, for: .touchUpInside)
        emailButton.addAction(emailButtonAction, for: .touchUpInside)
        
        let linkedInButtonActionId = UIAction.Identifier("linkedInButtonActionId")
        let linkedInButtonAction = UIAction(identifier: linkedInButtonActionId) { [unowned self] _ in
            print("linkedIn action button tapped.")
            let url = URL(string: "https://www.linkedin.com/in/masoud-yazdanirad/")!
            self.router.openURL(url: url)
        }
        
        linkedInButton.removeAction(identifiedBy: linkedInButtonActionId, for: .touchUpInside)
        linkedInButton.addAction(linkedInButtonAction, for: .touchUpInside)
        
        let telegramButtonActionId = UIAction.Identifier("telegramButtonActionId")
        let telegramButtonAction = UIAction(identifier: telegramButtonActionId) { [unowned self] _ in
            print("telegram action button tapped.")
            let url = URL(string: "https://telegram.me/masoudyr")!
            self.router.openURL(url: url)
        }
        
        telegramButton.removeAction(identifiedBy: telegramButtonActionId, for: .touchUpInside)
        telegramButton.addAction(telegramButtonAction, for: .touchUpInside)
    }
}
