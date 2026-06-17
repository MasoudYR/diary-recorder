//
//  DayCell.swift
//  Diary Recorder
//
//  Created by Masoud on 6/10/26.
//

import Foundation
import UIKit
import SnapKit

protocol DayCellConfiguration: UICollectionViewCell {
    func configure(
        day: CalendarDay,
        isToday: Bool,
        isSelected: Bool,
        isOutOfMonth: Bool,
        badgeNum: Int?
    )
}

class DayCell: UICollectionViewCell, DayCellConfiguration {
    
    static var counter = 0
    
    static let identifier = "DayCell"
    
    static var appearance: DayAppearance = .default
    
    private let vStackView = UIStackView()
    private let dayLabelView = UIView()
    private let dayLabel = UILabel()
    private let dayDecorateView = UIView()
    private let dayDecorateBadgeLabel = UILabel()
    
    private var dayLabelTopConstraint: Constraint?
    //private var decorateSizeConstraint: Constraint?
    
    private var lastCellSize: CGSize? = .zero
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        Self.counter += 1
        print(">>>", Self.self, #function, "counter: \(Self.counter)")
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .systemBackground
        contentView.clipsToBounds = true
        dayDecorateView.clipsToBounds = true
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
        dayLabel.textAlignment = .center
        dayLabel.adjustsFontSizeToFitWidth = true //in dare size numbre rooz ro kam mikine!
        dayLabel.minimumScaleFactor = 0.9
        
        dayLabelView.addSubview(dayLabel)
        
        dayLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            dayLabelTopConstraint = make.top.equalToSuperview().offset(10).constraint
        }
        
        vStackView.addArrangedSubview(dayLabelView)
    }
    
    private func setupDecorateBadgeView() {
        dayDecorateBadgeLabel.textColor = .label
        dayDecorateBadgeLabel.textAlignment = .center
        dayDecorateBadgeLabel.adjustsFontSizeToFitWidth = true //in dare size numbre rooz ro kam mikine!
        dayDecorateBadgeLabel.minimumScaleFactor = 0.8
        
        dayDecorateView.addSubview(dayDecorateBadgeLabel)
        
        dayDecorateBadgeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(2)
            make.top.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(dayDecorateView)
    }
    
    func configure(
        day: CalendarDay,
        isToday: Bool,
        isSelected: Bool,
        isOutOfMonth: Bool,
        badgeNum: Int?
    ) {
        let a = Self.appearance
        self.dayLabel.text = "\(day.dayNumber)"

        if let num = badgeNum, num != 0 {
            dayDecorateBadgeLabel.text = "\(num)"
        } else {
            dayDecorateBadgeLabel.text = ""
        }
        
        let baseFont: UIFont
        let textColor: UIColor
        let bg: UIColor
        
        if isToday {
            baseFont = a.todayFont
            textColor = a.todayColor
            bg = isSelected ? a.selectedBackgroundColor : a.todayBackgroundColor
        } else if isSelected {
            baseFont = a.selectedFont
            textColor = a.selectedColor
            bg = a.selectedBackgroundColor
        } else {
            baseFont = a.normalFont
            textColor = a.normalColor
            bg = a.normalBackgroundColor
        }
        
//        guard let lastCellSize else { return }
//        let topConstraintScale = Float(lastCellSize.height * 0.25)
//        print("@@this is top constraint value: \(lastCellSize)")
//        guard let dayLabelTopConstraint else { return }
//        dayLabelTopConstraint.update(offset: topConstraintScale)
        
        dayLabel.font = baseFont
        dayLabel.textColor = textColor
        
        bg.withAlphaComponent(0.7)
        contentView.backgroundColor = bg
        
        dayDecorateBadgeLabel.font = .roundedFont(ofSize: a.badgeFontSize, weight: .regular)
        contentView.layer.cornerRadius = a.cornerRadius
    }
}
