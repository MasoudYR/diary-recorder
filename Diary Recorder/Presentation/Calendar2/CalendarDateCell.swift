//
//  CalendarDateCell.swift
//  Diary Recorder
//
//  Created by Masoud on 6/4/26.
//

import Foundation
import UIKit
import SnapKit
import JTAppleCalendar

class EmptyCell2: JTACDayCell {
    static var identifier: String { String(describing: Self.self) }
}

class CalendarDateCell: JTACDayCell {
    
    static let identifier = "calenderDateCell"
    
    private let vStackView = UIStackView()
    private let dayLabelView = UIView()
    private let dayLabel = UILabel()
    private let dayDecorateView = UIView()
    
    private let dayDecorateBadgeLabel = UILabel()
    private let dayDecorateBadgeView = UIView()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 20
        setupStackView()
        setupDayLabel()
        setupDecorateBadgeView()
    }
    
    private func setupStackView() {
        vStackView.axis = .vertical
        vStackView.spacing = 2
        vStackView.alignment = .fill
        vStackView.distribution = .fillEqually
        
        contentView.addSubview(vStackView)
        
        vStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

    }
    
    private func setupDayLabel() {
        
        
        vStackView.addArrangedSubview(dayLabelView)
        //dayLabelView.backgroundColor = .green
        dayLabel.font = UIFont.roundedFont(ofSize: 20, weight: .semibold)
        dayLabel.textAlignment = .center
        
        //dayLabel.backgroundColor = .yellow
        dayLabelView.addSubview(dayLabel)
        
        dayLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(5)
        }
        
        
    }
    
    private func setupDecorateBadgeView() {
        
        dayDecorateBadgeView.backgroundColor = .systemGray
        dayDecorateBadgeView.layer.cornerRadius = 8
//        dayDecorateBadgeView.layer.borderWidth = 2
//        dayDecorateBadgeView.layer.borderColor = UIColor.systemGray.cgColor
        
        dayDecorateView.addSubview(dayDecorateBadgeView)
        
        dayDecorateBadgeView.snp.makeConstraints { make in
            make.size.equalTo(16)
            make.center.equalToSuperview()
        }
        
        dayDecorateBadgeLabel.font = UIFont.roundedFont(ofSize: 8, weight: .regular)
        dayDecorateBadgeLabel.textColor = .label
        dayDecorateBadgeLabel.textAlignment = .center
        
        dayDecorateBadgeView.addSubview(dayDecorateBadgeLabel)
        
        dayDecorateBadgeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(dayDecorateView)
    }
    
    func configure(
        dayNumber: String,
        decorateBadgeText: String?,
        isSelected: Bool,
        isToday: Bool
    ) {
        self.dayLabel.text = dayNumber
        
        if let text = decorateBadgeText {
            dayDecorateBadgeView.isHidden = false
            dayDecorateBadgeLabel.text = text
        } else {
            dayDecorateBadgeView.isHidden = true
        }
        
        if isToday {
            if isSelected {
                contentView.backgroundColor = .main
                dayLabel.textColor = .systemRed
            } else {
                contentView.backgroundColor = .clear
                dayLabel.textColor = .systemRed
            }
        } else {
            if isSelected {
                contentView.backgroundColor = .main
                dayLabel.textColor = .label
            } else {
                contentView.backgroundColor = .clear
                dayLabel.textColor = .label
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.text = ""
        contentView.backgroundColor = .clear
    }
}

