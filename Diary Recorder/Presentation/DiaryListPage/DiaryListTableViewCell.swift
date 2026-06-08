//
//  DiaryListTableViewCell.swift
//  Diary Recorder
//
//  Created by Masoud on 5/13/26.
//

import Foundation
import UIKit

class DiaryListTableViewCell: UITableViewCell {
    static let identifier = "diarytableviewcell"
    
    private let iconView = UIView()
    private let iconImageView = UIImageView()
    private let nameLabel = UILabel()
    private let durationLabel = UILabel()
    private let dateAndTimeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        iconView.backgroundColor = .systemGray6
        iconView.layer.cornerRadius = 20
        iconView.layer.borderWidth = 1
        iconView.layer.borderColor = UIColor.label.cgColor
        
        contentView.addSubview(iconView)
        
        iconView.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        
        iconImageView.image = UIImage(systemName: "play.fill")
        iconImageView.tintColor = .label
        
        iconView.addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints { make in
            //make.size.equalTo(20)
            make.center.equalToSuperview()
        }
       
        
        contentView.addSubview(nameLabel)
        nameLabel.font = UIFont.roundedFont(ofSize: 18, weight: .semibold)
        nameLabel.text = "unknown name"
        nameLabel.textColor = .label
        nameLabel.textAlignment = .left
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.left.equalTo(iconView.snp.right).offset(10)
            make.right.equalTo(contentView.snp.right).inset(10)
        }
        
        contentView.addSubview(dateAndTimeLabel)
        dateAndTimeLabel.font = UIFont.roundedFont(ofSize: 15, weight: .regular)
        dateAndTimeLabel.text = ""
        dateAndTimeLabel.textColor = .secondaryLabel
        dateAndTimeLabel.textAlignment = .left
        dateAndTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(10)
            make.bottom.equalToSuperview().inset(5)
        }
        
        contentView.addSubview(durationLabel)
        durationLabel.font = UIFont.roundedFont(ofSize: 15, weight: .regular)
        durationLabel.text = "00:00:00.00"
        durationLabel.textColor = .secondaryLabel
        durationLabel.textAlignment = .left
        durationLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(5)
        }
        
        
    }
    
    func configure(name: String, duration: String, dateAndTime: String) {
        nameLabel.text = name
        durationLabel.text = duration
        dateAndTimeLabel.text = dateAndTime
    }
}
