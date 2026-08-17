//
//  ContactUsButton.swift
//  Diary Recorder
//
//  Created by Masoud on 8/6/26.
//

import Foundation
import UIKit

class ContactUsButton: UIButton {
    
    private let parentView = UIView()
    private let iconImageView = UIImageView()
    private let titleContactLabel = UILabel()
    private let textContactLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupParentView()
        setupTitleContactLabel()
        setupIconImageView()
        setupTextContactLabel()
    }
    
    private func setupParentView() {
        parentView.backgroundColor = .presentViewsContents
        parentView.isUserInteractionEnabled = false
        parentView.layer.cornerRadius = 20
        
        addSubview(parentView)
        parentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTitleContactLabel() {
        titleContactLabel.textColor = .systemGray
        titleContactLabel.font = .roundedFont(ofSize: 18, weight: .medium)
        titleContactLabel.textAlignment = .left
        
        parentView.addSubview(titleContactLabel)
        
        titleContactLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.horizontalEdges.equalToSuperview().inset(15)
        }
    }
    
    private func setupIconImageView() {
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.layer.cornerRadius = 10
        iconImageView.clipsToBounds = true
        
        parentView.addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(35)
            make.top.equalTo(titleContactLabel.snp.bottom)
                .offset(5)
            make.left.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().inset(15)
        }
    }
    
    private func setupTextContactLabel() {
        textContactLabel.textColor = .label
        textContactLabel.font = .roundedFont(ofSize: 18, weight: .regular)
        textContactLabel.textAlignment = .left
        textContactLabel.numberOfLines = 0
        
            parentView.addSubview(textContactLabel)
        
        textContactLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconImageView)
            make.left.equalTo(iconImageView.snp.right).offset(10)
            make.right.equalToSuperview().inset(10)
        }
    }
    
    func confige(title: String, text: String, image: UIImage) {
        titleContactLabel.text = title
        textContactLabel.text = text
        iconImageView.image = image
    }
}
