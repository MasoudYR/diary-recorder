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
    private let vStackView = UIStackView()
    private let nameLabel = UILabel()
    //private let parentSubDetails = UIView()
    private let recordTimeParentView = UIView()
    private let recordTimeIcon = UIImageView()
    private let recordTimeLabel = UILabel()
    
    //private let separatorView = UIView()
    private let durationParentView = UIView()
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
        setupVStackView()
        setupNameLabel()
        //setupParentSubDetails()
        setupRecordTime()
        setupDuration()
        setupEmojiImageView()
        setupArrowImageView()
    }
    
    private func setupDiaryImageView() {
        diaryImageView.backgroundColor = .red
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
    
    private func setupVStackView() {
        //vStackView.backgroundColor = .red
        vStackView.axis = .vertical
        vStackView.spacing = 5
        vStackView.distribution = .fillProportionally
        vStackView.alignment = .leading
        
        contentView.addSubview(vStackView)
        
        vStackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(10)
            make.left.equalTo(diaryImageView.snp.right).offset(10)
        }
    }
    
    private func setupNameLabel() {
        nameLabel.font = UIFont.roundedFont(ofSize: 18, weight: .semibold)
        nameLabel.text = "unknown name"
        nameLabel.numberOfLines = 2
        nameLabel.textColor = .label
        nameLabel.textAlignment = .left
        
        vStackView.addArrangedSubview(nameLabel)
        
//        nameLabel.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(10)
//            make.left.equalTo(diaryImageView.snp.right).offset(10)
//            //make.right.equalTo(contentView.snp.right).inset(10)
//        }
    }
    
    private func setupParentSubDetails() {
//        
//        contentView.addSubview(parentSubDetails)
//        
//        parentSubDetails.snp.makeConstraints { make in
//            make.left.equalTo(diaryImageView).offset(10)
//            make.bottom.equalToSuperview().inset(10)
//        }
//        
//        setupRecordTime()
//        setupSeparartorView()
//        setupDuration()
    }
    
    private func setupRecordTime() {
        recordTimeParentView.backgroundColor = .systemGreen
        
        recordTimeIcon.image = UIImage(systemName: "clock")
        recordTimeIcon.tintColor = .secondaryLabel
        recordTimeIcon.contentMode = .scaleAspectFit
        
        recordTimeParentView.addSubview(recordTimeIcon)
        
        recordTimeIcon.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.left.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }
        
        recordTimeLabel.font = UIFont.roundedFont(ofSize: 15, weight: .regular)
        recordTimeLabel.text = ""
        recordTimeLabel.textColor = .secondaryLabel
        recordTimeLabel.textAlignment = .left
        
        recordTimeParentView.addSubview(recordTimeLabel)
        
        recordTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(recordTimeIcon.snp.right).offset(5)
            make.centerY.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(recordTimeParentView)
    }
    
    private func setupSeparartorView() {
//        separatorView.backgroundColor = .secondaryLabel
//        
//        parentSubDetails.addSubview(separatorView)
//        
//        separatorView.snp.makeConstraints { make in
//            make.width.equalTo(1)
//            make.verticalEdges.equalToSuperview()
//            make.left.equalTo(recordTimeLabel.snp.right).offset(10)
//        }
    }
    
    private func setupDuration() {
        
        durationParentView.backgroundColor = .blue
        
        durationIcon.image = UIImage(systemName: "waveform")
        durationIcon.tintColor = .secondaryLabel
        durationIcon.contentMode = .scaleAspectFit
        
        durationParentView.addSubview(durationIcon)
        
        durationIcon.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.left.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }
        
        durationLabel.font = UIFont.roundedFont(ofSize: 15, weight: .regular)
        durationLabel.text = "00:00:00.00"
        durationLabel.textColor = .secondaryLabel
        durationLabel.textAlignment = .left
        
        durationParentView.addSubview(durationLabel)
        
        durationLabel.snp.makeConstraints { make in
            make.left.equalTo(durationIcon.snp.right).offset(5)
            make.centerY.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(durationParentView)
    }
    
    private func setupEmojiImageView() {
        emojiImageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(emojiImageView)
        
        emojiImageView.snp.makeConstraints { make in
            make.size.equalTo(40)
            //make.centerY.equalToSuperview()
            //make.left.equalTo(nameLabel.snp.right).offset(10)
            //make.left.equalTo(vStackView.snp.right).offset(10)
            make.bottom.equalTo(vStackView)
            make.right.equalTo(vStackView)
        }
    }
    
    private func setupArrowImageView() {
        //arrowImageView.backgroundColor = .green
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .label
        arrowImageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(arrowImageView)
        
        arrowImageView.snp.makeConstraints { make in
            make.size.equalTo(25)
            make.right.equalToSuperview().inset(10)
            //make.left.equalTo(emojiImageView.snp.right)
            make.left.equalTo(vStackView.snp.right)
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
