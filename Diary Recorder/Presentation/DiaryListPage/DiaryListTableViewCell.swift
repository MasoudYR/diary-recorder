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
    
    private let micImageView = UIImageView()
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
        contentView.addSubview(micImageView)
        micImageView.image = UIImage(systemName: "microphone")
        micImageView.tintColor = .systemGreen
        micImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.verticalEdges.equalToSuperview().inset(5)
            make.height.width.equalTo(50)
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        nameLabel.text = "unknown name"
        nameLabel.textColor = .label
        nameLabel.textAlignment = .left
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(micImageView.snp.top)
            make.left.equalTo(micImageView.snp.right).offset(5)
        }
        
        contentView.addSubview(dateAndTimeLabel)
        dateAndTimeLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        dateAndTimeLabel.text = ""
        dateAndTimeLabel.textColor = .label
        dateAndTimeLabel.textAlignment = .left
        dateAndTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(micImageView.snp.right).offset(5)
            make.bottom.equalTo(micImageView.snp.bottom)
        }
        
        contentView.addSubview(durationLabel)
        durationLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        durationLabel.text = "00:00:00.00"
        durationLabel.textColor = .label
        durationLabel.textAlignment = .left
        durationLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.bottom.equalTo(dateAndTimeLabel.snp.bottom)
        }
        
        
    }
    
    func configure(name: String, duration: String, dateAndTime: String) {
        nameLabel.text = name
        durationLabel.text = duration
        dateAndTimeLabel.text = dateAndTime
    }
}
