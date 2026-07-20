//
//  InputAccessoryView.swift
//  Diary Recorder
//
//  Created by Masoud on 7/19/26.
//

import UIKit
import Combine

class InputAccessoryView: UIView {
    
    private let dismissButton = UIButton()
    private weak var responder: UIResponder?
    
    init(responder: UIResponder) {
        self.responder = responder
        super.init(frame: .init(x: 0, y: 0, width: 0, height: 50))
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        setupDismissButton()
    }
    
    private func setupDismissButton() {
        
        addSubview(dismissButton)
        let configuration = UIImage.SymbolConfiguration(scale: .medium)
        let image = UIImage(systemName: "keyboard.chevron.compact.down", withConfiguration: configuration)
        dismissButton.tintColor = .label
        dismissButton.backgroundColor = .systemGray5
        dismissButton.setImage(image, for: .normal)
        dismissButton.layer.cornerRadius = 22
        dismissButton.snp.makeConstraints { make in
            make.size.equalTo(44)
            make.top.centerX.equalToSuperview()
        }
        
        let dismissButtonAction = UIAction { [unowned self] _ in
            self.responder?.resignFirstResponder()
        }
        
        dismissButton.addAction(
            dismissButtonAction,
            for: .touchUpInside
        )
    }
    
}
