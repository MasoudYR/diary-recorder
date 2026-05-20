//
//  NameDiaryViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 5/18/26.
//

import Foundation
import UIKit
import Combine
import SnapKit

class NameDiaryViewController: UIViewController {
    
    private let viewModel: NameDiaryViewModel
    private let router: NameDiaryRouter
    
    private let vStackView = UIStackView()
    private let TitleLabel = UILabel()
    private let nameTextFieldView = UIView()
    private let nameTextField = UITextField()
    private let buttonsHStackView = UIStackView()
    private let saveButton = UIButton()
    private let cancelButton = UIButton()
    
    init(viewModel: NameDiaryViewModel, router: NameDiaryRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make() -> NameDiaryViewController {
        let viewModel = NameDiaryViewModel()
        let router = NameDiaryRouter()
        let viewController = NameDiaryViewController(
            viewModel: viewModel,
            router: router
        )
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func setupUI() {
        setupVStack()
        setupNameLabel()
        setupTextFieldView()
        setupButtonsHStackView()
        setupButtons()
        setupActions()
    }
    
    private func setupVStack() {
        vStackView.axis = .vertical
        vStackView.distribution = .fill
        vStackView.alignment = .center
        vStackView.spacing = 15
        vStackView.isLayoutMarginsRelativeArrangement = true
        vStackView.layoutMargins = .init(top: 30, left: 15, bottom: 15, right: 15)
        
        view.addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
    }
    
    private func setupNameLabel() {
        TitleLabel.text = "Name Your Diary"
        TitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        TitleLabel.textAlignment = .center
        
        vStackView.addArrangedSubview(TitleLabel)
    }
    
    private func setupTextFieldView() {
        nameTextFieldView.layer.borderWidth = 2
        nameTextFieldView.layer.borderColor = UIColor.label.cgColor
        nameTextFieldView.layer.cornerRadius = 8
        
        nameTextField.delegate = self
        nameTextField.placeholder = "Maximum 50 characters"
        nameTextField.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        nameTextField.textColor = .label
        nameTextField.backgroundColor = .systemBackground
        
        nameTextFieldView.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
        
        vStackView.addArrangedSubview(nameTextFieldView)
    }
    
    private func setupButtonsHStackView() {
        buttonsHStackView.axis = .horizontal
        buttonsHStackView.distribution = .fill
        buttonsHStackView.alignment = .fill
        buttonsHStackView.spacing = 40
        
        vStackView.addArrangedSubview(buttonsHStackView)
    }
    
    private func setupButtons() {
        saveButton.setTitle("Save", for: .normal)
        saveButton.tintColor = .label
        saveButton.layer.cornerRadius = 8
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.label.cgColor
        
        saveButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(110)
        }
        
        buttonsHStackView.addArrangedSubview(saveButton)
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.tintColor = .label
        cancelButton.layer.cornerRadius = 8
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.label.cgColor
        
        saveButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(110)
        }
        
        buttonsHStackView.addArrangedSubview(cancelButton)
    }
    
    private func setupActions() {
        let saveButtonActionId = UIAction.Identifier("saveButtonActionId")
        let saveButtonAction = UIAction { [weak self] _ in
            guard let self else { return }
            
            //
        }
        
        saveButton.removeAction(identifiedBy: saveButtonActionId, for: .touchUpInside)
        saveButton.addAction(saveButtonAction, for: .touchUpInside)
        
        let cancelButtonActionId = UIAction.Identifier("cancelButtonActionId")
        let cancelButtonAction = UIAction { [weak self] _ in
            guard let self else { return }
            
            //
        }
        
        cancelButton.removeAction(identifiedBy: cancelButtonActionId, for: .touchUpInside)
        cancelButton.addAction(cancelButtonAction, for: .touchUpInside)
        
        let nameTextFieldActionId = UIAction.Identifier("nameTextFieldActionId")
        let nameTextFieldAction = UIAction { [weak self] _ in
            guard let self else { return }
            viewModel.text = nameTextField.text
        }
        
        nameTextField.removeAction(identifiedBy: nameTextFieldActionId, for: .editingChanged)
        nameTextField.addAction(nameTextFieldAction, for: .editingChanged)
        
    }
}

extension NameDiaryViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = nameTextField.text ?? ""
        let nextText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if nextText.count > 50 {
            return false
        }
        return true
    }
    
}
