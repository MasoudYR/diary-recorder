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
    private let renameButton = UIButton()
    private let cancelButton = UIButton()
    
    init(viewModel: NameDiaryViewModel, router: NameDiaryRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make(
        lastSavedDiary: RecordingFileDetails,
        nameCurrentValueSubject: PassthroughSubject<String, Never>
    ) -> NameDiaryViewController {
        let viewModel = NameDiaryViewModel(lastSavedDiary: lastSavedDiary, nameCurrentValueSubject: nameCurrentValueSubject)
        let router = NameDiaryRouter()
        let viewController = NameDiaryViewController(
            viewModel: viewModel,
            router: router
        )
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
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
        vStackView.alignment = .fill
        vStackView.spacing = 15
        vStackView.isLayoutMarginsRelativeArrangement = true
        vStackView.layoutMargins = .init(top: 30, left: 30, bottom: 15, right: 30)
        
        view.addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
    }
    
    private func setupNameLabel() {
        TitleLabel.text = "Name Your Diary"
        TitleLabel.font = .roundedFont(ofSize: 24, weight: .bold)
        TitleLabel.textAlignment = .center
        
        vStackView.addArrangedSubview(TitleLabel)
    }
    
    private func setupTextFieldView() {
        nameTextFieldView.layer.borderWidth = 1
        nameTextFieldView.layer.borderColor = UIColor.label.cgColor
        nameTextFieldView.layer.cornerRadius = 20
        nameTextFieldView.backgroundColor = .main
        
        nameTextField.delegate = self
        nameTextField.text = viewModel.text
        nameTextField.placeholder = "Maximum 50 characters"
        nameTextField.font = .roundedFont(ofSize: 18, weight: .regular)
        nameTextField.textColor = .label
        nameTextField.backgroundColor = .main
        
        nameTextFieldView.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(15)
            make.horizontalEdges.equalToSuperview().inset(15)
        }
        
        vStackView.addArrangedSubview(nameTextFieldView)
    }
    
    private func setupButtonsHStackView() {
        buttonsHStackView.axis = .horizontal
        buttonsHStackView.distribution = .fillEqually
        buttonsHStackView.alignment = .fill
        buttonsHStackView.spacing = 40
        
        vStackView.addArrangedSubview(buttonsHStackView)
    }
    
    private func setupButtons() {
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.label, for: .normal)
        cancelButton.tintColor = .label
        cancelButton.titleLabel?.font = .roundedFont(ofSize: 18, weight: .regular)
        cancelButton.backgroundColor = .main
        cancelButton.layer.cornerRadius = 20
//        cancelButton.layer.borderWidth = 1
//        cancelButton.layer.borderColor = UIColor.label.cgColor
        
        cancelButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            //make.width.equalTo(110)
        }
        
        buttonsHStackView.addArrangedSubview(cancelButton)
        
        renameButton.setTitle("Save", for: .normal)
        renameButton.setTitleColor(.label, for: .normal)
        renameButton.tintColor = .label
        renameButton.titleLabel?.font = .roundedFont(ofSize: 18, weight: .regular)
        renameButton.backgroundColor = .main
        renameButton.layer.cornerRadius = 20
//        renameButton.layer.borderWidth = 1
//        renameButton.layer.borderColor = UIColor.label.cgColor
        
        renameButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            //make.width.equalTo(110)
        }
        
        buttonsHStackView.addArrangedSubview(renameButton)
    }
    
    private func setupActions() {
        let renameButtonActionId = UIAction.Identifier("renameButtonActionId")
        let renameButtonAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.viewModel.renameDiary()
            self.dismiss(animated: true)
        }
        
        renameButton.removeAction(identifiedBy: renameButtonActionId, for: .touchUpInside)
        renameButton.addAction(renameButtonAction, for: .touchUpInside)
        
        let cancelButtonActionId = UIAction.Identifier("cancelButtonActionId")
        let cancelButtonAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.dismiss(animated: true)
        }
        
        cancelButton.removeAction(identifiedBy: cancelButtonActionId, for: .touchUpInside)
        cancelButton.addAction(cancelButtonAction, for: .touchUpInside)
        
        let nameTextFieldActionId = UIAction.Identifier("nameTextFieldActionId")
        let nameTextFieldAction = UIAction { [weak self] _ in
            guard let self else { return }
            viewModel.text = nameTextField.text ?? ""
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func dismissKeyboardTappingOutsideTextfield() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        print("gesture recognizer is working incorrectly")
    }
}
