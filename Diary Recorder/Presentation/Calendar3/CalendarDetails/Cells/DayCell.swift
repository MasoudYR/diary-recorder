//
//  DayCell.swift
//  Diary Recorder
//
//  Created by Masoud on 6/10/26.
//

import Foundation
import UIKit

protocol DayCellConfiguration: UICollectionViewCell {
    func configure(
        day: CalendarDay,
        isToday: Bool,
        isSelected: Bool,
        isOutOfMonth: Bool,
        outOfMonthAlpha: CGFloat,
        badgeNum: Int?
    )
}

class DayCell: UICollectionViewCell, DayCellConfiguration {
    
    static let identifier = "DayCell"
    
    static var appearance: DayAppearance = .default
    
    private let vStackView = UIStackView()
    private let dayLabelView = UIView()
    private let dayLabel = UILabel()
    private let dayDecorateView = UIView()
    private let dayDecorateBadgeLabel = UILabel()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = Self.appearance.cornerRadius
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
        //dayLabel.font = UIFont.roundedFont(ofSize: 20, weight: .semibold)
        dayLabel.textAlignment = .center
        dayLabel.adjustsFontSizeToFitWidth = true
        dayLabel.minimumScaleFactor = 0.6
        
        dayLabelView.addSubview(dayLabel)
        
        dayLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(5)
        }
        
        vStackView.addArrangedSubview(dayLabelView)
    }
    
    private func setupDecorateBadgeView() {
        dayDecorateView.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
        
        dayDecorateBadgeLabel.font = UIFont.roundedFont(ofSize: 8, weight: .regular)
        dayDecorateBadgeLabel.textColor = .label
        dayDecorateBadgeLabel.textAlignment = .center
        
        dayDecorateView.addSubview(dayDecorateBadgeLabel)
        
        dayDecorateBadgeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(dayDecorateView)
    }
    
    func configure(
        day: CalendarDay,
        isToday: Bool,
        isSelected: Bool,
        isOutOfMonth: Bool,
        outOfMonthAlpha: CGFloat,
        badgeNum: Int?
    ) {
        let a = Self.appearance
        self.dayLabel.text = "\(day.dayNumber)"
        
        contentView.layer.cornerRadius = a.cornerRadius

        if let num = badgeNum, num != 0 {
            //dayDecorateView.isHidden = false
            dayDecorateBadgeLabel.text = "\(num)"
        } else {
            //dayDecorateView.isHidden = true
            dayDecorateBadgeLabel.text = ""
        }
        
        if isToday {
            if isSelected {
                dayLabel.font = a.todayFont
                dayLabel.textColor = a.todayColor
                contentView.backgroundColor = a.selectedBackgroundColor
            } else {
                dayLabel.font = a.todayFont
                dayLabel.textColor = a.todayColor
                contentView.backgroundColor = a.todayColor
            }
        } else {
            if isSelected {
                dayLabel.font = a.selectedFont
                dayLabel.textColor = a.selectedColor
                contentView.backgroundColor = a.selectedBackgroundColor
            } else {
                dayLabel.font = a.normalFont
                dayLabel.textColor = a.normalColor
                contentView.backgroundColor = a.normalBackgroundColor
            }
        }
    }
}
