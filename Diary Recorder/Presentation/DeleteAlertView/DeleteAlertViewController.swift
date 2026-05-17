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
    
    //private let viewModel: DeleteAlertViewModel
    //private let router: DeleteAlertRouter
    
    private let vStackView = UIStackView()
    private let deleteIconeImageView = UIImageView()
    private let titleLabel = UILabel()
    private let deleteMessageLabel = UILabel()
    private let buttonsHStackView = UIStackView()
    private let yesButton = UIButton()
    private let noButton = UIButton()
    private let deleteAction: () -> Void
    
    init(deleteAction: @escaping () -> Void) {
        self.deleteAction = deleteAction
        //self.viewModel = viewModel
        //self.router = router
        super.init(nibName: nil, bundle: nil)
        //self.router.deleteAlertViewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make(deleteHandler: @escaping () -> Void) -> DeleteAlertViewController {
        let viewController = DeleteAlertViewController(deleteAction: deleteHandler)
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.custom { _ in 250 }]
            sheet.preferredCornerRadius = 16
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
        vStackView.alignment = .center
        vStackView.isLayoutMarginsRelativeArrangement = true
        vStackView.layoutMargins = .init(top: 30, left: 10, bottom: 10, right: 10)
        view.addSubview(vStackView)
        
        vStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
    }
    
    private func setupImageIconView() {
        deleteIconeImageView.image = UIImage(systemName: "trash")
        deleteIconeImageView.tintColor = .label
        deleteIconeImageView.snp.makeConstraints { make in
            make.size.equalTo(30)
        }
        
        vStackView.addArrangedSubview(deleteIconeImageView)
    }
    
    private func setupDeleteMessageLabels() {
        titleLabel.text = "Delete Alert"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        
        vStackView.addArrangedSubview(titleLabel)
        
        deleteMessageLabel.text = "Are you sure you want to delete this file?"
        deleteMessageLabel.font = .systemFont(ofSize: 18)
        deleteMessageLabel.textColor = .label
        deleteMessageLabel.textAlignment = .left
        deleteMessageLabel.numberOfLines = 0
        
        vStackView.addArrangedSubview(deleteMessageLabel)
        vStackView.setCustomSpacing(25, after: deleteMessageLabel)
    }
    
    private func setupButtonsHStackView() {
        buttonsHStackView.axis = .horizontal
        buttonsHStackView.spacing = 40
        buttonsHStackView.distribution = .fill
        buttonsHStackView.alignment = .fill
        
        vStackView.addArrangedSubview(buttonsHStackView)
    }
    
    private func setupYesAndNoButtons() {
        yesButton.setTitle("Yes", for: .normal)
        yesButton.setTitleColor(.label, for: .normal)
        yesButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        yesButton.layer.cornerRadius = 8
        yesButton.backgroundColor = .systemBackground
        yesButton.layer.borderWidth = 1
        yesButton.layer.borderColor = UIColor.label.cgColor
        
        yesButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(120)
        }
        
        buttonsHStackView.addArrangedSubview(yesButton)
        
        noButton.setTitle("No", for: .normal)
        noButton.setTitleColor(.label, for: .normal)
        noButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        noButton.layer.cornerRadius = 8
        noButton.backgroundColor = .systemBackground
        noButton.layer.borderWidth = 1
        noButton.layer.borderColor = UIColor.label.cgColor
        
        noButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(120)
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
