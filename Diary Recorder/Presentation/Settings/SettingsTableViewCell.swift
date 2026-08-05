//
//  SettingsTableViewCell.swift
//  Diary Recorder
//
//  Created by Masoud on 8/1/26.
//

import Foundation
import UIKit

class SettingsTableViewCell: UITableViewCell {
    static let identifier = "SettingsTableViewCell"
    
    private let parentView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        //contentView.backgroundColor = .systemOrange
        setupParentView()
        setupIconImageView()
        setupTitleLabelView()
    }
    
    private func setupParentView() {
        parentView.backgroundColor = .presentViewsContents
        contentView.addSubview(parentView)
        parentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupIconImageView() {
        let symbolConfiguration = UIImage.SymbolConfiguration.init(pointSize: 20)
        iconImageView.preferredSymbolConfiguration = symbolConfiguration
        iconImageView.contentMode = .center
        iconImageView.layer.cornerRadius = 10
        parentView.addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.size.equalTo(35)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupTitleLabelView() {
        titleLabel.font = .roundedFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .left
        parentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(iconImageView.snp.right).offset(15)
        }
    }
    
    func configue(
        iconImage: UIImage,
        iconTintColor: UIColor = .white,
        iconBackgroundColor: UIColor = .label,
        title: String
    ) {
        iconImageView.image = iconImage
        iconImageView.tintColor = iconTintColor
        iconImageView.backgroundColor = iconBackgroundColor
        titleLabel.text = title
    }
    
    func selectionChanged(isSelected: Bool) {
        let backgroundColor: UIColor = isSelected
        ? .systemGray2
        : .presentViewsContents
        if isSelected {
            parentView.backgroundColor = backgroundColor
        } else {
            
            UIView.animate(withDuration: 0.3) {
                self.parentView.backgroundColor = backgroundColor
            }
        }
    }
}
