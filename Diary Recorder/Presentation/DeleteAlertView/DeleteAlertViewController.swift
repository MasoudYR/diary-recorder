//
//  DeleteAlertViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 5/17/26.
//

import Foundation
import UIKit
import SnapKit

class DeleteAlertViewController: UIViewController {
    
    private let deleteTitle: String
    private let deleteMessage: String
    
    private let vStackView = UIStackView()
    private let parentDeleteIconImageView = UIView()
    private let deleteIconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let deleteMessageLabel = UILabel()
    private let buttonsHStackView = UIStackView()
    private let yesButton = UIButton()
    private let noButton = UIButton()
    private let deleteAction: () -> Void
    
    init(title: String, message: String, deleteAction: @escaping () -> Void) {
        self.deleteAction = deleteAction
        self.deleteTitle = title
        self.deleteMessage = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make(title: String, message: String, deleteHandler: @escaping () -> Void) -> DeleteAlertViewController {
        let viewController = DeleteAlertViewController(title: title, message: message, deleteAction: deleteHandler)
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.custom { _ in 220 }]
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
        view.backgroundColor = .main
        setupVStackView()
        setupImageIconView()
        setupDeleteMessageLabels()
        setupButtonsHStackView()
        setupYesAndNoButtons()
        buttonActions()
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
    
    private func setupImageIconView() {
        deleteIconImageView.image = UIImage(systemName: "trash")
        deleteIconImageView.tintColor = .label
        
        parentDeleteIconImageView.addSubview(deleteIconImageView)
        
        deleteIconImageView.snp.makeConstraints { make in
            make.size.equalTo(30)
            make.center.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(parentDeleteIconImageView)
    }
    
    private func setupDeleteMessageLabels() {
        titleLabel.text = deleteTitle
        titleLabel.font = .roundedFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        
        vStackView.addArrangedSubview(titleLabel)
        
        deleteMessageLabel.text = deleteMessage
        deleteMessageLabel.font = .roundedFont(ofSize: 18, weight: .regular)
        deleteMessageLabel.textColor = .label
        deleteMessageLabel.textAlignment = .center
        deleteMessageLabel.numberOfLines = 0
        
        vStackView.addArrangedSubview(deleteMessageLabel)
        vStackView.setCustomSpacing(25, after: deleteMessageLabel)
    }
    
    private func setupButtonsHStackView() {
        buttonsHStackView.axis = .horizontal
        buttonsHStackView.spacing = 40
        buttonsHStackView.distribution = .fillEqually
        buttonsHStackView.alignment = .fill
        
        vStackView.addArrangedSubview(buttonsHStackView)
    }
    
    private func setupYesAndNoButtons() {
        yesButton.setTitle("Yes", for: .normal)
        yesButton.setTitleColor(.label, for: .normal)
        yesButton.titleLabel?.font = .roundedFont(ofSize: 18, weight: .regular)
        yesButton.layer.cornerRadius = 20
        yesButton.backgroundColor = .presentViewsContents
//        yesButton.layer.borderWidth = 1
//        yesButton.layer.borderColor = UIColor.label.cgColor
        
        yesButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            //make.width.equalTo(120)
        }
        
        buttonsHStackView.addArrangedSubview(yesButton)
        
        noButton.setTitle("No", for: .normal)
        noButton.setTitleColor(.label, for: .normal)
        noButton.titleLabel?.font = .roundedFont(ofSize: 18, weight: .regular)
        noButton.layer.cornerRadius = 20
        noButton.backgroundColor = .presentViewsContents
//        noButton.layer.borderWidth = 1
//        noButton.layer.borderColor = UIColor.label.cgColor
        
        noButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            //make.width.equalTo(120)
        }
        
        buttonsHStackView.addArrangedSubview(noButton)
    }
    
    private func buttonActions() {
        let yesButtonActionID = UIAction.Identifier("yesButtonActionId")
        let yesButtonAction = UIAction { [weak self] _ in
            guard let self else { return }
            print("yes button tapped")
            deleteAction()
            self.dismiss(animated: true)
        }
        
        yesButton.removeAction(identifiedBy: yesButtonActionID, for: .touchUpInside)
        yesButton.addAction(yesButtonAction, for: .touchUpInside)
        
        let noButtonActionId = UIAction.Identifier("noButtonActionId")
        let noButtonAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.dismiss(animated: true)
        }
        
        noButton.removeAction(identifiedBy: noButtonActionId, for: .touchUpInside)
        noButton.addAction(noButtonAction, for: .touchUpInside)
    }
    
}
