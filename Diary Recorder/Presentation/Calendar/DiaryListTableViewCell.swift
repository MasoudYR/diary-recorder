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
    
    private let diaryImageView = UIImageView()
    private let nameLabel = UILabel()
    private let parentSubDetails = UIView()
    private let recordTimeIcon = UIImageView()
    private let recordTimeLabel = UILabel()
    private let separatorView = UIView()
    private let durationIcon = UIImageView()
    private let durationLabel = UILabel()
    private let emojiImageView = UIImageView()
    private let arrowImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupDiaryImageView()
        setupNameLabel()
        setupParentSubDetails()
        setupEmojiImageView()
        setupArrowImageView()
    }
    
    private func setupDiaryImageView() {
        diaryImageView.layer.cornerRadius = 20
        diaryImageView.contentMode = .scaleAspectFit
        diaryImageView.clipsToBounds = true
        
        contentView.addSubview(diaryImageView)
        
        diaryImageView.snp.makeConstraints { make in
            make.size.equalTo(80)
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupNameLabel() {
        nameLabel.font = UIFont.roundedFont(ofSize: 18, weight: .semibold)
        nameLabel.text = "unknown name"
        nameLabel.textColor = .label
        nameLabel.textAlignment = .left
        
        contentView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(diaryImageView.snp.right).offset(10)
            //make.right.equalTo(contentView.snp.right).inset(10)
        }
    }
    
    private func setupParentSubDetails() {
        
        contentView.addSubview(parentSubDetails)
        
        parentSubDetails.snp.makeConstraints { make in
            make.left.equalTo(diaryImageView).offset(10)
            make.bottom.equalToSuperview().inset(10)
        }
        
        setupRecordTime()
        setupSeparartorView()
        setupDuration()
    }
    
    private func setupRecordTime() {
        recordTimeIcon.image = UIImage(systemName: "clock")
        recordTimeIcon.tintColor = .secondaryLabel
        recordTimeIcon.contentMode = .scaleAspectFit
        
        parentSubDetails.addSubview(recordTimeIcon)
        
        recordTimeIcon.snp.makeConstraints { make in
            make.size.equalTo(30)
            make.left.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }
        
        recordTimeLabel.font = UIFont.roundedFont(ofSize: 15, weight: .regular)
        recordTimeLabel.text = ""
        recordTimeLabel.textColor = .secondaryLabel
        recordTimeLabel.textAlignment = .left
        
        parentSubDetails.addSubview(recordTimeLabel)
        
        recordTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(recordTimeIcon.snp.right).offset(5)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupSeparartorView() {
        separatorView.backgroundColor = .secondaryLabel
        
        parentSubDetails.addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.verticalEdges.equalToSuperview()
            make.left.equalTo(recordTimeLabel.snp.right).offset(10)
        }
    }
    
    private func setupDuration() {
        durationIcon.image = UIImage(systemName: "waveform")
        durationIcon.tintColor = .secondaryLabel
        durationIcon.contentMode = .scaleAspectFit
        
        parentSubDetails.addSubview(durationIcon)
        
        durationIcon.snp.makeConstraints { make in
            make.size.equalTo(30)
            make.left.equalTo(separatorView.snp.right).offset(10)
            make.verticalEdges.equalToSuperview()
        }
        
        durationLabel.font = UIFont.roundedFont(ofSize: 15, weight: .regular)
        durationLabel.text = "00:00:00.00"
        durationLabel.textColor = .secondaryLabel
        durationLabel.textAlignment = .left
        
        parentSubDetails.addSubview(durationLabel)
        
        durationLabel.snp.makeConstraints { make in
            make.left.equalTo(durationIcon.snp.right).offset(5)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupEmojiImageView() {
        
        emojiImageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(diaryImageView)
        
        diaryImageView.snp.makeConstraints { make in
            make.size.equalTo(60)
            make.centerY.equalToSuperview()
            make.left.equalTo(nameLabel.snp.right).offset(10)
            make.left.equalTo(parentSubDetails.snp.right).offset(10)
        }
    }
    
    private func setupArrowImageView() {
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .label
        arrowImageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(arrowImageView)
        
        arrowImageView.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.right.equalToSuperview().inset(10)
            make.left.equalTo(diaryImageView.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
    }

    func configure(
        diaryImage: UIImage,
        name: String,
        recordTime: String,
        duration: String,
        emoji: UIImage
    ) {
        diaryImageView.image = diaryImage
        nameLabel.text = name
        recordTimeLabel.text = recordTime
        durationLabel.text = duration
        emojiImageView.image = emoji
    }
}
