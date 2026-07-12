//
//  EditPhotoTableViewCell.swift
//  Diary Recorder
//
//  Created by Masoud on 7/12/26.
//

import Foundation
import UIKit

class EditPhotoTableViewCell: UITableViewCell {
    
    static let identifier = "EditPhotoTableViewCell"
    
    private let titleLabel = UILabel()
    private let iconImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
//        contentView.layer.cornerRadius = 20
//        contentView.backgroundColor = .systemBlue
        
        setuptitleLabel()
        setupIconImageView()
    }
    
    private func setuptitleLabel() {
        titleLabel.font = .roundedFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .left

        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }
    }
    
    private func setupIconImageView() {
        iconImageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(25)
            make.right.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
    }
    
    func configue(title: String, iconImage: UIImage, tintColor: UIColor) {
        titleLabel.text = title
        titleLabel.textColor = tintColor
        iconImageView.image = iconImage
        iconImageView.tintColor = tintColor
    }
}
