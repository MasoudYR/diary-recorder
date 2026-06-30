//
//  AlertViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 6/30/26.
//

import Foundation
import UIKit
import Combine

class AlertViewController: UIViewController {
    
    private let vStackView = UIStackView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let parentOkButton = UIView()
    private let okButton = UIButton()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make() -> AlertViewController {
        let viewController = AlertViewController()
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.custom { _ in 180 }]
            sheet.preferredCornerRadius = 20
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupVStackView()
        setupTitleLabel()
        setupMessageLabel()
        setupOkButton()
        setupActions()
    }
    
    private func setupVStackView() {
        vStackView.axis = .vertical
        vStackView.spacing = 10
        vStackView.distribution = .fill
        vStackView.alignment = .fill
        vStackView.isLayoutMarginsRelativeArrangement = true
        vStackView.layoutMargins = .init(top: 30, left: 30, bottom: 15, right: 30)
        
        view.addSubview(vStackView)
        
        vStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
    }
    
    private func setupTitleLabel() {
        titleLabel.font = .roundedFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        vStackView.addArrangedSubview(titleLabel)
    }
    
    private func setupMessageLabel() {
        messageLabel.font = .roundedFont(ofSize: 18, weight: .regular)
        messageLabel.textColor = .label
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        vStackView.addArrangedSubview(messageLabel)
        vStackView.setCustomSpacing(25, after: messageLabel)
    }
    
    private func setupOkButton() {
        okButton.setTitle("OK", for: .normal)
        okButton.setTitleColor(.label, for: .normal)
        okButton.titleLabel?.font = .roundedFont(ofSize: 18, weight: .medium)
        okButton.layer.cornerRadius = 20
        okButton.backgroundColor = .main
        
        parentOkButton.addSubview(okButton)
        okButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(100)
        }
        
        vStackView.addArrangedSubview(parentOkButton)
    }
    
    private func setupActions() {
        let okButtonActionID = UIAction.Identifier("okButtonActionId")
        let okButtonAction = UIAction { [weak self] _ in
            guard let self else { return }
            print("ok button tapped")
            self.dismiss(animated: true)
        }
        
        okButton.removeAction(identifiedBy: okButtonActionID, for: .touchUpInside)
        okButton.addAction(okButtonAction, for: .touchUpInside)
    }
    
    func config(title: String, message: String) {
        titleLabel.text = title
        messageLabel.text = message
    }
    
}
